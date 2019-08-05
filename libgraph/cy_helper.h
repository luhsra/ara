#pragma once

#include <iostream>
#include <sstream>
#include <string>

template <class T>
std::string to_string(const T& obj) {
	std::stringstream st;
	st << obj;
	return st.str();
}
