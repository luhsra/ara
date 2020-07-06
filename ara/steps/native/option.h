#pragma once

#include <Python.h>
#include <cassert>
#include <optional>
#include <sstream>
#include <string>
#include <tuple>
#include <utility>
#include <variant>
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
		using type = T;

	  protected:
		std::optional<type> value;
		std::optional<type> default_value;

		RawType() : step_name("") {}
		virtual ~RawType() {}

		PyObject* get_value(PyObject* config, const std::string& key) {
			assert(PyDict_Check(config));
			assert(step_name != "");
			return PyDict_GetItemString(config, key.c_str());
		}

		std::string step_name;

	  public:
		virtual void from_pointer(PyObject*, std::string){};

		void check(PyObject* obj, const std::string& key) {
			PyObject* scoped_obj = get_value(obj, key);
			if (!scoped_obj) {
				this->value = std::nullopt;
				return;
			}
			this->from_pointer(scoped_obj, key);
		}

		std::string serialize_args() const { return ""; }

		void set_step_name(const std::string& step_name) { this->step_name = step_name; }

		void set_default_value(std::optional<type> default_value) { this->default_value = default_value; }

		std::optional<type> get() {
			if (value) {
				return value;
			}
			return default_value;
		}
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
		std::string serialize_args() const {
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

			this->value = cont.get();

			if (this->value()) {
				return;
			}

			if (*this->value < low || *this->value > high) {
				std::stringstream ss;
				ss << name << ": Range argument " << *this->value << "has to be between " << low << " and " << high
				   << "!" << std::flush;
				this->value = std::nullopt;
				throw std::invalid_argument(ss.str());
			}
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
				this->value = std::nullopt;
				return;
			}

			if (!PyList_Check(scoped_obj)) {
				std::stringstream ss;
				ss << key << ": Must be a list" << std::flush;
				this->value = std::nullopt;
				throw std::invalid_argument(ss.str());
			}

			this->value = std::optional(std::vector<typename T::type>());
			for (Py_ssize_t i = 0; i < PyList_Size(scoped_obj); ++i) {
				T cont;
				cont.from_pointer(PyList_GetItem(scoped_obj, i), key);
				auto ret = cont.get();

				if (!ret.has_value()) {
					this->value = std::nullopt;
					return;
				}
				this->value->emplace_back(*ret);
			}
		}
	};

	template <std::size_t N>
	class Choice : public RawType<typename String::type> {
		int64_t index;
		std::array<String::type, N> choices;

	  public:
		explicit Choice(std::array<String::type, N> choices)
		    : RawType<typename String::type>(), index(-1), choices(choices) {}

		static unsigned get_type() { return OptionType::CHOICE; }

		std::string serialize_args() const {
			std::stringstream ss;
			const char delim = ':';
			bool first = true;
			for (const typename String::type& choice : choices) {
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

			this->value = cont.get();

			if (this->value) {
				unsigned found_index = 0;
				for (typename String::type& choice : choices) {
					if (*this->value == choice) {
						break;
					}
					found_index++;
				}
				if (found_index == choices.size()) {
					std::stringstream ss;
					ss << name << ": Value " << *this->value << " is not in the list of possible choices."
					   << std::flush;
					this->value = std::nullopt;
					throw std::invalid_argument(ss.str());
				}
				this->index = found_index;
			}
		}

		/**
		 * Return the Index of the matching choice.
		 * Can be used in performance critical code.
		 */
		int64_t getIndex() { return index; }
	};

	template <class... T2, int N = sizeof...(T2)>
	constexpr auto makeChoice(T2... args) -> Choice<N> {
		std::array<String::type, N> arr = {args...};
		return Choice<N>(std::move(arr));
	}

	/**
	 * Description object for an option entity.
	 * The instance that actually holds the values.
	 */
	class OptEntity {
	  public:
		virtual ~OptEntity() = default;
		/**
		 * check in global config dict for this option.
		 */
		virtual void check(PyObject*) = 0;
	};

	template <class T>
	class TOptEntity : public OptEntity {
	  private:
		std::optional<T> ty;
		std::string opt_name;

	  public:
		TOptEntity() : ty(std::nullopt), opt_name(""){};

		TOptEntity(T ty, const std::string& step_name, const std::string& opt_name) : ty(ty), opt_name(opt_name) {
			this->ty->set_step_name(step_name);
		}

		virtual void check(PyObject* obj) override { ty->check(obj, opt_name); }
		/**
		 * get value of option.
		 */
		std::optional<typename T::type> get() { return ty->get(); }
	};

	/**
	 * Description object for options
	 */
	struct Option {
	  protected:
		const std::string name;
		const std::string help;

		virtual std::string get_type_args() const = 0;

	  public:
		// only for Python bridging, sed cy_helper.h
		friend std::string get_type_args(const ara::option::Option* opt);

		Option(const std::string& name, const std::string& help) : name(name), help(help) {}
		Option() = default;
		Option(const Option&) = delete;

		virtual ~Option() = default;

		virtual bool is_global() const = 0;

		virtual unsigned get_type() const = 0;

		const std::string get_name() const { return name; }
		const std::string get_help() const { return help; }
	};

	/**
	 * A Typed Option, aka an option with option which also stores its type.
	 */
	template <class T>
	class TOption : public Option {
	  private:
		T ty;
		bool global;

		virtual std::string get_type_args() const override { return ty.serialize_args(); }

	  public:
		TOption(const std::string& name, const std::string& help, T ty = T(),
		        std::optional<typename T::type> default_value = std::nullopt, bool global = false)
		    : Option(name, help), ty(ty), global(global) {
			this->ty.set_default_value(default_value);
		}
		TOption(const TOption&) = delete;

		TOptEntity<T> instantiate(const std::string step_name) const { return TOptEntity<T>(ty, step_name, name); }

		virtual bool is_global() const override { return global; }

		virtual unsigned get_type() const override { return T::get_type(); }
	};
} // namespace ara::option
