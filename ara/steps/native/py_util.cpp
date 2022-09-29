#include "py_util.h"

namespace ara::step::py_util {

	void py_assert(bool cond, const std::string&& msg, Logger& logger, const PyObject* error_with_obj) {
		if (!cond) {
			logger.err() << std::flush;
			logger.err() << "py_assert: " << msg << std::endl;
			if (PyErr_Occurred())
				PyErr_Print();
			if (error_with_obj != nullptr) {
				PyTypeObject* type = error_with_obj->ob_type;
				const char* type_str = type->tp_name;
				logger.err() << "py_assert: the type of the object involved was: " << type_str << std::endl;
			}
			abort();
		}
	}

} // namespace ara::step::py_util