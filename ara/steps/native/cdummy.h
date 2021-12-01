// vim: set noet ts=4 sw=4:

#pragma once

#include "option.h"
#include "step.h"

#include <graph.h>

namespace ara::step {
	class CDummy : public ConfStep<CDummy> {
	  private:
		using ConfStep<CDummy>::ConfStep;

		template <typename Graph>
		void do_cg_stuff(Graph& g, graph::CallGraph& cg) {
			for (auto v : boost::make_iterator_range(boost::vertices(g))) {
				logger.debug() << "Function: " << cg.function_name[v] << std::endl;
			}
		}

		const static inline option::TOption<option::Integer> dummy_option_template{
		    "dummy_option", "This is the help for dummy_option."};
		option::TOptEntity<option::Integer> dummy_option;

		const static inline option::TOption<option::Choice<3>> dummy_option2_template{
		    "dummy_option2", "This is an option with default.",
		    /* ty = */ option::makeChoice("A", "B", "C"),
		    /* default_value = */ "B"};
		option::TOptEntity<option::Choice<3>> dummy_option2;

		virtual void init_options() override;

	  public:
		virtual ~CDummy(){};
		static std::string get_name() { return "CDummy"; }
		static std::string get_description();
		static Step::OptionVec get_local_options();

		virtual std::vector<std::string> get_single_dependencies() override { return {"Dummy"}; }

		virtual void run() override;
	};
} // namespace ara::step
