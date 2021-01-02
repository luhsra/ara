// vim: set noet ts=4 sw=4:

#include "zephyr_static.h"

#include "llvm/IR/Module.h"

#include <dictobject.h>
#include <filesystem>
#include <functional>
#include <graph_filtering.hh>
#include <graph_selectors.hh>
#include <object.h>
#include <pyllco.h>
#include <string>
#include <unordered_map>

namespace ara::step {

	namespace {
		template <typename Graph>
		class ZephyrStaticImpl {
		  private:
			using Vertex = typename boost::graph_traits<Graph>::vertex_descriptor;
			using Parser = std::function<Vertex(const ZephyrStaticImpl& context)>;

			struct ParserInfo {
				// If true, the parser only is used for globals that sit in a ".static." section.
				// This is true most of the time, but e.g. for sys_sem with userspace enabled it is
				// not.
				bool requires_section;
				Parser parser;
			};

			Graph& g;
			graph::InstanceGraph& instances;
			Logger& logger;
			const llvm::Module& module;
			graph::CFG& cfg;
			// Can't be const because it is used in get_obj_from_value()
			llvm::GlobalVariable* global;
			const llvm::Constant* initializer;
			const llvm::DIVariable* info_node;
			Vertex v;

			static unsigned index_of(const llvm::DIVariable* info, const llvm::StringRef& name) {
				const llvm::DICompositeType* type = llvm::dyn_cast<llvm::DICompositeType>(info->getType());
				assert(type != nullptr);

				unsigned idx = 0;
				for (const auto node : type->getElements()) {
					const llvm::DIDerivedType* elem = llvm::dyn_cast<llvm::DIDerivedType>(node);
					// Ignore every node that holds no info about derived types aka elements
					if (elem && elem->getName() == name) {
						return idx;
					}
					++idx;
				}

				// Name does not exist. Fail hard.
				assert(true);
				return 0;
			}

			static llvm::Constant* get_element_checked(const llvm::Constant& c, unsigned index,
			                                           const llvm::DIVariable* meta, const llvm::StringRef& name) {
				assert(meta == nullptr || (meta != nullptr && index == index_of(meta, name)));
				return c.getAggregateElement(index);
			}

			// Create a py dict from the given elements, this is a ref stealing
			// operation
			static PyObject* py_dict(std::initializer_list<std::pair<const char*, PyObject*>> elements) {
				PyObject* dict = PyDict_New();

				for (auto& element : elements) {
					PyDict_SetItemString(dict, element.first, element.second);
					Py_DecRef(element.second);
				}

				return dict;
			}

			static PyObject* py_int(const llvm::APInt& i) {
				if (i.isNegative()) {
					return Py_BuildValue("L", i.getSExtValue());
				} else {
					return Py_BuildValue("K", i.getZExtValue());
				}
			}

			static PyObject* py_int(unsigned long long i) { return Py_BuildValue("K", i); }

			static PyObject* py_str(const char* str) { return PyUnicode_FromString(str); }

			static PyObject* py_str(const llvm::StringRef& str) {
				// Since stringrefs allow slicing, their raw strings may not be null
				// terminated.
				return PyUnicode_FromStringAndSize(str.data(), str.size());
			}

			static PyObject* py_none() { Py_RETURN_NONE; }

			static Vertex add_instance(const ZephyrStaticImpl& context, std::string label, PyObject* obj,
			                           std::string id) {
				// assert(false);
				Vertex v = boost::add_vertex(context.g);
				context.instances.label[v] = label;
				context.instances.obj[v] = boost::python::object(boost::python::handle<>(boost::python::borrowed(obj)));
				context.instances.id[v] = id;
				context.instances.branch[v] = false;
				context.instances.loop[v] = false;
				context.instances.after_scheduler[v] = true;
				context.instances.unique[v] = true;

				// These two are meaningless in the context of static instances,
				// since they are globals and don't belong to any (a)bb.
				context.instances.soc[v] = 0;
				context.instances.llvm_soc[v] = 0;

				// Extract file and line from the debug node if possible. Normally
				// those could be found in the cfg, but not in this case.
				if (context.info_node) {
					std::filesystem::path file = std::filesystem::path(context.info_node->getDirectory().str()) /
					                             std::filesystem::path(context.info_node->getFilename().str());
					context.instances.file[v] = file.string();
					context.instances.line[v] = context.info_node->getLine();
				}
				context.instances.specialization_level[v] = std::string();
				return v;
			}

