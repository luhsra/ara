#pragma once

#include "graph.h"

#include <boost/iterator/iterator_facade.hpp>
#include <sstream>
#include <string>

namespace cy_helper {

	template <class T>
	std::string to_string(const T& obj) {
		std::stringstream st;
		st << obj;
		return st.str();
	}

	template <class T, class P>
	class PtrIterator : public boost::iterator_facade<PtrIterator<T, P>, P*, boost::forward_traversal_tag, P*> {
	  public:
		PtrIterator() : iterator() {}

		explicit PtrIterator(T iterator) : iterator(iterator) {}

	  private:
		friend class boost::iterator_core_access;

		void increment() { iterator++; }

		bool equal(PtrIterator<T, P> const& other) const { return this->iterator == other.iterator; }

		P* dereference() const {
			P& tmp = *iterator;
			return &tmp;
		}

		T iterator;
	};

	template <class T, class P>
	class PtrRange {
	  public:
		PtrRange() : begini(), endi() {}

		PtrRange(T begin, T end) : begini(begin), endi(end) {}

		PtrIterator<T, P> begin() { return PtrIterator<T, P>(begini); }

		PtrIterator<T, P> end() { return PtrIterator<T, P>(endi); }

	  private:
		T begini;
		T endi;
	};

	template <class T, class P>
	PtrRange<T, P> make_ptr_range(std::pair<T, T> iterators) {
		return PtrRange<T, P>(iterators.first, iterators.second);
	}

	ara::cfg::Function* get_subgraph_prop(ara::cfg::FunctionDescriptor* descr) {
		ara::cfg::Function& func = boost::get_property(*descr);
		return &func;
	}

	template <class T>
	class SubgraphIterator
	    : public boost::iterator_facade<SubgraphIterator<T>, typename T::vertex_descriptor,
	                                    boost::forward_traversal_tag, typename T::vertex_descriptor> {
	  public:
		SubgraphIterator() = default;

		explicit SubgraphIterator(typename T::vertex_iterator iterator, const T* subgraph)
		    : iterator(iterator), subgraph(subgraph) {}

	  private:
		friend class boost::iterator_core_access;

		void increment() { iterator++; }

		bool equal(SubgraphIterator<T> const& other) const { return this->iterator == other.iterator; }

		typename T::vertex_descriptor dereference() const {
			typename T::vertex_descriptor tmp = subgraph->local_to_global(*iterator);
			return tmp;
		}

		typename T::vertex_iterator iterator;
		const T* subgraph;
	};

	template <class T>
	class SubgraphRange {
	  public:
		SubgraphRange() = default;
		SubgraphRange(const T& subgraph) : subgraph(&subgraph) {
			auto its = boost::vertices(subgraph);
			begini = its.first;
			endi = its.second;
		}

		SubgraphIterator<T> begin() { return SubgraphIterator<T>(begini, subgraph); }

		SubgraphIterator<T> end() { return SubgraphIterator<T>(endi, subgraph); }

	  private:
		const T* subgraph;
		typename T::vertex_iterator begini;
		typename T::vertex_iterator endi;
	};

	template <class E, class V, class G>
	V target(E& edge, G& graph) {
		return boost::target(edge, graph);
	}

	template <class E, class V, class G>
	V source(E& edge, G& graph) {
		return boost::source(edge, graph);
	}

	template <class E, class G>
	std::pair<E, E> edges(G& graph) {
		return std::move(boost::edges(graph));
	}

	template <class V, class G>
	std::pair<V, V> vertices(G& graph) {
		return std::move(boost::vertices(graph));
	}
} // namespace cy_helper
