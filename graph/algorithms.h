/**
 * Provide algorithms or functions that are not contained in the BGL.
 */
#pragma once

#include <boost/graph/depth_first_search.hpp>
#include <exception>

namespace ara::graph {

	/**
	 * Check, if a path from source to target exists.
	 *
	 * Uses a BFS approach.
	 */
	template <typename Graph>
	bool is_connected(const Graph& g, const typename Graph::vertex_descriptor source,
	                  const typename Graph::vertex_descriptor target) {
		class VertexFound : public std::exception {};
		class VertexUnconnected : public std::exception {};
		class FoundVisitor : public boost::default_dfs_visitor {
			const typename Graph::vertex_descriptor source;
			const typename Graph::vertex_descriptor target;

		  public:
			FoundVisitor(const typename Graph::vertex_descriptor source, const typename Graph::vertex_descriptor target)
			    : source(source), target(target) {}

			void start_vertex(typename Graph::vertex_descriptor u, const Graph&) const {
				if (u != source) {
					throw VertexUnconnected();
				}
			}

			void discover_vertex(typename Graph::vertex_descriptor u, const Graph&) const {
				if (u == target) {
					throw VertexFound();
				}
			}
		};

		FoundVisitor vis(source, target);

		try {
			boost::depth_first_search(g, boost::visitor(vis).root_vertex(source));
		} catch (const VertexFound&) {
			return true;
		} catch (const VertexUnconnected&) {
		}
		return false;
	}
} // namespace ara::graph
