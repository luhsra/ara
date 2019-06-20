// vim: set noet ts=4 sw=4:

#include "DetectInteractions.h"

#include "llvm/ADT/APFloat.h"
#include "llvm/Analysis/AliasAnalysis.h"
#include "llvm/Analysis/AssumptionCache.h"
#include "llvm/Analysis/DependenceAnalysis.h"
#include "llvm/Analysis/LoopInfo.h"
#include "llvm/Analysis/MemoryDependenceAnalysis.h"
#include "llvm/Analysis/ScalarEvolution.h"
#include "llvm/IR/CFG.h"
#include "llvm/IR/LegacyPassManagers.h"
#include "llvm/IR/Use.h"
#include "llvm/Pass.h"
#include "llvm/PassAnalysisSupport.h"

#include <cassert>
#include <fstream>
#include <functional>
#include <iostream>
#include <limits.h>
#include <stdexcept>
#include <string>
#include <vector>
using namespace llvm;
using namespace OS;

// print the argument
void debug_argument_test(std::any value) {

	std::size_t const tmp = value.type().hash_code();
	const std::size_t tmp_int = typeid(int).hash_code();
	const std::size_t tmp_double = typeid(double).hash_code();
	const std::size_t tmp_string = typeid(std::string).hash_code();
	const std::size_t tmp_long = typeid(long).hash_code();
	std::cerr << "Argument: ";

	if (tmp_int == tmp) {
		std::cerr << std::any_cast<int>(value) << '\n';
	} else if (tmp_double == tmp) {
		std::cerr << std::any_cast<double>(value) << '\n';
	} else if (tmp_string == tmp) {
		std::cerr << std::any_cast<std::string>(value) << '\n';
	} else if (tmp_long == tmp) {
		std::cerr << std::any_cast<long>(value) << '\n';
	} else {
		std::cerr << "[warning: cast not possible] type: " << value.type().name() << '\n';
	}
}

/**
 * @brief split a string at delimeter string
 * @param stringToBeSplitted string to splitt
 * @param delimeter delemiter to splitt
 */
std::vector<std::string> split(std::string stringToBeSplitted, std::string delimeter) {
	std::vector<std::string> splittedString;
	int startIndex = 0;
	int endIndex = 0;
	// std::cerr << "start handler name " << stringToBeSplitted << std::endl;
	while ((endIndex = stringToBeSplitted.find(delimeter, startIndex)) < stringToBeSplitted.size()) {
		std::string val = stringToBeSplitted.substr(startIndex, endIndex - startIndex);
		// std::cerr << "handler name " << val << std::endl;
		splittedString.push_back(val);
		startIndex = endIndex + delimeter.size();
	}
	if (startIndex < stringToBeSplitted.size()) {
		std::string val = stringToBeSplitted.substr(startIndex);
		// std::cerr << "handler name " << val << std::endl;
		splittedString.push_back(val);
	}
	return splittedString;
}

/**
 * @brief cast specific generic api calls to their corresponding individual name
 * @param call call data contianer with arguments
 * @param abb abb which contains a syscall
 */
