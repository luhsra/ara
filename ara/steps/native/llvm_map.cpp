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

			Vertex add_bb(std::string name, graph::ABBType type, const BasicBlock* llvm_bb, Vertex function,
			              bool is_entry, const std::string& source_loc) {
				auto bb = boost::add_vertex(g);
				cfg.name[bb] = name;
				cfg.type[bb] = static_cast<int>(type);
				cfg.llvm_link[bb] = reinterpret_cast<intptr_t>(llvm_bb);
				cfg.level[bb] = static_cast<int>(graph::NodeLevel::bb);

				if (llvm_bb != nullptr &&
				    (source_loc == "all" || (source_loc == "calls" && type == graph::ABBType::call))) {
					try {
						for (const auto& inst : *llvm_bb) {
							auto [file, line] = get_source_location(inst);
							cfg.files[bb].emplace_back(file.string());
							cfg.lines[bb].emplace_back(line);
						}
					} catch (const LLVMError&) {
						logger.warn() << "Debug location unknown, while requested: " << llvm_bb->front() << std::endl;
					}
				}

				auto f2b_edge = boost::add_edge(function, bb, g);
				cfg.etype[f2b_edge.first] = static_cast<int>(graph::CFType::f2b);

				cfg.is_entry[f2b_edge.first] = is_entry;

				// attributes from LLVM analyses
				auto& map = graph_data.basic_blocks;
				cfg.is_exit[bb] = (map.find(llvm_bb) != map.end()) ? map.at(llvm_bb).is_exit_block : false;
				if (type == graph::ABBType::not_implemented) {
					// not implemented fake bbs are always exists
					cfg.is_exit[bb] = true;
				}
				cfg.is_exit_loop_head[bb] =
				    (map.find(llvm_bb) != map.end()) ? map.at(llvm_bb).is_exit_loop_head : false;
				cfg.part_of_loop[bb] = (map.find(llvm_bb) != map.end()) ? map.at(llvm_bb).is_part_of_loop : false;

				return bb;
			}

		  public:
			LLVMMapImpl(Graph& g, graph::CFG& cfg, graph::GraphData& graph_data, Logger& logger,
			            bool dump_llvm_functions, const std::string& prefix, const std::string& source_loc)
			    : g(g), cfg(cfg), graph_data(graph_data), logger(logger) {
				std::map<const BasicBlock*, Vertex> bbs;

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
					cfg.llvm_link[function] = reinterpret_cast<intptr_t>(&func);
					cfg.level[function] = static_cast<int>(graph::NodeLevel::function);

					logger.debug() << "Inserted new function " << cfg.name[function] << "." << std::endl;

					unsigned bb_counter = 0;
					for (BasicBlock& bb : func) {
						graph::ABBType ty = graph::ABBType::computation;
						if (isa<CallBase>(bb.front()) && !is_call_to_intrinsic(bb.front())) {
							ty = graph::ABBType::call;
						}
						auto bb_node = add_bb(bb.getName().str(), ty, &bb, function, bb_counter == 0, source_loc);
						bbs[&bb] = bb_node;

						bb_counter++;

						// connect already mapped successors and predecessors
						for (const BasicBlock* succ_b : successors(&bb)) {
							if (bbs.find(succ_b) != bbs.end()) {
								auto edge = boost::add_edge(bb_node, bbs[succ_b], g);
								cfg.etype[edge.first] = static_cast<int>(graph::CFType::lcf);
							}
						}
						for (const BasicBlock* pred_b : predecessors(&bb)) {
							if (pred_b != &bb && bbs.find(pred_b) != bbs.end()) {
								auto edge = boost::add_edge(bbs[pred_b], bb_node, g);
								cfg.etype[edge.first] = static_cast<int>(graph::CFType::lcf);
							}
						}
					}
					if (bb_counter == 0) {
						add_bb("empty", graph::ABBType::not_implemented, nullptr, function, true, source_loc);
						cfg.implemented[function] = false;
					}
				}

				logger.info() << "Mapped " << boost::num_vertices(g) << " nodes." << std::endl;
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
			std::string dot_file = *dump_prefix.get() + "dot";
			llvm::json::Value printer_conf(llvm::json::Object{
			    {"name", "Printer"}, {"dot", dot_file}, {"graph_name", "LLVM CFG"}, {"subgraph", "abbs"}});

			step_manager.chain_step(printer_conf);
		}
	}
} // namespace ara::step
