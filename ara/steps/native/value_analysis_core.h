// vim: set noet ts=4 sw=4:

#pragma once

#include "arguments.h"
#include "option.h"
#include "step.h"

#include <Graphs/SVFG.h>
#include <Graphs/VFGNode.h>
#include <Util/BasicTypes.h>
#include <WPA/Andersen.h>
#include <cxxabi.h>
#include <graph.h>

using namespace SVF;

namespace ara::step {
	class ValueAnalysisCore : public EntryPointStep<ValueAnalysisCore> {
	  private:
		using EntryPointStep<ValueAnalysisCore>::EntryPointStep;

		const static inline option::TOption<option::Bool> dump_stats_template{
		    "dump_stats", "Export JSON statistics about the value-analysis depth."};
		option::TOptEntity<option::Bool> dump_stats;

		virtual void init_options() override;

		/**
		 * demangle a string, for example:
		 * _ZN11MutexLockerC2EP15QueueDefinition to MutexLocker::MutexLocker(QueueDefinition*)
		 */
		std::string demangle(std::string name) {
			int status = -1;
			std::unique_ptr<char, void (*)(void*)> res{abi::__cxa_demangle(name.c_str(), NULL, NULL, &status),
			                                           std::free};
			return (status == 0) ? res.get() : name;
		}

		/* a list of values and their (hopefully) corresponding paths along which they are retrieved */
		typedef std::tuple<std::vector<const Constant*>, std::vector<std::vector<const Instruction*>>> ValPath;

		const llvm::Value* temp_traverse(const SVFGNode* node, const SVFG& vfg, std::vector<const SVFGNode*>& visited);
		std::vector<const SVFGNode*> vstd;

		const llvm::Constant* handle_value(const llvm::Value* value, const SVFG& vfg, const VFGNode* node);
		ValPath retrieve_value(const SVFG& vfg, const llvm::Value& value);
		std::vector<ValPath> collectUsesOnVFG(const SVFG& vfg, const llvm::CallBase& call);

		/**
		 * given a function, find its corresponding callgraph node and iterate over
		 * its parents up to the respective root, saving each list of functions
		 * in <curPath> first, and adding it to <paths> when a root node is reached
		 *
		 * this should just be bottom-up DFS
		 */
		void getCallPaths(const Function* f, std::vector<std::vector<const Instruction*>>& paths,
		                  std::vector<const Instruction*>& curPath) {
			SVF::PAG* pag = SVF::PAG::getPAG();
			// this is actually a singleton, so the creation was done in SVFAnalyses
			SVF::Andersen* ander = SVF::AndersenWaveDiff::createAndersenWaveDiff(pag);
			SVF::PTACallGraph* callgraph = ander->getPTACallGraph();
			// TODO check out icfg->getCallBlockNode(inst) which directly gets the callblocknode
			// callee is getCallee(inst), caller is svfModule->getSVFFunction(f)
			if (const SVFFunction* sf = LLVMModuleSet::getLLVMModuleSet()->getSVFFunction(f)) {
				PTACallGraphNode* cgn = callgraph->getCallGraphNode(sf);
				/* check if further path exists */
				if (cgn->hasIncomingEdge()) {
					/* incoming edges of this node */
					for (auto edgit = cgn->InEdgeBegin(); edgit != cgn->InEdgeEnd(); ++edgit) {
						PTACallGraphEdge* edg = *edgit;
						PTACallGraphEdge::CallInstSet cis = edg->getDirectCalls();
						for (const CallBlockNode* cbn : cis) {
							const Function* cf = cbn->getCallSite()->getFunction();
							const Instruction* ci = cbn->getCallSite();
							curPath.push_back(ci);
							getCallPaths(cf, paths, curPath);
							/**
							 * when the recursion above finishes, we have reached a root node
							 * therefore we go back (down) one node and check its other parents
							 */
							curPath.pop_back();
						}
					}
				}
				/* end of this callpath reached */
				else {
					paths.push_back(curPath);
				}
			}
		}

