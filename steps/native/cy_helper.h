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

template <class S> step::Step* step_fac(PyObject* config) {
	step::Step* s = new S();
	s->parse_options(config);
	return s;
}
