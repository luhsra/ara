#pragma once

namespace ara::graph {
    /* empty class as common type for all Boost property classes. Necessary for the Python wrapper */
	/* TODO, this adds a vtable to all properties. Find a mechanism that only affects the wrapper. */
	struct BoostProperty {
		virtual ~BoostProperty() {}
	};
}
