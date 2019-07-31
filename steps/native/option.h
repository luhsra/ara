#pragma once

#include <string>
#include <tuple>
#include <utility>
#include <vector>

#include "Python.h"

namespace ara::option {
	template<typename T>
	class RawType {
		public:
		typedef T type;

		protected:
		RawType();

		private:
		type value;

		public:

		std::pair<type, bool> get() {
			return std::make_pair(value, false);
		}
	};

	struct Integer : public RawType<int64_t> {
		void check(PyObject* obj);
		Integer() {};
	};

	struct Float : public RawType<double> {
		void check(PyObject* obj);
		Float() {};
	};

	struct Bool : public RawType<bool> {
		void check(PyObject* obj);
		Bool() {};
	};

	struct String : public RawType<std::string> {
		void check(PyObject* obj);
		String() {};
	};

	template <typename T> struct allowed_in_range          { static const bool value = false; };
	template <>           struct allowed_in_range<Integer> { static const bool value = true; };
	template <>           struct allowed_in_range<Float>   { static const bool value = true; };

	template<class T>
	class Range : public RawType<typename T::type> {
		static_assert(allowed_in_range<T>::value, "Range of this type not allowed to be constructed.");

		T low;
		T high;

		public:
		Range(T low, T high) : low(low), high(high) {}

		void check(PyObject* obj) {}
	};

	template <typename T> struct allowed_in_list          { static const bool value = false; };
	template <>           struct allowed_in_list<Integer> { static const bool value = true; };
	template <>           struct allowed_in_list<Float>   { static const bool value = true; };
	template <>           struct allowed_in_list<String>  { static const bool value = true; };

	template<class T>
	class List : public RawType<std::vector<typename T::type>> {
		static_assert(allowed_in_list<T>::value, "List of this type not allowed to be constructed.");

		public:
		List() {}

		void check(PyObject* obj) {}
	};

	template <std::size_t N>
	class Choice : public RawType<typename String::type> {
		int64_t index;
		std::array<String::type, N> choices;

		public:
		Choice(std::array<String::type, N> choices) : choices(choices) {}

		void check(PyObject* obj) {}

		/**
		 * Return the Index of the matching choice.
		 * Can be used to performance critical code..
		 */
		int64_t getIndex() { return index; }
	};

	template<class...T2, int N = sizeof...(T2)>
	constexpr auto makeChoice(T2... args) -> Choice<N> {
		//return Choice<N>({ std::forward(args)... });
		std::array<String::type, N> arr = { args... };
		return Choice<N>(std::move(arr));
	}


	/**
	 * Description object for options
	 */
	struct Option {
		const std::string name;
		const std::string help;

		Option(std::string name, std::string help) : name(name), help(help) {}
		Option() = default;

		virtual ~Option() = default;

		/**
		 * check in global config dict for this option.
		 */
		virtual void check(PyObject*) = 0;

	};

	/**
	 * A Typed Option, aka an option with option which also stores its type.
	 */
	template<class T>
	class TOption : public Option {
		private:
		T ty;


		public:
		TOption(std::string name, std::string help, T ty = T()) : Option(name, help), ty(ty) {}

		virtual void check(PyObject* obj) override {
			ty.check(obj);
		}

		/**
		 * get value of option.
		 */
		std::pair<typename T::type, bool> get() {
			ty.get();
		}
	};
} // namespace ara::option