			static inline Parser default_parser(const std::string name) {
				return [&name](const ZephyrStaticImpl& context) {
					// context.instances.label[context.v] = name;
					PyObject* obj = py_dict({{"data", get_obj_from_value(safe_deref(context.global))}});
					return add_instance(context, name, obj, context.global->getName().str());
				};
			}

			static Vertex parse_thread(const ZephyrStaticImpl& context) {
				// TODO: Maybe evaluate support for named threads. These can only be
				// read out for static ones, the k_thread_create syscall does not
				// create named threads.

				// The global holding all the static data is of type "struct
				// _static_thread_data". However, since all syscalls expect a "struct
				// k_thread" one of those is created as well. It can be found
				// by its name "_k_thread_obj_<thread name>". The thread name can be deduced from
				// the name of the _static_thread_data which is called "_k_thread_data_<thread name>".
				llvm::GlobalValue* data = nullptr;
				llvm::StringRef thread_name = safe_deref(context.global).getName();
				if (thread_name.consume_front("_k_thread_data_")) {
					std::string obj_name = "_k_thread_obj_" + thread_name.str();
					data = context.module.getNamedValue(obj_name);
				}

				const llvm::ConstantInt* stack_size = llvm::dyn_cast<llvm::ConstantInt>(
				    get_element_checked(*context.initializer, 2, context.info_node, "init_stack_size"));
				llvm::Function& entry = safe_deref(llvm::dyn_cast<llvm::Function>(
				    get_element_checked(*context.initializer, 3, context.info_node, "init_entry")));
				const llvm::ConstantInt* priority = llvm::dyn_cast<llvm::ConstantInt>(
				    get_element_checked(*context.initializer, 7, context.info_node, "init_prio"));
				const llvm::ConstantInt* options = llvm::dyn_cast<llvm::ConstantInt>(
				    get_element_checked(*context.initializer, 8, context.info_node, "init_options"));
				const llvm::ConstantInt* delay = llvm::dyn_cast<llvm::ConstantInt>(
				    get_element_checked(*context.initializer, 9, context.info_node, "init_delay"));

				PyObject* obj = py_dict({
				    {"data", data ? get_obj_from_value(*data) : py_none()},
				    {"stack", py_none()},
				    {"stack_size", py_int(safe_deref(stack_size).getValue())},
				    {"entry", get_obj_from_value(entry)},
				    {"entry_name", py_str(entry.getName())},
				    // The entry abb is stored as a graphtool.Vertex which seems to
				    // be reachable only from the python site.
				    // TODO: Find a way to do this in C++
				    {"entry_abb", py_none()},
				    {"entry_params", py_none()},
				    {"priority", py_int(safe_deref(priority).getValue())},
				    {"options", py_int(safe_deref(options).getValue())},
				    {"delay", py_int(safe_deref(delay).getValue())},
				});

				return add_instance(context, "Thread", obj, thread_name.str());
			}

			static Vertex parse_semaphore(const ZephyrStaticImpl& context) {
				// Zephyr actually enforces that these two are int constants
				const llvm::ConstantInt* count = llvm::dyn_cast<llvm::ConstantInt>(
				    get_element_checked(*context.initializer, 1, context.info_node, "count"));
				const llvm::ConstantInt* limit = llvm::dyn_cast<llvm::ConstantInt>(
				    get_element_checked(*context.initializer, 2, context.info_node, "limit"));
				PyObject* obj = py_dict({{"data", get_obj_from_value(safe_deref(context.global))},
				                         {"count", py_int(safe_deref(count).getValue())},
				                         {"limit", py_int(safe_deref(limit).getValue())}});

				return add_instance(context, "Semaphore", obj, safe_deref(context.global).getName().str());
			}

