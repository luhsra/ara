#pragma once

#include "Python.h"
#include "logging.h"

namespace ara::step::py_util {

	/**
	 * @brief Print an error message and quit the program if the condition cond is not true.
	 *
	 * 	Python Exceptions are shown in the terminal.
	 *  If you provide the error_with_obj obj then this function prints the python Type of this object.
	 *  (Only if cond is false)
	 *
	 * @param cond condition to check
	 * @param msg error msg
	 * @param logger logger to which the error should be printed
	 * @param error_with_obj this function prints the python Type of this argument on error. Optional.
	 */
	void py_assert(bool cond, const std::string&& msg, Logger& logger, const PyObject* error_with_obj = nullptr);

	/**
	 * @brief Aborts execution if a python error occured
	 * 
	 * @param display_msg display message on true
	 */
	void handle_py_error(bool display_msg = true);

} // namespace ara::step::py_util