void convert_syscall_name(call_data call, shared_abb abb) {

	if (call.call_name.find("xTimerGenericCommand") != std::string::npos) {

		std::string call_name;
		auto any_value = call.arguments.at(1).any_list.front();
		if (any_value.type().hash_code() == typeid(long).hash_code()) {

			auto command_id = std::any_cast<long>(any_value);

			switch (command_id) {

			/*
			#define tmrCOMMAND_EXECUTE_CALLBACK_FROM_ISR 	( ( BaseType_t ) -2 )
			#define tmrCOMMAND_EXECUTE_CALLBACK				( ( BaseType_t ) -1 )
			#define tmrCOMMAND_START_DONT_TRACE				( ( BaseType_t ) 0 )
			#define tmrCOMMAND_START					    ( ( BaseType_t ) 1 )
			#define tmrCOMMAND_RESET						( ( BaseType_t ) 2 )
			#define tmrCOMMAND_STOP							( ( BaseType_t ) 3 )
			#define tmrCOMMAND_CHANGE_PERIOD				( ( BaseType_t ) 4 )
			#define tmrCOMMAND_DELETE						( ( BaseType_t ) 5 )
			#define tmrCOMMAND_START_FROM_ISR				( ( BaseType_t ) 6 )
			#define tmrCOMMAND_RESET_FROM_ISR				( ( BaseType_t ) 7 )
			#define tmrCOMMAND_STOP_FROM_ISR				( ( BaseType_t ) 8 )
			#define tmrCOMMAND_CHANGE_PERIOD_FROM_ISR		( ( BaseType_t ) 9 )
			*/
			case -2:
				call_name = "tmrCOMMAND_EXECUTE_CALLBACK_FROM_ISR";
				break;
			case -1:
				call_name = "tmrCOMMAND_EXECUTE_CALLBACK";
				break;
			case 0:
				call_name = "tmrCOMMAND_START_DONT_TRACE";
				break;
			case 1:
				call_name = "tmrCOMMAND_START";
				break;
			case 2:
				call_name = "tmrCOMMAND_RESET";
				break;
			case 3:
				call_name = "tmrCOMMAND_STOP";
				break;
			case 4:
				call_name = "tmrCOMMAND_CHANGE_PERIOD";
				break;
			case 5:
				call_name = "tmrCOMMAND_DELETE";
				break;
			case 6:
				call_name = "tmrCOMMAND_START_FROM_ISR";
				break;
			case 7:
				call_name = "tmrCOMMAND_RESET_FROM_ISR";
				break;
			case 8:
				call_name = "tmrCOMMAND_STOP_FROM_ISR";
				break;
			case 9:
				call_name = "tmrCOMMAND_CHANGE_PERIOD_FROM_ISR";
				break;
			default:
				call_name = call.call_name;
				break;
			}
			abb->set_syscall_name(call_name);
			call.call_name = call_name;
		}
	} else if (call.call_name.find("xTaskGenericNotify") != std::string::npos) {

		std::string call_name;
		auto any_value = call.arguments.at(2).any_list.front();
		if (any_value.type().hash_code() == typeid(long).hash_code()) {

			auto command_id = std::any_cast<long>(any_value);

			switch (command_id) {
			/*
			eNoAction = 0,				Notify the task without updating its notify value.
			eSetBits,					Set bits in the task's notification value.
			eIncrement,				    Increment the task's notification value.
			eSetValueWithOverwrite,		Set the task's notification value to a specific value even if the previous value
			has not yet been read by the task. eSetValueWithoutOverwrite
			*/
			case 0:
				call_name = "xTaskNotifyNoAction";
				break;
			case 1:
				call_name = "xTaskNotifySetBits";
				break;
			case 2:
				call_name = "xTaskNotifyIncrement";
				break;
			case 3:
				call_name = "xTaskNotifySetValueWithOverwrite";
				break;
			case 4:
				call_name = "xTaskNotifySetValueWithoutOverwrite";
				break;
			default:
				call_name = call.call_name;
				break;
			}
			abb->set_syscall_name(call_name);
			call.call_name = call_name;
		}
	}
}

/**
 * @brief detect if in osek the scheduler is addressed as resource,  and create this resource if not already in graph
 * and addressed
 * @param graph project data structure
 * @param abb which contains the syscall
 * @param already_visited call instructions which were already iterated
 */
void osek_scheduler_resource(graph::Graph& graph, shared_abb abb,
                             std::vector<llvm::Instruction*>* already_visited_calls) {

	if (graph.get_os_type() != OSEK)
		return;

	std::hash<std::string> hash_fn;

	std::string scheduler_resource_name = "RES_SCHEDULER";

	// check if scheduler exists as resource in graph
	if (graph.get_vertex(hash_fn(scheduler_resource_name + typeid(OS::Mutex).name())) != nullptr)
		return;

	if (abb->get_syscall_type() == receive) {
		// iterate about the possible refereneced(syscall targets) abstraction types
		for (auto& target : *abb->get_call_target_instances()) {
			// the RTOS has the handler name RTOS
			if (target == typeid(OS::Mutex).hash_code()) {

				// get the call specific arguments
				auto arguments = abb->get_syscall_arguments();
				auto syscall_reference = abb->get_syscall_instruction_reference();
				auto specific_arguments = get_syscall_relative_arguments(&arguments, already_visited_calls,
				                                                         syscall_reference, abb->get_syscall_name());

				// cast argument to string and check if internal scheduler is addressed as a resource
				auto any_value = specific_arguments.arguments.at(0).any_list.front();
				std::string addressed_resource = std::any_cast<std::string>(any_value);
				if (addressed_resource == scheduler_resource_name) {
					// create the resource and store it in the graph
					auto resource = std::make_shared<OS::Mutex>(&graph, scheduler_resource_name);

					resource->set_handler_name(scheduler_resource_name);
					resource->set_start_scheduler_creation_flag(after);
					resource->set_resource_type(binary_mutex);
					graph.set_vertex(resource);
				}
			}
		}
	}
}

