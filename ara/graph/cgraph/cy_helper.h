/**
 * Helper function for cython incompabilities. DO NOT USE IN OTHER C++-PARTS!
 */

#pragma once

namespace ara::graph {
	inline SigType to_sigtype(int ty) { return static_cast<SigType>(ty); }
} // namespace ara::graph
