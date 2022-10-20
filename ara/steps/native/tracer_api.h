#pragma once

#include "logging.h"
#include "mix.h"

#include <Python.h>
#include <boost/python.hpp>

// we use 'unsigned long' directly for vertex ids in cython, so make sure it is the same as uint64_t
static_assert(sizeof(uint64_t) == sizeof(unsigned long));

namespace ara::step::tracer {

	template <typename Graph>
	using Edge = typename boost::graph_traits<Graph>::edge_descriptor;

	class Entity {
		boost::python::object ent;

	  public:
		Entity(PyObject* ent);
		boost::python::object get_obj() const { return ent; }
	};

	class GraphNode {
		uint64_t node;
		graph::GraphType type;

	  public:
		GraphNode(uint64_t node, graph::GraphType type) : node(node), type(type) {}
		uint64_t get_node() const { return node; }
		graph::GraphType get_type() const { return type; }
	};

	class GraphPath;

	class Tracer {
		boost::python::object tracer; // nullptr means that tracing is deactivated. In that case all calls does nothing.
		Logger& logger;
		boost::python::object get_vertex_by_id(const GraphNode& node) const;

	  public:
		Tracer(PyObject* tracer, Logger& logger);
		bool is_active() const { return !tracer.is_none(); }
		Entity get_entity(const std::string& str) const;
		void entity_on_node(const Entity& ent,
		                    const GraphNode& node) const; // currently only support for one Node in this wrapper
		void entity_is_looking_at(const Entity& ent,
		                          const GraphPath& path) const; // currently only support for one Path in this wrapper
		void go_to_node(const Entity& ent, const GraphPath& path, bool forward = true) const;
		boost::python::object add_edge_to_path(boost::python::object path, uint64_t source, uint64_t target,
		                                       graph::GraphType type) const;
		void clear() const;
	};

	class GraphPath {
		boost::python::object path;
		graph::GraphType type;

	  public:
		GraphPath(graph::GraphType type) : path(boost::python::object{}), type(type) {}

		/**
		 * @brief Clones this object and creates a copy of python obj path
		 */
		GraphPath clone();

		template <typename Graph>
		void add_edge(const Tracer& tracer, const Edge<Graph>& edge, const Graph& g) {
			if (!tracer.is_active()) {
				return;
			}
			this->path = tracer.add_edge_to_path(this->path, source(edge, g), target(edge, g), this->type);
		}

		boost::python::object get_path() const { return path; }
		graph::GraphType get_type() const { return type; }
	};
} // namespace ara::step::tracer
