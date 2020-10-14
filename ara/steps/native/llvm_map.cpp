// vim: set noet ts=4 sw=4:

#include "llvm_map.h"

#include "common/llvm_common.h"

#include <boost/property_tree/json_parser.hpp>
#include <llvm/Analysis/CFGPrinter.h>
#include <llvm/IR/BasicBlock.h>

using namespace llvm;
using namespace std;
using namespace boost::property_tree;

namespace ara::step {

	namespace {
		template <typename Graph>
		class LLVMMapImpl {
		  private:
			using Vertex = typename boost::graph_traits<Graph>::vertex_descriptor;
			using Edge = typename boost::graph_traits<Graph>::edge_descriptor;

			Graph& g;
			graph::CFG& cfg;
			graph::GraphData& graph_data;
			Logger& logger;

			bool get(const std::map<const BasicBlock*, graph::llvmext::BasicBlock> m, const BasicBlock* k,
			         bool default_value, bool loop) {
				if (m.find(k) == m.end()) {
					return default_value;
				} else {
					if (loop) {
						return m.at(k).is_loop_head;
					} else {
						return m.at(k).is_exit_block;
					}
				}
			}

			Vertex add_abb(std::string name, graph::ABBType type, const BasicBlock* entry, const BasicBlock* exit,
			               Vertex function, bool is_entry, const std::string& source_loc) {
				auto abb = boost::add_vertex(g);
				cfg.name[abb] = name;
				cfg.type[abb] = static_cast<int>(type);
				cfg.entry_bb[abb] = reinterpret_cast<intptr_t>(entry);
				cfg.exit_bb[abb] = reinterpret_cast<intptr_t>(exit);

				if (source_loc == "all" || (source_loc == "calls" && type == graph::ABBType::call)) {
					try {
						auto [file, line] = get_source_location(entry->front());
						cfg.file[abb] = file.string();
						cfg.line[abb] = line;
					} catch (const LLVMError&) {
						logger.warn() << "Debug location unknown, while requested: " << entry->front() << std::endl;
					}
				}

				auto i_edge = boost::add_edge(abb, function, g);
				cfg.etype[i_edge.first] = static_cast<int>(graph::CFType::a2f);

				auto o_edge = boost::add_edge(function, abb, g);
				cfg.etype[o_edge.first] = static_cast<int>(graph::CFType::f2a);

				cfg.is_entry[o_edge.first] = is_entry;

				assert(entry == exit);
				cfg.is_exit[abb] = get(graph_data.basic_blocks, entry, false, false);
				cfg.is_loop_head[abb] = get(graph_data.basic_blocks, entry, false, true);

				return abb;
			}

		  public:
			LLVMMapImpl(Graph& g, graph::CFG& cfg, graph::GraphData& graph_data, Logger& logger,
			            bool dump_llvm_functions, const std::string& prefix, const std::string& source_loc)
			    : g(g), cfg(cfg), graph_data(graph_data), logger(logger) {
				std::map<const BasicBlock*, Vertex> abbs;

				unsigned name_counter = 0;

				for (Function& func : graph_data.get_module()) {

					if (dump_llvm_functions) {
						// dump LLVM functions as CFG into dot files
						std::string filename = prefix + func.getName().str() + ".dot";
						std::error_code ec;
						llvm::raw_fd_ostream file(filename, ec, sys::fs::OF_Text);

						if (!ec) {
							llvm::WriteGraph(file, (const Function*)&func, false);
						} else {
							logger.err() << "  error opening file for writing!" << std::endl;
						}
					}

					if (is_intrinsic(func)) {
						continue;
					}
					auto function = boost::add_vertex(g);
					cfg.name[function] = func.getName();
					cfg.implemented[function] = true;
					cfg.function[function] = reinterpret_cast<intptr_t>(&func);
					cfg.is_function[function] = true;

					logger.debug() << "Inserted new function " << cfg.name[function] << "." << std::endl;

					unsigned bb_counter = 0;
					for (BasicBlock& bb : func) {
						std::stringstream ss;
						ss << "ABB" << name_counter++;
						graph::ABBType ty = graph::ABBType::computation;
						if (isa<CallBase>(bb.front()) && !is_call_to_intrinsic(bb.front())) {
							ty = graph::ABBType::call;
						}
						auto abb = add_abb(ss.str(), ty, &bb, &bb, function, bb_counter == 0, source_loc);
						abbs[&bb] = abb;

						bb_counter++;

						// connect already mapped successors and predecessors
						for (const BasicBlock* succ_b : successors(&bb)) {
							if (abbs.find(succ_b) != abbs.end()) {
								auto edge = boost::add_edge(abb, abbs[succ_b], g);
								cfg.etype[edge.first] = static_cast<int>(graph::CFType::lcf);
							}
						}
						for (const BasicBlock* pred_b : predecessors(&bb)) {
							if (abbs.find(pred_b) != abbs.end()) {
								auto edge = boost::add_edge(abbs[pred_b], abb, g);
								cfg.etype[edge.first] = static_cast<int>(graph::CFType::lcf);
							}
						}
					}
					if (bb_counter == 0) {
						add_abb("empty", graph::ABBType::not_implemented, nullptr, nullptr, function, true, source_loc);
						cfg.implemented[function] = false;
					}
				}

				logger.info() << "Mapped " << name_counter << " ABBs." << std::endl;
			}
		};
	} // namespace

	void LLVMMap::init_options() {
		llvm_dump = llvm_dump_template.instantiate(get_name());
		llvm_dump_prefix = llvm_dump_prefix_template.instantiate(get_name());
		source_loc = source_loc_template.instantiate(get_name());
		opts.emplace_back(llvm_dump);
		opts.emplace_back(llvm_dump_prefix);
		opts.emplace_back(source_loc);
	}

	Step::OptionVec LLVMMap::get_local_options() {
		return {llvm_dump_template, llvm_dump_prefix_template, source_loc_template};
	}

	std::string LLVMMap::get_description() {
		return "Map llvm::Basicblock and ara::graph::ABB"
		       "\n"
		       "Maps in a one to one mapping.";
	}

	void LLVMMap::run() {
		const auto& dopt = llvm_dump.get();
		std::string prefix;
		const auto& prefix_opt = llvm_dump_prefix.get();
		assert(prefix_opt);

		const auto& s_loc = source_loc.get();

		graph::GraphData& graph_data = graph.get_graph_data();
		graph::CFG cfg = graph.get_cfg();
		graph_tool::gt_dispatch<>()(
		    [&](auto& g) { LLVMMapImpl(g, cfg, graph_data, logger, dopt && *dopt, *prefix_opt, *s_loc); },
		    graph_tool::always_directed())(cfg.graph.get_graph_view());

		if (*dump.get()) {
			std::string uuid = step_manager.get_execution_id();
			std::string dot_file = *dump_prefix.get() + uuid + ".dot";

			llvm::json::Value printer_conf(llvm::json::Object{
			    {"name", "Printer"}, {"dot", dot_file}, {"graph_name", "LLVM CFG"}, {"subgraph", "abbs"}});

			step_manager.chain_step(printer_conf);
		}
	}
} // namespace ara::step
