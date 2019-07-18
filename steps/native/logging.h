#ifndef LOGGER_H
#define LOGGER_H

#include "py_logging.h"

#include <boost/type_traits.hpp>
#include <llvm/Support/raw_os_ostream.h>
#include <sstream>

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
		LogBuf(LogLevel level, PyLogger& logger) : level(level), logger(logger) {}

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
			py_log(level, logger, msg);
			o_stream.str(std::string());
			o_stream.clear();
			return (o_stream.good()) ? 0 : -1;
		}

		LogLevel level;
		PyLogger& logger;
		std::ostringstream o_stream;
	};

  public:
	/**
	 * Class that behaves like a std::ostream. There is some magic in this class so it is able to handle logging of llvm
	 * classes and std classes.
	 *
	 * The problem is that LLVM has its own logging infrastructure with llvm::raw_ostream.
	 * This wrapper class therefore contains a std::ostream object with operator<< overloads for all objects enabled for
	 * std::ostream logging and a std::raw_ostream object with operator<< overloads for all LLVM classes.
	 */
	class LogStream {
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
		template <typename T> LogStream& operator<<(T&& x) {
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

	  private:
		friend Logger;
		LogStream(LogLevel level, PyLogger& logger) : buf(level, logger), stream(&buf), llvm_stream(stream) {}

		LogBuf buf;
		std::ostream stream;
		llvm::raw_os_ostream llvm_stream;
	};

	PyLogger logger;

  public:
	Logger() {
		logger.logger = nullptr;
		logger.level = LogLevel::NOTSET;
	}

	Logger(PyObject* py_logger) {
		assert(py_logger != nullptr);
		logger.logger = py_logger;
		logger.level = get_level(py_logger);
	}

	Logger::LogStream crit() {
		assert(logger.logger != nullptr);
		return Logger::LogStream(LogLevel::CRITICAL, logger);
	}

	Logger::LogStream err() {
		assert(logger.logger != nullptr);
		return Logger::LogStream(LogLevel::ERROR, logger);
	}

	Logger::LogStream warn() {
		assert(logger.logger != nullptr);
		return Logger::LogStream(LogLevel::WARNING, logger);
	}

	Logger::LogStream info() {
		assert(logger.logger != nullptr);
		return Logger::LogStream(LogLevel::INFO, logger);
	}

	Logger::LogStream debug() {
		assert(logger.logger != nullptr);
		return Logger::LogStream(LogLevel::DEBUG, logger);
	}
};

#endif // LOGGER_H
