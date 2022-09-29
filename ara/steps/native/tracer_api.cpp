
#include "tracer_api.h"

#include "py_util.h"

namespace ara::step::tracer {

	Entity Tracer::get_entity(std::string&& str) {
		if (!this->trace) {
			return Entity(nullptr);
		}

		PyObject* method = PyObject_GetAttrString(this->trace, "get_entity");
		py_util::py_assert(method, "Could not get function object of trace", logger, this->trace);
		py_util::py_assert(PyMethod_Check(method), "trace.get_entity is not a python function!", logger, method);

		PyObject* name = Py_BuildValue("s", str.c_str());
		py_util::py_assert(name, "Error building Python String", logger);

		PyObject* entity = PyObject_CallOneArg(method, name);
		py_util::py_assert(entity, "Error in trace.get_entity() function", logger, name);

		Py_DECREF(method);
		Py_DECREF(name);
		return Entity(entity);
	}

} // namespace ara::step::tracer