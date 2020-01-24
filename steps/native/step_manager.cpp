#include "step.h"
// clang-format off
// cython headers does not include anything except Python itself
#include <string>
#include "native_step_pyx.h"
// clang-format on

#include <boost/property_tree/json_parser.hpp>
#include <sstream>

using namespace boost::property_tree;

namespace ara::step {
	void StepManager::chain_step(ptree step_config) {
		std::stringstream sstream;
		json_parser::write_json(sstream, step_config, /* pretty = */ false);
		chain_step_in_step_manager(step_manager, sstream.str());
	}

	void StepManager::chain_step(std::string step_name) {
		ptree tree;
		tree.put("name", step_name);
		chain_step(tree);
	}
} // namespace ara::step