/**
 * @brief detect interactions of OS abstractions and create the corresponding edges in the graph
 * @param graph project data structure
 * @param start_vertex abstraction instance which is iterated
 * @param function current function of abstraction instance
 * @param call_reference function call instruction
 * @param already_visited call instructions which were already iterated
 * @param warning_list list to store warning
 */
void iterate_called_functions_interactions(graph::Graph& graph, graph::shared_vertex start_vertex,
                                           OS::shared_function function, llvm::Instruction* call_reference,
                                           std::vector<llvm::Instruction*> already_visited_calls,
                                           std::vector<llvm::Instruction*>* calltree_references,
                                           std::vector<shared_warning>* warning_list) {

	// return if function does not contain a syscall
	if (function == nullptr || function->has_syscall() == false)
		return;

	// search hash value in list of already visited basic blocks
	for (auto tmp_call : already_visited_calls) {
		if (call_reference == tmp_call) {
			// basic block already visited
			return;
		}
	}
	if (call_reference != nullptr) {
		calltree_references->emplace_back(call_reference);
		already_visited_calls.emplace_back(call_reference);
	}

	// get the abbs of the function
	std::list<OS::shared_abb> abb_list = function->get_atomic_basic_blocks();

	// iterate about the abbs
	for (auto& abb : abb_list) {

		// check if abb contains a syscall and it is not a creational syscall
		if (abb->get_call_type() == sys_call && abb->get_syscall_type() != create) {

			// check if osek scheduler is addressd a resource and create this resource if necessary
			osek_scheduler_resource(graph, abb, &already_visited_calls);

			bool success = false;

			std::vector<argument_data> argument_list = abb->get_syscall_arguments();
			std::list<std::size_t>* target_list = abb->get_call_target_instances();

			// load the handler names
			std::vector<std::string> handler_names;

			argument_data argument_candidats;

			bool default_handler = false;

			// get the handler name of the target instance
			if (abb->get_handler_argument_index() != 9999) {
				argument_candidats = (argument_list.at(abb->get_handler_argument_index()));
				if (argument_list.size() > 0 && argument_candidats.any_list.size() > 0) {

					auto any_argument = argument_candidats.any_list.front();
					llvm::Value* llvm_argument_reference = nullptr;
					if (argument_candidats.any_list.size() > 1) {

						// get the argument value regarding the current call tree path
						get_call_relative_argument(any_argument, llvm_argument_reference, argument_candidats,
						                           calltree_references);
					}

					if (any_argument.type().hash_code() == typeid(std::string).hash_code()) {

						std::string tmp_handler_names = std::any_cast<std::string>(any_argument);
						// check if the expected handler name occurs in the graph
						handler_names = split(tmp_handler_names, "(OR)");

					} else {
						// TODO
						// std::cerr << "handler argument is no string" << std::endl;
						// debug_argument_test(any_argument);
					}
				}
			}

			if (handler_names.empty())
				handler_names.emplace_back("RTOS");

			for (auto handler_name : handler_names) {
				bool handler_found = false;
				for (auto& vertex : graph.get_vertices()) {
					if (vertex->get_handler_name() == handler_name)
						handler_found = true;
				}

				if (!handler_found) {

					default_handler = true;
				}

				// iterate about the possible refereneced(syscall targets) abstraction types
				for (auto& target : *target_list) {

					// the RTOS has the handler name RTOS
					if (target == typeid(OS::RTOS).hash_code())
						handler_name = "RTOS";

					if (default_handler == true) {
						handler_name = "RTOS";
						target = typeid(OS::RTOS).hash_code();
					}

					// get the vertices of the specific type from the graph
					std::list<graph::shared_vertex> vertex_list = graph.get_type_vertices(target);

					// iterate about the vertices
					for (auto& target_vertex : vertex_list) {

						// compare the referenced handler name with the handler name of the vertex
						if (target_vertex->get_handler_name() == handler_name) {

							// get the vertex abstraction of the function, where the syscall is called
							if (start_vertex != nullptr && target_vertex != nullptr) {

								if ((abb->get_syscall_type() == delay || abb->get_syscall_type() == destroy) &&
								    target == typeid(OS::RTOS).hash_code()) {
									target_vertex = start_vertex;
								}
								// check if the syscall expect values from target or commits values to target
								if (abb->get_syscall_type() == receive || abb->get_syscall_type() == wait ||
								    abb->get_syscall_type() == take) {

									// create the edge, which contains the start and target vertex and the arguments
									auto edge = std::make_shared<graph::Edge>(&graph, abb->get_syscall_name(),
									                                          target_vertex, start_vertex, abb);

									// store the edge in the graph
									graph.set_edge(edge);

									target_vertex->set_outgoing_edge(edge);
									start_vertex->set_ingoing_edge(edge);
									edge->set_instruction_reference(abb->get_syscall_instruction_reference());
									// set the success flag
									success = true;

									// get the call specific arguments
									auto arguments = abb->get_syscall_arguments();
									auto syscall_reference = abb->get_syscall_instruction_reference();
									auto specific_arguments = get_syscall_relative_arguments(
									    &arguments, calltree_references, syscall_reference, abb->get_syscall_name());

									// check if syscall is a generic call, which can transformed to more generic one
									convert_syscall_name(specific_arguments, abb);
									edge->set_specific_call(&specific_arguments);

								} else { // syscall set values

									// create the edge, which contains the start and target vertex and the arguments
									auto edge = std::make_shared<graph::Edge>(&graph, abb->get_syscall_name(),
									                                          start_vertex, target_vertex, abb);

									// store the edge in the graph
									graph.set_edge(edge);

									start_vertex->set_outgoing_edge(edge);
									target_vertex->set_ingoing_edge(edge);
									edge->set_instruction_reference(abb->get_syscall_instruction_reference());
									// set the success flag
									success = true;

									// get the call specific arguments
									auto arguments = abb->get_syscall_arguments();
									auto syscall_reference = abb->get_syscall_instruction_reference();
									auto specific_arguments = get_syscall_relative_arguments(
									    &arguments, calltree_references, syscall_reference, abb->get_syscall_name());

									// check if syscall is a generic call, which can transformed to more generic one
									convert_syscall_name(specific_arguments, abb);
									edge->set_specific_call(&specific_arguments);
								}
							}
							break;
						}
					}
					// check if target vertex with corresponding handler name was detected
					if (success) {
						// break the loop iteration about the possible syscall target instances
						break;
					}
				}
				if (success == false) {
					// edge could not created, generate warning
					auto warning = std::make_shared<EdgeCreateWarning>(start_vertex, abb);
					warning_list->emplace_back(warning);
				}
			}
		} else if (abb->get_call_type() == func_call) {
			// iterate about the called function
			iterate_called_functions_interactions(graph, start_vertex, abb->get_called_function(),
			                                      abb->get_call_instruction_reference(), already_visited_calls,
			                                      calltree_references, warning_list);
		}
	}
}

