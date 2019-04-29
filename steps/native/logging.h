#ifndef LOGGER_H
#define LOGGER_H

#include "py_logging.h"

#include <sstream>

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
			return (o_stream.good()) ? 0 : -1;
		}

		LogLevel level;
		PyLogger& logger;
		std::ostringstream o_stream;
	};

	class LogStream : public std::ostream {
	  public:
		LogStream(LogLevel level, PyLogger& logger) : std::ostream(&buf), buf(level, logger) {}

	  private:
		LogBuf buf;
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
