// SPDX-FileCopyrightText: 2021 Bastian Fuhlenriede
// SPDX-FileCopyrightText: 2021 Gerion Entrup <entrup@sra.uni-hannover.de>
//
// SPDX-License-Identifier: GPL-3.0-or-later

// vim: set noet ts=4 sw=4:

#include "cdummy.h"

namespace ara::step {

	// ATTENTION: put in anonymous namespace to get an unique symbol
	namespace {
		template <typename Graph>
		void do_cfg_stuff(Graph& g, graph::CFG& cfg, Logger& logger) {
			for (auto v : boost::make_iterator_range(boost::vertices(g))) {
				logger.debug() << "Vertex: " << cfg.name[v] << std::endl;
			}
		}
	} // namespace

	namespace cdummy_detail {} // namespace cdummy_detail

	std::string CDummy::get_description() {
		return "Template for a C++ step."
		       "\n"
		       "Add a meaningful description of your step here.";
	}

	void CDummy::init_options() {
		dummy_option = dummy_option_template.instantiate(get_name());
		dummy_option2 = dummy_option2_template.instantiate(get_name());
		opts.emplace_back(dummy_option);
		opts.emplace_back(dummy_option2);
	}

	Step::OptionVec CDummy::get_local_options() { return {dummy_option_template, dummy_option2_template}; }

	void CDummy::run() {
		logger.info() << "Execute CDummy step." << std::endl;

		// demonstrate option usage
		const std::optional<int64_t>& dopt = dummy_option.get();
		if (dopt) {
			logger.info() << "Dummy option is " << *dopt << '.' << std::endl;
		}
		const auto& dopt2 = dummy_option2.get();
		assert(dopt2);
		logger.info() << "Dummy option 2 is " << *dopt2 << '.' << std::endl;

		// demonstrate graph dispatching
		// the following methods are independent (all methods work with all graphs) and need to be chosen case by case

		// 1. Non-class template function that gets all arguments
		graph::CFG cfg = graph.get_cfg();
		graph_tool::gt_dispatch<>()([&](auto& g) { do_cfg_stuff(g, cfg, logger); },
		                            graph_tool::always_directed())(cfg.graph.get_graph_view());

		// 2. Class template function that gets only the graph
		// Note, that this must be implemented in the header. Suitable for short wrapper functions.
		graph::CallGraph cg = graph.get_callgraph();
		graph_tool::gt_dispatch<>()([&](auto& g) { this->do_cg_stuff(g, cg); },
		                            graph_tool::always_directed())(cg.graph.get_graph_view());

		// 3. Direct implementation within the lambda function.
		// Suitable for short inline code.
		graph::InstanceGraph instances = graph.get_instances();
		graph_tool::gt_dispatch<>()(
		    [&](auto& g) {
			    // if you need the Graph type
			    using Graph = typename std::remove_reference<decltype(g)>::type;
			    Graph& my_graph = g;
			    for (auto v : boost::make_iterator_range(boost::vertices(my_graph))) {
				    logger.debug() << "Instance: " << instances.label[v] << std::endl;
			    }
		    },
		    graph_tool::always_directed())(instances.graph.get_graph_view());
	}
} // namespace ara::step