/**
 * @brief detect interactions of OS abstractions and create the corresponding edges in the graph
 * @param graph project data structure
 * @param warning_list list to store warning
 */
void detect_interactions(graph::Graph& graph, std::vector<shared_warning>* warning_list) {

	// get main function from the graph
	std::string main_function_name = "main";
	std::hash<std::string> hash_fn;
	auto main_vertex = graph.get_vertex(hash_fn(main_function_name + typeid(OS::Function).name()));

	if (main_vertex == nullptr) {
		std::cerr << "ERROR, application contains no main function" << std::endl;
		abort();
	} else {
		auto main_function = std::dynamic_pointer_cast<OS::Function>(main_vertex);
		// get all interactions of the main functions and their called function with other os instances
		std::vector<llvm::Instruction*> already_visited;
		std::vector<llvm::Instruction*> calltree_references;
		iterate_called_functions_interactions(graph, main_function, main_function, nullptr, already_visited,
		                                      &calltree_references, warning_list);
	}

	// get all tasks, which are stored in the graph
	for (auto& task : graph.get_type_vertices<OS::Task>()) {
		std::vector<llvm::Instruction*> already_visited;
		std::vector<llvm::Instruction*> calltree_references;
		OS::shared_function task_definition = task->get_definition_function();
		// get all interactions of the instance
		iterate_called_functions_interactions(graph, task, task_definition, nullptr, already_visited,
		                                      &calltree_references, warning_list);
	}

	// get all isrs, which are stored in the graph
	for (auto& isr : graph.get_type_vertices<OS::ISR>()) {
		std::vector<llvm::Instruction*> already_visited;
		std::vector<llvm::Instruction*> calltree_references;
		OS::shared_function isr_definition = isr->get_definition_function();
		// get all interactions of the instance
		iterate_called_functions_interactions(graph, isr, isr_definition, nullptr, already_visited,
		                                      &calltree_references, warning_list);
	}

	// get all timers of the graph
	for (auto& timer : graph.get_type_vertices<OS::Timer>()) {
		std::vector<llvm::Instruction*> already_visited;
		std::vector<llvm::Instruction*> calltree_references;
		OS::shared_function timer_definition = timer->get_callback_function();
		// get all interactions of the instance
		iterate_called_functions_interactions(graph, timer, timer_definition, nullptr, already_visited,
		                                      &calltree_references, warning_list);
	}

	// get all hooks of the graph
	for (auto& hook : graph.get_type_vertices<OS::Hook>()) {
		std::vector<llvm::Instruction*> already_visited;
		std::vector<llvm::Instruction*> calltree_references;
		OS::shared_function hook_definition = hook->get_definition_function();
		// get all interactions of the instance
		iterate_called_functions_interactions(graph, hook, hook_definition, nullptr, already_visited,
		                                      &calltree_references, warning_list);
	}

	// get all coroutines of the graph
	for (auto& coroutine : graph.get_type_vertices<OS::CoRoutine>()) {
		std::vector<llvm::Instruction*> already_visited;
		std::vector<llvm::Instruction*> calltree_references;
		OS::shared_function coroutine_definition = coroutine->get_definition_function();
		// get all interactions of the instance
		iterate_called_functions_interactions(graph, coroutine, coroutine_definition, nullptr, already_visited,
		                                      &calltree_references, warning_list);
	}
}

