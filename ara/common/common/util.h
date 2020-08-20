/**
 * Common helper functions for C++.
 */
#pragma once

namespace ara {
	template <class T>
	T& safe_deref(T* t) {
		assert(t != nullptr && "t is not null");
		return *t;
	}
} // namespace ara
