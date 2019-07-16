#pragma once

#include <exception>

namespace ara {
	class VertexNotFound : public std::exception {
		virtual const char* what() const throw() { return "Vertex not found in Graph"; }
	} vertex_not_found;
}; // namespace ara
