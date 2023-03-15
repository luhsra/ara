// SPDX-FileCopyrightText: 2021 Gerion Entrup <entrup@sra.uni-hannover.de>
// SPDX-FileCopyrightText: 2021 Lukas Berg
//
// SPDX-License-Identifier: GPL-3.0-or-later

#pragma once

#include <exception>
#include <sstream>

namespace ara {
	class VertexNotFound : public std::runtime_error {
	  private:
		static std::string format(const std::string& action, const std::string& vertex_name) {
			std::stringstream ss;
			ss << action << ": Vertex " << vertex_name << " not found in Graph";
			return ss.str();
		}

	  public:
		explicit VertexNotFound(const std::string& action = "", const std::string& vertex_name = "")
		    : std::runtime_error(format(action, vertex_name)) {}
	};

	class EdgeNotFound : public std::runtime_error {
	  private:
		static std::string format(const std::string& action, const std::string& edge_name) {
			std::stringstream ss;
			ss << action << ": Edge " << edge_name << " not found in Graph";
			return ss.str();
		}

	  public:
		explicit EdgeNotFound(const std::string& action = "", const std::string& edge_name = "")
		    : std::runtime_error(format(action, edge_name)) {}
	};

	class FunctionNotFound : public std::runtime_error {
	  private:
		static std::string format(const std::string& function_name) {
			std::stringstream ss;
			ss << "Function " << function_name << " not found in Graph";
			return ss.str();
		}

	  public:
		explicit FunctionNotFound(const std::string& function_name = "") : std::runtime_error(format(function_name)) {}
	};

	struct LLVMError : public std::runtime_error {
		using std::runtime_error::runtime_error;
	};

	class NotImplemented : public std::exception {
		virtual const char* what() const throw() { return "Not implemented."; }
	};

	class PythonError : public std::exception {
		virtual const char* what() const throw() { return "Something in Python went wrong"; }
	};

	class StopDFSException : public std::exception {
		virtual const char* what() const throw() { return "The DFS needs a premature abort."; }
	};

	class BoostPythonInconvertable : public std::exception {
		virtual const char* what() const throw() {
			return "Boost Python. Could not convert Python object into C++ class.";
		}
	};

	class ValuesUnknown : public std::runtime_error {
	  public:
		explicit ValuesUnknown(const std::string& message) : std::runtime_error(message) {}
	};

	class ConnectionStatusUnknown : public std::runtime_error {
	  public:
		explicit ConnectionStatusUnknown(const std::string& message) : std::runtime_error(message) {}
	};

	class StepError : public std::runtime_error {
	  private:
		static std::string format(const std::string& step_name, const std::string& message) {
			std::stringstream ss;
			ss << "Error in step " << step_name << ": " << message;
			return ss.str();
		}

	  public:
		explicit StepError(const std::string& step_name, const std::string& message)
		    : std::runtime_error(format(step_name, message)) {}
	};
} // namespace ara
