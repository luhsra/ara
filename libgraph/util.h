#pragma once

#include <string>
#include <sstream>
#include <iostream>

template<class T>
std::string to_string(const T& obj) {
	std::stringstream st;
	st << obj;
	return st.str();
}
