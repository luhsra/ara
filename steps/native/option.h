#pragma once

#include <Python.h>
#include <cassert>
#include <sstream>
#include <string>
#include <tuple>
#include <utility>
#include <vector>

namespace ara::option {
	enum OptionType {
		INT = 0b1,
		FLOAT = 0b10,
		BOOL = 0b100,
		STRING = 0b1000,
		CHOICE = 0b10000,
		LIST = 0b100000,
		RANGE = 0b1000000
	};

	template <typename T>
	class RawType {
	  public:
		typedef T type;

	  protected:
		bool valid = false;
		type value;

		RawType() : step_name("") {}
		virtual ~RawType() {}

		PyObject* get_value(PyObject* config, std::string key) {
			assert(PyDict_Check(config));
			assert(step_name != "");
			return PyDict_GetItemString(config, key.c_str());
		}

		std::string step_name;

	  public:
		virtual void from_pointer(PyObject*, std::string){};

		void check(PyObject* obj, std::string key) {
			PyObject* scoped_obj = get_value(obj, key);
			if (!scoped_obj) {
				this->valid = false;
				return;
			}
			this->from_pointer(scoped_obj, key);
		}

		std::string serialize_args() { return ""; }

		void set_step_name(std::string step_name) { this->step_name = step_name; }

		std::pair<type, bool> get() { return std::make_pair(value, valid); }
	};

	struct Integer : public RawType<int64_t> {
		static unsigned get_type() { return OptionType::INT; }
		virtual void from_pointer(PyObject* obj, std::string name) override;
		using RawType<int64_t>::RawType;
	};

	struct Float : public RawType<double> {
		static unsigned get_type() { return OptionType::FLOAT; }
		virtual void from_pointer(PyObject* obj, std::string name) override;
		using RawType<double>::RawType;
	};

	struct Bool : public RawType<bool> {
		static unsigned get_type() { return OptionType::BOOL; }
		virtual void from_pointer(PyObject* obj, std::string name) override;
		using RawType<bool>::RawType;
	};

	struct String : public RawType<std::string> {
		static unsigned get_type() { return OptionType::STRING; }
		virtual void from_pointer(PyObject* obj, std::string name) override;
		using RawType<std::string>::RawType;
	};

	template <typename T>
	struct allowed_in_range {
		static const bool value = false;
	};
	template <>
	struct allowed_in_range<Integer> {
		static const bool value = true;
	};
	template <>
	struct allowed_in_range<Float> {
		static const bool value = true;
	};

	template <class T>
	class Range : public RawType<typename T::type> {
		static_assert(allowed_in_range<T>::value, "Range of this type not allowed to be constructed.");

		typename T::type low;
		typename T::type high;

	  public:
		std::string serialize_args() {
			std::stringstream ss;
			ss << low << ":" << high;
			return ss.str();
		}

		Range(typename T::type low, typename T::type high) : RawType<typename T::type>(), low(low), high(high) {}

		static unsigned get_type() { return OptionType::RANGE | T::get_type(); }

		void check(PyObject* obj, std::string name) {
			T cont;
			cont.set_step_name(this->step_name);
			cont.check(obj, name);

			auto ret = cont.get();
			this->value = ret.first;

			if (!ret.second) {
				this->valid = false;
				return;
			}

			if (this->value < low || this->value > high) {
				std::stringstream ss;
				ss << name << ": Range argument " << this->value << "has to be between " << low << " and " << high
				   << "!" << std::flush;
				throw std::invalid_argument(ss.str());
			}

			this->valid = true;
		}
	};

	template <typename T>
	struct allowed_in_list {
		static const bool value = false;
	};
	template <>
	struct allowed_in_list<Integer> {
		static const bool value = true;
	};
	template <>
	struct allowed_in_list<Float> {
		static const bool value = true;
	};
	template <>
	struct allowed_in_list<String> {
		static const bool value = true;
	};

	template <class T>
	class List : public RawType<std::vector<typename T::type>> {
		static_assert(allowed_in_list<T>::value, "List of this type not allowed to be constructed.");

