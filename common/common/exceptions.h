#pragma once

#include <exception>

namespace ara {
	class VertexNotFound : public std::exception {
		virtual const char* what() const throw() { return "Vertex not found in Graph"; }
	} vertex_not_found;

	class FunctionNotFound : public std::exception {
		virtual const char* what() const throw() { return "Function not found in Graph"; }
	} function_not_found;

	class NotImplemented : public std::exception {
		virtual const char* what() const throw() { return "Not implemented."; }
	} not_implemented;
} // namespace ara
