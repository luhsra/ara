#pragma once

#include "logging.h"

#include <Python.h>

namespace ara::step::tracer {

	class Entity {
		PyObject* ent;

	  public:
		Entity(PyObject* ent) : ent(ent) {}
		~Entity() { Py_XDECREF(ent); }
		PyObject* getPyObj() { return ent; }
	};

	class Tracer {
		PyObject* trace; // nullptr means that tracing is deactivated. In that case all calls does nothing.
		Logger& logger;

	  public:
		Tracer(PyObject* trace, Logger& logger)
		    : trace((trace && trace != Py_None) ? Py_NewRef(trace) : nullptr), logger(logger) {}
		~Tracer() { Py_XDECREF(trace); }
		Entity get_entity(std::string&& str);
	};
} // namespace ara::step::tracer
