// SPDX-FileCopyrightText: 2022 Jan Neugebauer
//
// SPDX-License-Identifier: GPL-3.0-or-later

#include "tracer_api.h"

#include "py_util.h"
#include "step_pyx.h"

namespace ara::step::tracer {

	Entity::Entity(PyObject* ent)
	    : ent((ent && ent != Py_None) ? boost::python::object{boost::python::handle<>(ent)} : boost::python::object{}) {
	}

	Tracer::Tracer(PyObject* tracer, Logger& logger)
	    : tracer((tracer && tracer != Py_None)
	                 ? boost::python::object{boost::python::handle<>(boost::python::borrowed(tracer))}
	                 : boost::python::object{}),
	      logger(logger) {}

	GraphPath GraphPath::clone() {
		GraphPath g_path{this->type};
		if (!this->path.is_none()) {
			PyObject* new_path = py_copy_object(this->path.ptr());
			py_util::handle_py_error();
			g_path.path = boost::python::object{boost::python::handle<>(new_path)};
		}
		return g_path;
	}

	boost::python::object Tracer::get_vertex_by_id(const GraphNode& node) const {
		PyObject* vertex =
		    py_tracer_get_vertex_by_id(this->tracer.ptr(), node.get_node(), static_cast<int>(node.get_type()));
		py_util::handle_py_error();
		return boost::python::api::object{boost::python::handle<>(vertex)};
	}

	boost::python::object Tracer::add_edge_to_path(boost::python::object path, uint64_t source, uint64_t target,
	                                               graph::GraphType type) const {
		PyObject* edge =
		    py_tracer_add_edge_to_path(this->tracer.ptr(), path.ptr(), source, target, static_cast<int>(type));
		py_util::handle_py_error();
		return boost::python::api::object{boost::python::handle<>(edge)};
	}

	Entity Tracer::get_entity(const std::string& str) const {
		if (this->tracer.is_none()) {
			return Entity{nullptr};
		}

		PyObject* obj = py_tracer_get_entity(this->tracer.ptr(), const_cast<std::string&>(str));
		py_util::handle_py_error();
		return Entity{obj};
	}

	void Tracer::entity_on_node(const Entity& ent, const GraphNode& node) const {
		if (this->tracer.is_none()) {
			return;
		}

		boost::python::object vertex = this->get_vertex_by_id(node);
		py_tracer_entity_on_node(this->tracer.ptr(), ent.get_obj().ptr(), vertex.ptr(),
		                         static_cast<int>(node.get_type()));
		py_util::handle_py_error();
	}

	void Tracer::entity_is_looking_at(const Entity& ent, const GraphPath& path) const {
		if (this->tracer.is_none()) {
			return;
		}

		py_tracer_entity_is_looking_at(this->tracer.ptr(), ent.get_obj().ptr(), path.get_path().ptr(),
		                               static_cast<int>(path.get_type()));
		py_util::handle_py_error();
	}

	void Tracer::go_to_node(const Entity& ent, const GraphPath& path, bool forward) const {
		if (this->tracer.is_none()) {
			return;
		}

		py_tracer_go_to_node(this->tracer.ptr(), ent.get_obj().ptr(), path.get_path().ptr(),
		                     static_cast<int>(path.get_type()), forward);
		py_util::handle_py_error();
	}

	void Tracer::clear() const {
		if (this->tracer.is_none()) {
			return;
		}

		py_tracer_clear(this->tracer.ptr());
		py_util::handle_py_error();
	}

} // namespace ara::step::tracer
