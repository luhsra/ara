/**
 * Common helper functions for C++.
 */
#pragma once

#include <type_traits>
#include <cassert>

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
} // namespace ara