			static Vertex parse_stack(const ZephyrStaticImpl& context) {
				// The max size of the stack is not explicitly given by a member of
				// k_stack. We can inferr it from the size of the statically allocated
				// buffer that k_stack.base points to.
				const llvm::ConstantExpr* buf_init = llvm::dyn_cast<llvm::ConstantExpr>(
				    get_element_checked(*context.initializer, 2, context.info_node, "base"));
				llvm::PointerType* buf_ptr =
				    llvm::dyn_cast<llvm::PointerType>(safe_deref(safe_deref(buf_init).getOperand(0)).getType());
				assert(buf_ptr);
				llvm::ArrayType* buf = llvm::dyn_cast<llvm::ArrayType>(safe_deref(buf_ptr).getElementType());

				PyObject* obj = py_dict({{"data", get_obj_from_value(safe_deref(context.global))},
				                         {"buf", py_none()},
				                         {"max_entries", py_int(safe_deref(buf).getNumElements())}});
				return add_instance(context, "Stack", obj, safe_deref(context.global).getName().str());
			}

			static Vertex parse_pipe(const ZephyrStaticImpl& context) {
				const llvm::ConstantInt* size = llvm::dyn_cast<llvm::ConstantInt>(
				    get_element_checked(*context.initializer, 1, context.info_node, "size"));

				PyObject* obj = py_dict({{"data", get_obj_from_value(safe_deref(context.global))},
				                         {"size", py_int(safe_deref(size).getValue())}});
				return add_instance(context, "Pipe", obj, safe_deref(context.global).getName().str());
			}

			static PyObject* parse_(const ZephyrStaticImpl& context) {
				context.instances.label[context.v] = "";
				return py_dict({{"", py_none()}});
			}

			std::unordered_map<std::string, ParserInfo> parsers{
			    {"_static_thread_data", {true, parse_thread}},
			    {"k_sem", {true, parse_semaphore}},
			    {"k_mutex", {true, default_parser("Mutex")}},
			    {"k_queue", {true, default_parser("Queue")}},
			    {"k_lifo", {true, default_parser("Queue")}},
			    {"k_fifo", {true, default_parser("Queue")}},
			    {"k_stack", {true, parse_stack}},
			    {"k_pipe", {true, parse_pipe}},
			};

		  public:
			ZephyrStaticImpl(Graph& g, graph::InstanceGraph& instances, Logger& logger, const llvm::Module& module,
			                 graph::CFG& cfg)
			    : g(g), instances(instances), logger(logger), module(module), cfg(cfg) {
				for (auto gl = module.global_begin(); gl != module.global_end(); gl++) {
					global = const_cast<llvm::GlobalVariable*>(&*gl);
					llvm::StringRef section = global->getSection();

					initializer = global->getInitializer();
					if (initializer->isZeroValue() && section.empty()) {
						// Ignore globals without a section if they are zero initialized.
						// This is to avoid false positives since this step would detect all
						// declarations of dynamically initialized instances as well.
						// Skipping should be fine in allmost all cases.
						continue;
					}

					// If possible, extract debug information about the current
					// aggregate type.
					llvm::SmallVector<llvm::DIGlobalVariableExpression*, 1> dbg;
					global->getDebugInfo(dbg);

					info_node = dbg.size() > 0 ? llvm::dyn_cast<llvm::DIVariable>(dbg[0]->getVariable()) : nullptr;
					llvm::StructType* type = llvm::dyn_cast_or_null<llvm::StructType>(initializer->getType());

					if (type == nullptr) {
						// No struct type, skipping this one
						continue;
					}
					llvm::StringRef type_name = type->getStructName();
					assert(type_name.consume_front("struct."));
					auto parser = parsers.find(type_name.str());
					if (parser == parsers.end()) {
						logger.warning() << "Unknown zephyr type, skipping " << type_name;
						continue;
					}
					if ((parser->second.requires_section && !section.empty()) || !parser->second.requires_section) {
						logger.debug() << "Analyzing " << type_name << std::endl;
						parser->second.parser(*this);
					}
				}
			}
		};
	} // namespace

	std::string ZephyrStatic::get_description() {
		return "Adds statically created instances of zephyr specific objects to the instance graph.";
	}

	void ZephyrStatic::run() {
		graph::InstanceGraph instances = graph.get_instances();
		graph::CFG cfg = graph.get_cfg();
		graph_tool::gt_dispatch<>()([&](auto& g) { ZephyrStaticImpl(g, instances, logger, graph.get_module(), cfg); },
		                            graph_tool::always_directed())(instances.graph.get_graph_view());
	}
} // namespace ara::step