/**
 * @brief add all instances to a queueset
 * @param graph project data structure
 * @param warning_list list to store warning
 */
void add_to_queue_set(graph::Graph& graph, std::vector<shared_warning>* warning_list) {

	// get all queuesets, which are stored in the graph
	for (auto& queueset : graph.get_type_vertices<OS::QueueSet>()) {

		auto ingoing_edges = queueset->get_ingoing_edges();

		// detect all calls that add a instance to qeueset
		for (auto ingoing : ingoing_edges) {

			if (ingoing->get_abb_reference()->get_syscall_type() == add) {

				auto call = ingoing->get_specific_call();

				// get element to set to queueset via the handlername from syscall
				if (call.arguments.front().multiple == false) {

					if (call.arguments.front().any_list.front().type().hash_code() == typeid(std::string).hash_code()) {

						std::string handler_name = std::any_cast<std::string>(call.arguments.front().any_list.front());

						std::hash<std::string> hash_fn;

						graph::shared_vertex queue_set_element = nullptr;

						queue_set_element = graph.get_vertex(hash_fn(handler_name + typeid(OS::Mutex).name()));
						if (queue_set_element == nullptr)
							queue_set_element = graph.get_vertex(hash_fn(handler_name + typeid(OS::Queue).name()));
						if (queue_set_element == nullptr)
							queue_set_element = graph.get_vertex(hash_fn(handler_name + typeid(OS::Semaphore).name()));

						// set element to queueset
						if (queue_set_element != nullptr)
							queueset->set_queue_element(queue_set_element);
						else {

							// Element to store in queueset could not found in graph
							auto warning = std::make_shared<QueueSetMemberWarning>(queueset, handler_name,
							                                                       ingoing->get_abb_reference());
							warning_list->emplace_back(warning);
						}
					}
				} else {
					std::cerr << "ERROR: edge contains multiple possible values" << std::endl;
					abort();
				}
			}
		}
	}
}

