#pragma once

#include <exception>
#include <sstream>

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

	class PythonError : public std::exception {
		virtual const char* what() const throw() { return "Something in Python went wrong"; }
	};

	class BoostPythonInconvertable : public std::exception {
		virtual const char* what() const throw() {
			return "Boost Python. Could not convert Python object into C++ class.";
		}
	};

	class ValuesUnknown : public std::exception {
	  private:
		std::stringstream message;

	  public:
		explicit ValuesUnknown(const std::string& message) {
			this->message << "The correct values could not be retrieved: ";
			this->message << message;
			this->message.flush();
		}

		virtual const char* what() const throw() { return message.str().c_str(); }
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