		template <typename Graph>
		void get_values(Graph& g, const SVFG& vfg) {
			graph::CFG cfg = graph.get_cfg();
			// ptree stats;
			for (auto abb :
			     boost::make_iterator_range(boost::vertices(cfg.filter_by_abb(g, graph::ABBType::syscall)))) {
				llvm::BasicBlock* bb = cfg.get_entry_bb<Graph>(abb);
				llvm::CallBase* called_func = llvm::dyn_cast<llvm::CallBase>(&bb->front());
				// logger.debug() << "call base aka instruction: " << *called_func << std::endl;
				if (called_func) {
					vstd.clear();
					Arguments args;
					llvm::AttributeSet attrs;
					llvm::Function* func = called_func->getCalledFunction();
					if (func) {
						// this->logger.debug() << *bb << std::endl;
						// this->logger.debug() << "Called function: " << *called_func << std::endl;
						this->logger.debug()
						    << "Function name: \033[34m" << func->getName().str() << "\033[0m" << std::endl;
						this->logger.debug() << "Number of args: " << func->arg_size() << std::endl;
						this->logger.debug() << "------------" << std::endl;
						// llvm::AttributeSet attrs = func->getAttributes().getFnAttributes();
						llvm::AttributeList attrl = called_func->getAttributes();
						for (unsigned it = attrl.index_begin(); it != attrl.index_end(); ++it) {
							// index is sometimes negative (2**32 - 1 or something)??
							// logger.debug() << it << ": " << attrl.getAsString(it) << std::endl;
						}

						const llvm::ConstantTokenNone* token = llvm::ConstantTokenNone::get(called_func->getContext());
						const llvm::Constant* none_c = llvm::dyn_cast<llvm::Constant>(token);

						std::vector<ValPath> vps = collectUsesOnVFG(vfg, *called_func);
						int t = 0;
						for (auto vp : vps) {
							attrs = attrl.getAttributes(t + 1);
							if (std::get<0>(vp).size() != std::get<1>(vp).size()) {
								logger.debug() << "===Number of Values: " << std::get<0>(vp).size() << std::endl;
								logger.debug() << "===Number of Paths:  " << std::get<1>(vp).size() << std::endl;
							}
							if (std::get<0>(vp).size() < 1) {
								logger.debug() << "no vals" << std::endl;
								continue;
							}

							/**
							 * for unambiguous values:
							 * 	- push back an Argument with just the one value and no alternatives/paths
							 */
							if (std::get<0>(vp).size() == 1) {
								const llvm::Value* constVal = std::get<0>(vp).at(0);
								if (const Function* func = llvm::dyn_cast<llvm::Function>(constVal)) {
									logger.debug()
									    << "value is function: " << demangle(func->getName().str()) << std::endl;
								} else {
									logger.debug() << "unambiguous value: " << *constVal << std::endl;
								}
								args.push_back(Argument(attrs, *constVal));
								continue;
							}

							Argument a(attrs, *none_c);

							/**
							 * i does not correspond to the index of the argument in the function
							 * it is just here for debugging purposes
							 */
							long unsigned int i = 0;
							/* we need paths >= values for this to work */
							assert(std::get<1>(vp).size() >= std::get<0>(vp).size());
							std::string entryFun;
							for (auto v : std::get<0>(vp)) {
								/* end iterator points behind the last element so we subtract 1 before dereferencing it
								 */
								entryFun = (*(std::get<1>(vp).at(i).end() - 1))->getFunction()->getName().str();

								/* erase the syscall itself from the instruction list */
								std::get<1>(vp).at(i).erase(std::get<1>(vp).at(i).begin());

								if (const Function* func = llvm::dyn_cast<llvm::Function>(v)) {
									logger.debug() << "Value (function) " << i << ": "
									               << demangle(func->getName().str()) << std::endl;
								} else {
									logger.debug() << "Value " << i << ": " << *v << std::endl;
								}
								logger.debug() << "PATH " << i << ": \n        |--";
								for (auto inst : std::get<1>(vp).at(i)) {
									logger.debug() << *inst << "\n        ---";
								}
								logger.debug() << "\033[33m" << demangle(entryFun) << "\033[0m|" << std::endl;

								a.add_variant(std::get<1>(vp).at(i), *v);
								i++;
							}
							/* print extra / leftover paths */
							if (i < std::get<1>(vp).size()) {
								logger.debug() << "\033[32mLEFTOVER PATHS (" << i << " to "
								               << std::get<1>(vp).size() - 1 << ")\033[0m" << std::endl;
								for (long unsigned int j = i; j < std::get<1>(vp).size(); j++) {
									std::get<1>(vp).at(j).erase(std::get<1>(vp).at(j).begin());
									logger.debug() << "PATH " << j << ": \n        |--";
									for (auto inst : std::get<1>(vp).at(j)) {
										logger.debug() << *inst << "\n        ---";
									}
									logger.debug() << "\033[33m" << demangle(entryFun) << "\033[0m|" << std::endl;
								}
							}

							args.set_entry_fun(entryFun);
							args.push_back(a);
							t++;
						}
					}
					/* return value */
					if (called_func->hasOneUse()) {
						const llvm::User* ur = called_func->user_back();
						llvm::Value* retval = ur->getOperand(1);
						logger.debug() << "return: " << *retval << std::endl;
						args.set_return_value(std::make_unique<Argument>(llvm::AttributeSet(), *retval));
					}

					// std::pair<Arguments, std::vector<std::vector<unsigned>>> args_pair = va.get_values(*called_func);
					// Arguments& args = args_pair.first;

					// // statistic printing
					// if (dump_stats) {
					// 	ptree arg_stats;
					// 	arg_stats.put("basic_block", bb->getName().str());
					// 	llvm::Function* func = called_func->getCalledFunction();
					// 	if (func) {
					// 		arg_stats.put("called_function", func->getName().str());
					// 	}
					// 	int i = 0;
					// 	for (auto& numbers : args_pair.second) {
					// 		std::stringstream ss;
					// 		ss << "argument " << i++;
					// 		ptree stat_list;
					// 		for (unsigned num : numbers) {
					// 			stat_list.push_back(std::make_pair("", ptree(std::to_string(num))));
					// 		}
					// 		arg_stats.add_child(ss.str(), stat_list);
					// 	}
					// 	std::string abb_name = cfg.name[abb];
					// 	stats.add_child(abb_name, arg_stats);
					// }

					cfg.arguments[abb] = boost::python::object(boost::python::handle<>(args.get_python_list()));
					this->logger.debug() << "Retrieved " << args.size() << " arguments for call " << *called_func
					                     << std::endl;
					this->logger.debug() << "================================================" << std::endl;
					std::cout << std::endl;
				} else {
					this->logger.warn() << "Something went wrong." << std::endl;
					this->logger.debug() << "In function: " << bb->getParent()->getName().str() << std::endl;
					this->logger.debug() << "Basicblock: " << *bb << std::endl;
				}
			}
			// if (dump_stats) {
			// 	json_parser::write_json(prefix + "value_analysis_statistics.json", stats);
			// }
		}

	  public:
		static std::string get_name() { return "ValueAnalysisCore"; }
		static std::string get_description();
		static Step::OptionVec get_local_options() { return {dump_stats_template}; }

		virtual llvm::json::Array get_configured_dependencies() override;
		virtual void run() override;
	};
} // namespace ara::step