/**
 * @brief get the application mode of the start scheduler instruction in OSEK rtos. The appmode is the argument of the
 *system call.
 * @param graph project data structure
 * @param warning_list list to store warning
 **/
void get_osek_appmode(graph::Graph& graph, std::vector<shared_warning>* warning_list) {

	// check if rtos is a osek rtos
	if (graph.get_os_type() != OSEK)
		return;

	std::hash<std::string> hash_fn;

	// get function with name main from graph
	std::string start_function_name = "main";

	graph::shared_vertex main_vertex = graph.get_vertex(hash_fn(start_function_name + typeid(OS::Function).name()));

	OS::shared_function main_function;

	// check if graph contains main function
	if (main_vertex != nullptr) {
		std::vector<std::size_t> already_visited;
		main_function = std::dynamic_pointer_cast<OS::Function>(main_vertex);

	} else {
		std::cerr << "ERROR: no main function in programm" << std::endl;
		abort();
	}

	std::string rtos_name = "RTOS";

	// load the rtos graph instance
	auto rtos_vertex = graph.get_vertex(hash_fn(rtos_name + typeid(OS::RTOS).name()));

	if (rtos_vertex == nullptr) {
		std::cerr << "ERROR: RTOS could not load from graph" << std::endl;
		abort();
	}
	auto rtos = std::dynamic_pointer_cast<OS::RTOS>(rtos_vertex);

	std::string appmode = "";
	// get the start scheduler instruction from main function
	for (auto outgoing_edge : main_function->get_outgoing_edges()) {

		if (outgoing_edge->get_abb_reference()->get_syscall_type() == start_scheduler) {

			auto call_data = outgoing_edge->get_specific_call();
			// load the argument , appmode is the only argument
			if (call_data.arguments.size() != 1 || call_data.arguments.at(0).any_list.size() != 1) {
				abort();
			}
			// cast argument to string and check if multiple appmodes exists
			auto any_value = call_data.arguments.at(0).any_list.front();
			std::string tmp_appmode = std::any_cast<std::string>(any_value);

			if (appmode != "" && appmode != tmp_appmode) {
				abort();
			} else {
				appmode = tmp_appmode;
			}
		}
	}
	// store appmode in rtos
	if (appmode != "")
		rtos->appmode = appmode;
	else {
		// Appmodes are different or empty in application
		auto warning = std::make_shared<AppModeWarning>(nullptr);
		warning_list->emplace_back(warning);
	}
}

namespace step {

	std::string DetectInteractionsStep::get_name() { return "DetectInteractionsStep"; }

	std::string DetectInteractionsStep::get_description() {
		return "Extracts out of FreeRTOS abstraction instances. Iterates about the GCFG of each abstraktion instance "
		       "which is defined by functions. For each abb from type syscall a edge is generated from the start, "
		       "instance which contains the abb, to the target vertex, instance which is addressed by the syscall.";
	}

	/**
	 * @brief the run method of the DetectInteractionsStep pass. This pass detects all interactions of the instances via
	 * the RTOS.
	 * @param graph project data structure
	 */
	void DetectInteractionsStep::run(graph::Graph& graph) {

		std::cout << "Run DetectInteractionsStep" << std::endl;

		// detect interactions of the OS abstraction instances

		std::vector<shared_warning>* warning_list = &(this->warnings);

		detect_interactions(graph, warning_list);

		// freertos or osek specific interaction analysis
		add_to_queue_set(graph, warning_list);
		get_osek_appmode(graph, warning_list);
	}

	std::vector<std::string> DetectInteractionsStep::get_dependencies() {
		PyObject* elem = PyDict_GetItemString(config, "os");
		assert(PyUnicode_Check(elem));

		if (strcmp("freertos", PyUnicode_AsUTF8(elem)) == 0)
			return {"FreeRTOSInstancesStep"};
		else if (strcmp("osek", PyUnicode_AsUTF8(elem)) == 0)
			return {"OilStep"};
	}
} // namespace step
// RAII
