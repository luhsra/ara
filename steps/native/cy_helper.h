/**
 * Helper function for cython incompabilities. DO NOT USE IN OTHER C++-PARTS!
 */

#pragma once

#include "option.h"
#include "step.h"

std::vector<ara::option::Option*> repack(const step::Step& step) {
	std::vector<ara::option::Option*> rep;
	for (ara::option::Option& opt : step.options()) {
		rep.emplace_back(&opt);
	}
	return rep;
}

template <class S>
step::Step* step_fac(PyObject* config) {
	step::Step* s = new S();
	s->parse_options(config);
	return s;
}

namespace ara::option {
bool get_range_arguments(ara::option::Option* opt, int64_t& low, int64_t& high) {
	if (opt->get_type() == (ara::option::OptionType::RANGE | ara::option::OptionType::INT)) {
		static_cast<ara::option::TOption<ara::option::Range<ara::option::Integer>>*>(opt)->ty.get_args(low, high);
		return true;
	}
	return false;
}

bool get_range_arguments(ara::option::Option* opt, double& low, double& high) {
	if (opt->get_type() == (ara::option::OptionType::RANGE | ara::option::OptionType::FLOAT)) {
		static_cast<ara::option::TOption<ara::option::Range<ara::option::Float>>*>(opt)->ty.get_args(low, high);
		return true;
	}
	return false;
}
}
