/**
 * Common helper functions for C++.
 */
#pragma once

#include <cassert>
#include <type_traits>

namespace ara {
	template <typename T>
	class remove_pointer_ {
		template <typename U = T>
		static auto test(int) -> std::remove_reference<decltype(*std::declval<U>())>;
		static auto test(...) -> std::remove_cv<T>;

	  public:
		using type = typename decltype(test(0))::type;
	};

	template <typename T>
	using remove_pointer = typename remove_pointer_<T>::type;

	/**
	 * Dereference any kind of pointer, raw or smart, and return a reference.
	 * While dereferencing, it checks for a null pointer and fails in error case.
	 */
	template <class T>
	inline remove_pointer<T>& safe_deref(T&& t) {
		assert(t != nullptr && "t is not null");
		return *t;
	}

	/**
	 * Helper class for std::visit. See example for std::visit for explanation.
	 * Drop this, once a std::overload exists.
	 */
	template <class... Ts>
	struct overloaded : Ts... {
		using Ts::operator()...;
	};
	// explicit deduction guide (not needed as of C++20)
	template <class... Ts>
	overloaded(Ts...) -> overloaded<Ts...>;

	/**
	 * Do a special action for the first round in the loop
	 *
	 * Credit: Joakim Thorén, https://stackoverflow.com/a/54833594
	 */
	template <typename BeginIt, typename EndIt, typename FirstFun, typename OthersFun>
	void for_first_then_each(BeginIt begin, EndIt end, FirstFun firstFun, OthersFun othersFun) {
		if (begin == end)
			return;
		firstFun(*begin);
		for (auto it = std::next(begin); it != end; ++it) {
			othersFun(*it);
		};
	}
} // namespace ara
