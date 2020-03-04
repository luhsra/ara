#include "step.h"
#include "native_step_pyx.h"

#include <boost/property_tree/json_parser.hpp>
#include <sstream>

using namespace boost::property_tree;

namespace ara::step {
	void StepManager::chain_step(const ptree& step_config) {
		std::stringstream sstream;
		json_parser::write_json(sstream, step_config, /* pretty = */ false);
		step_manager_chain_step(step_manager, sstream.str().c_str());
	}

	void StepManager::chain_step(const std::string step_name) {
		ptree tree;
		tree.put("name", step_name);
		chain_step(tree);
	}

	std::string StepManager::get_execution_id() { return step_manager_get_execution_id(step_manager); }
} // namespace ara::step
