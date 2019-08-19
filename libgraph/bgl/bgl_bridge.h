#pragma once

#define BOOST_RESULT_OF_USE_DECLTYPE

#include "bgl_wrapper.h"

#include <memory>

#include "boost/range/iterator_range.hpp"
#include "boost/graph/graph_concepts.hpp"
#include "boost/graph/subgraph.hpp"
#include <boost/iterator/transform_iterator.hpp>

namespace ara::bgl_wrapper {

	template<typename T, typename boost_iterator, typename value_type>
	class GraphIter : public GraphIterator<T> {
		private:
			boost::transform_iterator<boost_iterator, int> iter;

			static std::unique_ptr<typename value_type> convert_to_ptr(value_type& obj) {
				return std::move(std::make_unique<value_type>(T(obj)));
			}
		public:
			GraphIter(boost_iterator it) : iter(boost::make_transform_iterator(it, convert_to_ptr)) {}


        virtual std::unique_ptr<T> operator*() override {
			return *iter;
		}
        virtual GraphIterator<T>& operator++() override {
			iter->operator++;
			return *this;
		}
        virtual GraphIterator<T>& operator--() override {
			iter->operator--;
			return *this;
		}
        virtual GraphIterator<T>& operator+(size_t s) override {
			iter->operator+(s);
			return *this;
		}
        virtual GraphIterator<T>& operator-(size_t s) override {
			iter->operator-(s);
			return *this;
		}

        virtual bool operator==(const GraphIterator<T>& o) override {
			return this->iter == o.iter;
		}
        virtual bool operator!=(const GraphIterator<T>& o) override {
			return this->iter != o.iter;
		}
        virtual bool operator<(const GraphIterator<T>& o) override {
			return this->iter < o.iter;
		}
        virtual bool operator>(const GraphIterator<T>& o) override {
			return this->iter > o.iter;
		}
        virtual bool operator<=(const GraphIterator<T>& o) override {
			return this->iter <= o.iter;
		}
        virtual bool operator>=(const GraphIterator<T>& o) override {
			return this->iter >= o.iter;
		}
	};


// First, define a lambda to get the second element of a pair:
auto get_second = [](const std::pair<const int,std::string>& p){ return p.second; };

// Then, we can convert a map iterator into an iterator that automatically dereferences the second element
auto beg = boost::make_transform_iterator(m.begin(),get_second);
auto end = boost::make_transform_iterator(m.end(),get_second);
f(beg,end); // ok, works!

	class PredicateImpl {};

	// template<typename W, typename I, typename V>
	// static inline boost::iterator_range<GraphIterator<W>> convert_it(std::pair<I, I> its) {
	// 	GraphIter<W, I, V> first(its.first);
	// 	GraphIter<W, I, V> second(its.second);
	// 	return boost::make_iterator_range(first, second);
	// }

	template<typename W, typename I, typename V>
	static inline boost::iterator_range<GraphIterator<W>> convert_it(std::pair<I, I> its) {
		auto first = std::make_unique<GraphIter<W, I, V>>(its.first);
		auto second = std::make_unique<GraphIter<W, I, V>>(its.second);
		return std::make_pair(first, second);
	}

	template<typename Graph> class GraphImpl;

	template<typename Graph>
	class VertexImpl : public VertexWrapper {
		public:
		virtual ~VertexImpl() {}

		VertexImpl(Graph& g, typename Graph::vertex_descriptor& v) : g(g), v(v) {}

		virtual SamePair<std::unique_ptr<GraphIterator<EdgeWrapper>>> in_edges() override {
			return convert_it<EdgeWrapper, typename Graph::edge_iterator, typename Graph::edge_descriptor>(boost::in_edges(g, v));
		}

		virtual SamePair<std::unique_ptr<GraphIterator<EdgeWrapper>>> out_edges() override {
			return convert_it<EdgeWrapper, typename Graph::edge_iterator, typename Graph::edge_descriptor>(boost::out_edges(g, v));
		}

		virtual uint64_t in_degree() override{
			return convert_size(boost::in_degree(g, v));
		}

		virtual uint64_t out_degree() override {
			return convert_size(boost::out_degree(g, v));
		}

		virtual uint64_t degree()override  {
			return convert_size(boost::degree(g, v));
		}

		virtual SamePair<std::unique_ptr<GraphIterator<VertexWrapper>>> adjacent_vertices() override {
			return convert_it<VertexWrapper, typename Graph::vertex_iterator, typename Graph::vertex_descriptor>(boost::adjacent_vertices(g, v));
		}


		virtual SamePair<std::unique_ptr<GraphIterator<VertexWrapper>>> inv_adjacent_vertices() override {
			return convert_it<VertexWrapper, typename Graph::vertex_iterator, typename Graph::vertex_descriptor>(boost::adjacent_vertices(g, v));
		}