	  public:
		using RawType<std::vector<typename T::type>>::RawType;

		static unsigned get_type() { return OptionType::LIST | T::get_type(); }

		void check(PyObject* obj, std::string key) {
			PyObject* scoped_obj = this->get_value(obj, key);

			if (!scoped_obj) {
				this->valid = false;
				return;
			}

			if (!PyList_Check(scoped_obj)) {
				std::stringstream ss;
				ss << key << ": Must be a list" << std::flush;
				throw std::invalid_argument(ss.str());
			}

			for (Py_ssize_t i = 0; i < PyList_Size(scoped_obj); ++i) {
				T cont;
				cont.from_pointer(PyList_GetItem(scoped_obj, i), key);
				auto ret = cont.get();

				if (!ret.second) {
					this->valid = false;
					return;
				}
				this->value.emplace_back(ret.first);
			}
			this->valid = true;
		}
	};

	template <std::size_t N>
	class Choice : public RawType<typename String::type> {
		int64_t index;
		std::array<String::type, N> choices;

	  public:
		Choice(std::array<String::type, N> choices) : RawType<typename String::type>(), choices(choices) {}

		static unsigned get_type() { return OptionType::CHOICE; }

		std::string serialize_args() {
			std::stringstream ss;
			const char delim = ':';
			bool first = true;
			for (typename String::type& choice : choices) {
				assert(choice.find(delim) == std::string::npos);
				if (first) {
					first = false;
				} else {
					ss << delim;
				}
				ss << choice;
			}
			return ss.str();
		}

		void check(PyObject* obj, std::string name) {
			String cont;
			cont.set_step_name(this->step_name);
			cont.check(obj, name);

			auto ret = cont.get();
			this->value = ret.first;

			if (!ret.second) {
				this->valid = false;
				return;
			}

			unsigned found_index = 0;
			for (typename String::type& choice : choices) {
				if (this->value == choice) {
					break;
				}
				found_index++;
			}
			if (found_index == choices.size()) {
				std::stringstream ss;
				ss << name << ": Value " << this->value << " is not in the list of possible choices." << std::flush;
				throw std::invalid_argument(ss.str());
			}

			this->valid = true;
		}

		/**
		 * Return the Index of the matching choice.
		 * Can be used to performance critical code..
		 */
		int64_t getIndex() { return index; }
	};

	template <class... T2, int N = sizeof...(T2)>
	constexpr auto makeChoice(T2... args) -> Choice<N> {
		std::array<String::type, N> arr = {args...};
		return Choice<N>(std::move(arr));
	}

	/**
	 * Description object for options
	 */
	struct Option {
	  protected:
		const std::string name;
		const std::string help;

		virtual std::string get_type_args() = 0;

	  public:
		// only for Python bridging, sed cy_helper.h
		friend std::string get_type_args(ara::option::Option* opt);

		Option(std::string name, std::string help) : name(name), help(help) {}
		Option() = default;

		virtual ~Option() = default;

		/**
		 * check in global config dict for this option.
		 */
		virtual void check(PyObject*) = 0;

		virtual void set_step_name(std::string step_name) = 0;

		virtual bool is_global() = 0;

		virtual unsigned get_type() = 0;

		std::string get_name() { return name; }
		std::string get_help() { return help; }
	};

	/**
	 * A Typed Option, aka an option with option which also stores its type.
	 */
	template <class T>
	class TOption : public Option {
	  private:
		T ty;
		bool global;

		virtual std::string get_type_args() { return ty.serialize_args(); }

	  public:
		TOption(std::string name, std::string help, T ty = T(), bool global = false)
		    : Option(name, help), ty(ty), global(global) {}

		virtual void set_step_name(std::string step_name) override { ty.set_step_name(step_name); }

		virtual void check(PyObject* obj) override { ty.check(obj, name); }

		virtual bool is_global() override { return global; }

		virtual unsigned get_type() { return T::get_type(); }
		/**
		 * get value of option.
		 */
		std::pair<typename T::type, bool> get() { return ty.get(); }
	};
} // namespace ara::option
