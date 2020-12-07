#ifndef LOGGER_H
#define LOGGER_H

/* Python.h must be included before py_logging.h, see
 * https://github.com/cython/cython/issues/3133
 * TODO, fixed in Cython 3.0
 */
#include "Python.h"
#include "py_logging.h"

#include <boost/python.hpp>
#include <boost/type_traits.hpp>
#include <llvm/Support/raw_os_ostream.h>
#include <map>
#include <sstream>

namespace ara {

	/**
	 * Provide an output stream that dumps its output with py_logging.
	 *
	 * You can use it with:
	 * Logger logger;
	 * logger.debug() << "foo" << std::endl;
	 */
	class Logger {
	  private:
		class LogBuf : public std::streambuf {
		  public:
			LogBuf(LogLevel level, PyLogger& py_logger) : level(level), py_logger(py_logger) {}

		  private:
			virtual int overflow(int c) override {
				if (c == EOF) {
					return !EOF;
				} else {
					o_stream.put(c);
					return (o_stream.eof()) ? EOF : c;
				}
			}

			virtual int sync() override {
				o_stream.flush();
				std::string msg = o_stream.str();
				if (msg.back() == '\n') {
					msg.pop_back();
				}
				py_log(level, py_logger, msg);
				o_stream.str(std::string());
				o_stream.clear();
				return (o_stream.good()) ? 0 : -1;
			}

			LogLevel level;
			PyLogger& py_logger;
			std::ostringstream o_stream;
		};

	  public:
		/**
		 * Class that behaves like a std::ostream. There is some magic in this class so it is able to handle logging of
		 * llvm classes and std classes.
		 *
		 * The problem is that LLVM has its own logging infrastructure with llvm::raw_ostream.
		 * This wrapper class therefore contains a std::ostream object with operator<< overloads for all objects enabled
		 * for std::ostream logging and a std::raw_ostream object with operator<< overloads for all LLVM classes.
		 */
		class LogStream {
		  private:
			friend Logger;
			struct _constructor_tag {}; // explicit _constructor_tag() = default; };

		  public:
			/**
			 * Enable operator<< for LLVM types (compatible with llvm::raw_ostream).
			 */
			template <typename T, std::enable_if_t<boost::has_left_shift<llvm::raw_ostream, T>::value, int> = 0>
			LogStream& operator<<(T& x) {
				llvm_stream << x;
				llvm_stream.flush();
				return *this;
			}

			/**
			 * Enable operator<< for standard C++ types (compatible with std::ostream).
			 */
			template <typename T>
			LogStream& operator<<(T&& x) {
				stream << std::forward<T>(x);
				return *this;
			}

			/**
			 * Enable operator<< for special functions like std::endl.
			 */
			LogStream& operator<<(std::ostream& (*manip)(std::ostream&)) {
				stream << manip;
				return *this;
			}

			/**
			 * Enable operator<< for boost::python objects.
			 */
			LogStream& operator<<(boost::python::object x) {
				stream << boost::python::extract<std::string>(boost::python::str(x))();
				return *this;
			}

			/**
			 * Get a reference to the llvm_ostream logger
			 */
			llvm::raw_os_ostream& llvm_ostream() { return llvm_stream; }

			/**
			 * Flush the std::ostream and llvm::raw_ostream logger.
			 */
			void flush() {
				llvm_stream.flush();
				stream.flush();
			}

			LogStream(LogLevel level, PyLogger& py_logger, _constructor_tag)
			    : buf(level, py_logger), stream(&buf), llvm_stream(stream) {}

		  private:
			static std::unique_ptr<LogStream> factory(LogLevel level, PyLogger& py_logger) {
				return std::make_unique<LogStream>(level, py_logger, _constructor_tag{});
			}

			LogBuf buf;
			std::ostream stream;
			llvm::raw_os_ostream llvm_stream;
		};

	  private:
		PyLogger logger;
		std::map<LogLevel, std::unique_ptr<Logger::LogStream>> instances;

		Logger::LogStream& get_instance(LogLevel level) {
			assert(logger.logger != nullptr);
			if (instances.find(level) == instances.end()) {
				instances[level] = LogStream::factory(level, logger);
			}
			return *instances[level];
		}

	  public:
		Logger() {
			logger.logger = nullptr;
			logger.level = LogLevel::NOTSET;
		}

		Logger(PyObject* py_logger) {
			assert(py_logger != nullptr);
			logger.logger = py_logger;
			logger.level = py_log_get_level(py_logger);
		}

		void set_level(LogLevel level) { logger.level = level; }
		LogLevel get_level() { return logger.level; }

		Logger::LogStream& crit() { return get_instance(LogLevel::CRITICAL); }

		Logger::LogStream& err() { return get_instance(LogLevel::ERROR); }

		Logger::LogStream& error() { return get_instance(LogLevel::ERROR); }

		Logger::LogStream& warn() { return get_instance(LogLevel::WARNING); }

		Logger::LogStream& warning() { return get_instance(LogLevel::WARNING); }

		Logger::LogStream& info() { return get_instance(LogLevel::INFO); }

		Logger::LogStream& debug() { return get_instance(LogLevel::DEBUG); }
	};

	inline LogLevel translate_level(std::string lvl) {
		if (lvl == "critical") {
			return LogLevel::CRITICAL;
		}
		if (lvl == "error") {
			return LogLevel::ERROR;
		}
		if (lvl == "warn" || lvl == "warning") {
			return LogLevel::WARNING;
		}
		if (lvl == "info") {
			return LogLevel::INFO;
		}
		if (lvl == "debug") {
			return LogLevel::DEBUG;
		}
		return LogLevel::NOTSET;
	}

} // namespace ara

#endif // LOGGER_H