		virtual void clear_in_edges() override {
			boost::clear_in_edges(g, v);
		}

		virtual void clear_out_edges() override {
			boost::clear_out_edges(g, v);
		}

		virtual void clear_edges() override {
			boost::clear_edges(g, v);
		}

		private:
		friend class GraphImpl<Graph>;

		uint64_t convert_size(typename boost::graph_traits<Graph>::degree_size_type size) {
			return static_cast<uint64_t>(size);
		}

		Graph& g;
		typename Graph::vertex_descriptor& v;
	};

	template<typename Graph>
	class EdgeImpl {
		public:
		virtual ~EdgeImpl() {}

		virtual std::unique_ptr<VertexWrapper> source() override {
			return std::make_unique<VertexImpl<Graph>>(boost::source(g, e));
		}

		virtual VertexWrapper& target() override {
			return std::make_unique<VertexImpl<Graph>>(boost::target(g, e));
		}

		private:
		friend class GraphImpl<Graph>;

		Graph& g;
		typename Graph::edge_descriptor& e;
	};

	template<typename Graph>
	class GraphImpl : public GraphWrapper{
		public:
		virtual ~GraphImpl() {}

		virtual SamePair<std::unique_ptr<GraphIterator<VertexWrapper>>> vertices() override {
			return convert_it<VertexWrapper, typename Graph::vertex_iterator, typename Graph::vertex_descriptor>(boost::vertices(graph));
		}

		virtual uint64_t num_vertices() override {
			auto size = boost::num_vertices(graph);
			return static_cast<uint64_t>(size);
		}

		virtual SamePair<std::unique_ptr<GraphIterator<EdgeWrapper>>> edges() override {
			return convert_it<EdgeWrapper, typename Graph::edge_iterator, typename Graph::edge_descriptor>(boost::edges(graph));
		}

		virtual uint64_t num_edges() override {
			auto size = boost::num_edges(graph);
			return static_cast<uint64_t>(size);
		}

		virtual std::unique_ptr<VertexWrapper> add_vertex() override {
			auto v = boost::add_vertex(graph);
			return std::make_unique<VertexImpl<Graph>>(graph, v);
		}

		virtual void remove_vertex(VertexWrapper& vertex) override {
			auto v = static_cast<VertexImpl<Graph>>(vertex);
			boost::remove_vertex(v.v, graph);
		}

		virtual std::unique_ptr<EdgeWrapper> add_edge(VertexWrapper& source, VertexWrapper& target) override {
			auto s = static_cast<VertexImpl<Graph>>(source);
			auto t = static_cast<VertexImpl<Graph>>(target);
			auto e = boost::add_edge(graph, s, t);
			return std::make_unique<EdgeImpl<Graph>>(graph, e);
		}

		virtual void remove_edge(EdgeWrapper& edge) override {
			auto e = static_cast<EdgeImpl<Graph>>(edge);
			boost::remove_edge(e.e, graph);
		}
			protected:
		Graph& graph;
	};

	template<typename Graph>
	class SubGraphImpl : public GraphImpl<Graph>{
		public:

		//subgraph functions
		virtual std::unique_ptr<GraphWrapper> create_subgraph() override {
			auto& g = graph.create_subgraph();
			return std::make_unique<SubGraphImpl<Graph>>(g);
		}

		virtual bool is_root() override {
			return graph.is_root();
		}

		virtual std::unique_ptr<GraphWrapper> root() override {
			auto& g = graph.root();
			return std::make_unique<SubGraphImpl<Graph>>(g);
		}

		virtual std::unique_ptr<GraphWrapper> parent() override {
			auto& g = graph.parent();
			return std::make_unique<SubGraphImpl<Graph>>(g);
		}

		virtual SamePair<std::unique_ptr<GraphIterator<GraphWrapper>>> children() override {
			return convert_it<GraphWrapper, typename Graph::children_iterator, typename Graph>(graph.children(graph));
		}

		virtual std::unique_ptr<VertexWrapper> local_to_global(VertexWrapper& vertex) override {
			return std::make_unique<VertexImpl<Graph>>(local_to_global(vertex.v));
		}
		virtual std::unique_ptr<EdgeWrapper> local_to_global(EdgeWrapper& edge) override {
			return std::make_unique<EdgeImpl<Graph>>(local_to_global(edge.e));
		}

		virtual std::unique_ptr<VertexWrapper> global_to_local(VertexWrapper& vertex) override {
			return std::make_unique<VertexImpl<Graph>>(global_to_local(vertex.v));
		}
		virtual std::unique_ptr<EdgeWrapper> global_to_local(EdgeWrapper& edge) override {
			return std::make_unique<EdgeImpl<Graph>>(global_to_local(edge.e));
		}

		virtual std::unique_ptr<GraphWrapper> filter_by(Predicate vertex, Predicate edge) override {
			/* TODO */
			return nullptr;
		}

	};
}
