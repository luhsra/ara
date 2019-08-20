#pragma once

#include <exception>

namespace ara {
	class VertexNotFound : public std::exception {
		virtual const char* what() const throw() { return "Vertex not found in Graph"; }
	};

	class FunctionNotFound : public std::exception {
		virtual const char* what() const throw() { return "Function not found in Graph"; }
	};

	class NotImplemented : public std::exception {
		virtual const char* what() const throw() { return "Not implemented."; }
	};
} // namespace ara
