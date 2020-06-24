// vim: set noet ts=4 sw=4:

#pragma once

#include "option.h"
#include "step.h"

#include "arguments.h"

#include <graph.h>

#include <cxxabi.h>

#define VERSION_BKP VERSION
#undef VERSION
#include <MSSA/SVFG.h>
#include <Util/BasicTypes.h>
//#include <Util/VFGNode.h>
#include <Graphs/VFGNode.h>
//#include <MSSA/SVFG.h>
#include <Graphs/SVFG.h>
#include <WPA/Andersen.h>
#undef VERSION
#define VERSION VERSION_BKP
#undef VERSION_BKP

namespace ara::step {
	class ValueAnalysisCore : public EntryPointStep<ValueAnalysisCore> {
	  private:
		using EntryPointStep<ValueAnalysisCore>::EntryPointStep;

		const static inline option::TOption<option::Bool> dump_stats_template{
		    "dump_stats", "Export JSON statistics about the value-analysis depth."};
		option::TOptEntity<option::Bool> dump_stats;

		virtual void init_options() override;

		/*
		 * demangle a string, for example:
		 * _ZN11MutexLockerC2EP15QueueDefinition to MutexLocker::MutexLocker(QueueDefinition*)
		 */
		std::string demangle(std::string name) {
			int status = -1;
			std::unique_ptr<char, void(*)(void*)> res {abi::__cxa_demangle(name.c_str(), NULL, NULL, &status), std::free};
			return (status == 0) ? res.get() : name;
		}

		/* a list of values and their (hopefully) corresponding paths along which they are retrieved */
		typedef std::tuple<std::vector<const Constant*>, std::vector<std::vector<const Instruction*>>> ValPath;

		ValPath retrieve_value(const SVFG& vfg, const llvm::Value& value);
		std::vector<ValPath> collectUsesOnVFG(const SVFG& vfg, const llvm::CallBase& call);

		/*
		 * given a function, find its corresponding callgraph node and iterate over
		 * its parents up to the respective root, saving each list of functions
		 * in <curPath> first, and adding it to <paths> when a root node is reached
		 *
		 * this should just be bottom-up DFS
		 */
		void getCallPaths(const Function* f, std::vector<std::vector<const Instruction*>>& paths, std::vector<const Instruction*>& curPath) {
			if (const SVFFunction* sf = svfModule->getSVFFunction(f)) {
				PTACallGraphNode* cgn = callgraph->getCallGraphNode(sf);
				/* check if further path exists */
				if (cgn->hasIncomingEdge()) {
					/* incoming edges of this node */
					for (auto edgit = cgn->InEdgeBegin(); edgit != cgn->InEdgeEnd(); ++edgit) {
						PTACallGraphEdge* edg = *edgit;
						PTACallGraphEdge::CallInstSet cis = edg->getDirectCalls();
						for (const CallBlockNode* cbn : cis) {
							const Function* cf = cbn->getCallSite()->getFunction();
							const Instruction* ci = cbn->getCallSite().getInstruction();
							curPath.push_back(ci);
							getCallPaths(cf, paths, curPath);
							/* when the recursion above finishes, we have reached a root node
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

		PTACallGraph* callgraph;
		SVFModule* svfModule;

		template <typename Graph>
		void get_values(Graph& g, const SVFG& vfg) {
			cfg = graph->get_cfg();
			// ptree stats;
			for (auto abb :
			     boost::make_iterator_range(boost::vertices(filter_by_abb(graph::ABBType::syscall, g, cfg)))) {
				llvm::BasicBlock* bb = reinterpret_cast<llvm::BasicBlock*>(cfg.entry_bb[abb]);
				llvm::CallBase* called_func = llvm::dyn_cast<llvm::CallBase>(&bb->front());
				//logger.debug() << "call base aka instruction: " << *called_func << std::endl;
				if (called_func) {
					//Arguments args;
					llvm::Function* func = called_func->getCalledFunction();
					if (func) {
						//this->logger.debug() << *bb << std::endl;
						//this->logger.debug() << "Called function: " << *called_func << std::endl;
						this->logger.debug() << "Function name: \033[34m" << func->getName().str() << "\033[0m" << std::endl;
						this->logger.debug() << "Number of args: " << func->arg_size() << std::endl;
						this->logger.debug() << "------------" << std::endl;
						// attributes
						llvm::AttributeSet attrs = func->getAttributes().getFnAttributes();
						// return value (probably wrong)
						if (llvm::Value* v = llvm::dyn_cast<llvm::Value>(func)) {
							//this->logger.debug() << "Return: " << *v << std::endl;
						}

						// TODO get Instructions instead of Functions
						std::vector<ValPath> vps = collectUsesOnVFG(vfg, *called_func);
						for (auto vp : vps) {
							/* i does not correspond to the index of the argument in the function 
							 * it is just here for debugging purposes
							 */
							int i=0, j=0;
							for (auto v : std::get<0>(vp)) {
								// temporary: uncomment to skip direct constants (values with empty paths) 
								// works with Function* version:
								//if (std::get<1>(vp).at(0).empty()) continue;
								// works with Instruction* version:
								//if (std::get<1>(vp).at(0).size() == 1) continue;
								if (const Function* func = llvm::dyn_cast<llvm::Function>(v)) {
									logger.debug() << "Value (function) " << i << ": " << demangle(func->getName().str()) << std::endl;
								}
								else {
									logger.debug() << "Value " << i << ": " << *v << std::endl;
								}
								i++;
							}
							for (auto p : std::get<1>(vp)) {
								if (p.size() <= 1) {
									//continue;
								}
								logger.debug() << "PATH " << j << ": \n        |--";
								std::string topLevFun;
								for (auto inst : p) {
									//topLevFun = demangle(inst->getFunction()->getName().str());
									//logger.debug() << *inst << "\033[33m(called by " << topLevFun << ")\033[0m" << "---";
									logger.debug() << *inst << "\n        ---";
								}
								logger.debug() <<  "|" << std::endl;
								/* end iterator points behind the last element so we subtract 1 before dereferencing it */
								logger.debug() << "Entry function is: \033[33m"
											   << (*(p.end() - 1))->getFunction()->getName().str()
											   << "\033[0m" << std::endl;
								j++;
							}
						}
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

					// cfg.arguments[abb] = boost::python::object(boost::python::handle<>(args.get_python_list()));
					this->logger.debug() << "Retrieved " // << args.size() << " arguments for call " << *called_func
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
