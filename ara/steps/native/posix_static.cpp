#include "posix_static.h"
#include "python_util.h"

#include "llvm/IR/Module.h"

#include <dictobject.h>
#include <functional>
#include <graph_filtering.hh>
#include <graph_selectors.hh>
#include <string>
#include <unordered_map>

namespace ara::step {
	namespace {
		template <typename Graph>
		class POSIXStaticImpl {
			using Vertex = typename boost::graph_traits<Graph>::vertex_descriptor;
			using Parser = std::function<void(const POSIXStaticImpl& context)>;

			Graph& g;
			graph::InstanceGraph& instances;
			Logger& logger;
			const llvm::Module& module;
            const llvm::DIVariable* info_node;
            llvm::GlobalVariable* global;

			static void add_instance(const POSIXStaticImpl& context, PyObject* obj) {
				const Vertex v = boost::add_vertex(context.g);
                context.instances.obj[v] = boost::python::object(boost::python::handle<>(boost::python::borrowed(obj)));
				context.instances.is_control[v] = false;

				// Extract file and line from the debug node if possible. Normally
				// those could be found in the cfg, but not in this case.
				if (context.info_node) {
					std::filesystem::path file = std::filesystem::path(context.info_node->getDirectory().str()) /
					                             std::filesystem::path(context.info_node->getFilename().str());
					context.instances.file[v] = file.string();
					context.instances.line[v] = context.info_node->getLine();
				}
			}

            static void parse_mutex(const POSIXStaticImpl& context) {
                PyObject* obj = py_dict({{"symbol", get_obj_from_value(safe_deref(context.global))},
                                         {"type", py_str("Mutex")},
                                         {"module", py_str("mutex")}});
                add_instance(context, obj);
            }

            static void parse_cond(const POSIXStaticImpl& context) {
                PyObject* obj = py_dict({{"symbol", get_obj_from_value(safe_deref(context.global))},
                                         {"type", py_str("ConditionVariable")},
                                         {"module", py_str("condition_variable")}});
                add_instance(context, obj);
            }

            static void parse_rwlock(const POSIXStaticImpl& context) {
                context.logger.warning() << "parse_rwlock() not implemented" << std::endl;
            }

            std::unordered_map<std::string, Parser> parsers {
			    {"pthread_mutex_t", parse_mutex},
                {"pthread_cond_t", parse_cond},
                {"pthread_rwlock_t", parse_rwlock},
			};

		  public:
			POSIXStaticImpl(Graph& g, graph::InstanceGraph& instances, Logger& logger, const llvm::Module& module)
                : g(g), instances(instances), logger(logger), module(module) {
                for (auto gl = module.global_begin(); gl != module.global_end(); gl++) {
                    global = const_cast<llvm::GlobalVariable*>(&*gl);
					if (!global->hasInitializer()) {
						continue;
					}

                    // extract type info in debug data
                    llvm::SmallVector<llvm::DIGlobalVariableExpression*, 1> dbg;
					global->getDebugInfo(dbg);
                    if (dbg.size() < 1) {
                        continue;
                    }
                    info_node = llvm::dyn_cast<llvm::DIVariable>(dbg[0]->getVariable());
                    if (info_node == nullptr || info_node->getType() == nullptr) {
                        continue;
                    }
                    const std::string type_info = info_node->getType()->getName().str();
                    logger.warning() << "type info: " << type_info << std::endl;

                    // only proceed if we detected a type that can be a static instance
                    auto parser = parsers.find(type_info);
					if (parser == parsers.end()) {
						continue;
					}

                    // Filter out global variables that not representing static instances
                    const llvm::Constant* initializer = global->getInitializer();
                    const llvm::StructType* init_type = llvm::dyn_cast_or_null<llvm::StructType>(initializer->getType());
                    // Detect static initializers: {{{0}}} overrides struct type name in LLVM initializer:
					if (init_type == nullptr || init_type->getStructName().str().length() == 0) {
						parser->second(*this);
					}
                }
            }
        };
	} // namespace

	std::string POSIXStatic::get_description() {
		return "Adds statically created instances of POSIX specific objects to the instance graph.";
	}

	void POSIXStatic::run() {
		graph::InstanceGraph instances = graph.get_instances();
		graph_tool::gt_dispatch<>()([&](auto& g) { POSIXStaticImpl(g, instances, logger, graph.get_module()); },
		                            graph_tool::always_directed())(instances.graph.get_graph_view());
	}

} // namespace
        