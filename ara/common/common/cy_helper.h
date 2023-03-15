// SPDX-FileCopyrightText: 2020 Gerion Entrup <entrup@sra.uni-hannover.de>
//
// SPDX-License-Identifier: GPL-3.0-or-later

#pragma once

#include <sstream>
#include <string>

namespace ara::cy_helper {
	template <class T>
	std::string to_string(const T& obj) {
		std::stringstream st;
		st << obj;
		return st.str();
	}

	template <class Enum>
	inline void assign_enum(Enum& e, int i) {
		e = static_cast<Enum>(i);
	}

	template <class T>
	inline std::shared_ptr<T> to_shared_ptr(std::unique_ptr<T> ptr) {
		return ptr;
	}
} // namespace ara::cy_helper
