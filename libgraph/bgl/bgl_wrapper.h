#pragma once

#include "common/exceptions.h"
#include "boost/range/iterator.hpp"
#include <memory>

namespace ara::bgl_wrapper {
	struct BoostProperty {
		virtual ~BoostProperty() {}
	};

	template<class T>
	using SamePair = std::pair<T, T>;

	template<class T>
	struct GraphIterator {
		virtual ~GraphIterator() {}

		virtual std::unique_ptr<T> operator*() { throw ara::NotImplemented(); }
		virtual GraphIterator<T>& operator++() { throw ara::NotImplemented(); }
		virtual GraphIterator<T>& operator--() { throw ara::NotImplemented(); }
		virtual GraphIterator<T>& operator+(size_t) { throw ara::NotImplemented(); }
		virtual GraphIterator<T>& operator-(size_t) { throw ara::NotImplemented(); }
		virtual bool operator==(const GraphIterator<T>&) { throw ara::NotImplemented(); }
		virtual bool operator!=(const GraphIterator<T>&) { throw ara::NotImplemented(); }
		virtual bool operator<(const GraphIterator<T>&) { throw ara::NotImplemented(); }
		virtual bool operator>(const GraphIterator<T>&) { throw ara::NotImplemented(); }
		virtual bool operator<=(const GraphIterator<T>&) { throw ara::NotImplemented(); }
		virtual bool operator>=(const GraphIterator<T>&) { throw ara::NotImplemented(); }
	};

	struct Predicate {};

	struct EdgeWrapper;

	struct VertexWrapper {
		virtual ~VertexWrapper() {}

		virtual SamePair<std::unique_ptr<GraphIterator<EdgeWrapper>>> in_edges() = 0;
		virtual SamePair<std::unique_ptr<GraphIterator<EdgeWrapper>>> out_edges() = 0;

		virtual uint64_t in_degree() = 0;
		virtual uint64_t out_degree() = 0;
		virtual uint64_t degree() = 0;

		virtual SamePair<std::unique_ptr<GraphIterator<VertexWrapper>>> adjacent_vertices() = 0;
		virtual SamePair<std::unique_ptr<GraphIterator<VertexWrapper>>> inv_adjacent_vertices() {
			throw ara::NotImplemented();
		}

		virtual void clear_in_edges() { throw ara::NotImplemented(); }
		virtual void clear_out_edges() { throw ara::NotImplemented(); }
		virtual void clear_edges() = 0;

		virtual uint64_t get_id() = 0;
		virtual std::unique_ptr<BoostProperty> get_property_obj() { return nullptr; }
	};

	struct EdgeWrapper {
		virtual ~EdgeWrapper() {}

		virtual std::unique_ptr<VertexWrapper> source() = 0;
		virtual std::unique_ptr<VertexWrapper> target() = 0;

		virtual std::unique_ptr<BoostProperty> get_property_obj() { return nullptr; }
	};

	struct GraphWrapper {
		virtual ~GraphWrapper() {}

		virtual SamePair<std::unique_ptr<GraphIterator<VertexWrapper>>> vertices() = 0;
		virtual uint64_t num_vertices() = 0;

		virtual SamePair<std::unique_ptr<GraphIterator<EdgeWrapper>>> edges() = 0;
		virtual uint64_t num_edges() = 0;

		virtual std::unique_ptr<VertexWrapper> add_vertex() = 0;
		/* TODO not supported by boost subgraph */
		// virtual void remove_vertex(VertexWrapper& vertex) = 0;

		virtual std::unique_ptr<EdgeWrapper> add_edge(VertexWrapper& source, VertexWrapper& target) = 0;
		virtual void remove_edge(EdgeWrapper& edge) = 0;

		/* subgraph functions */
		virtual std::unique_ptr<GraphWrapper> create_subgraph() { throw ara::NotImplemented(); }

		virtual bool is_root() { throw ara::NotImplemented(); }

		virtual std::unique_ptr<GraphWrapper> root() { throw ara::NotImplemented(); }

		virtual std::unique_ptr<GraphWrapper> parent() { throw ara::NotImplemented(); }

		virtual SamePair<std::unique_ptr<GraphIterator<GraphWrapper>>> children() { throw ara::NotImplemented(); }

		virtual std::unique_ptr<VertexWrapper> local_to_global(VertexWrapper&) { throw ara::NotImplemented(); }
		virtual std::unique_ptr<EdgeWrapper> local_to_global(EdgeWrapper&) { throw ara::NotImplemented(); }

		virtual std::unique_ptr<VertexWrapper> global_to_local(VertexWrapper&) { throw ara::NotImplemented(); }
		virtual std::unique_ptr<EdgeWrapper> global_to_local(EdgeWrapper&) { throw ara::NotImplemented(); }

		virtual std::unique_ptr<GraphWrapper> filter_by(Predicate, Predicate) { throw ara::NotImplemented(); }

		virtual std::unique_ptr<BoostProperty> get_property_obj() { return nullptr; }
	};
} // namespace bgl_wrapper
