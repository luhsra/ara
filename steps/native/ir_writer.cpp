// vim: set noet ts=4 sw=4:

#include "ir_writer.h"


namespace ara::step {

	// ATTENTION: put in anonymous namespace to get an unique symbol
	namespace {
		template <typename Graph>
		void do_graph_stuff(Graph& g, graph::CFG& cfg, Logger& logger) {
			for (auto v : boost::make_iterator_range(boost::vertices(g))) {
				logger.debug() << "Vertex: " << cfg.name[v] << std::endl;
			}
		}
	} // namespace

	std::string IRWriter::get_description() const {
		return "Print current IR code to file.";
	}

	void IRWriter::fill_options() { opts.emplace_back(ir_file_option); }

	void IRWriter::run(graph::Graph& graph) {
		logger.info() << "Execute IRWriter step." << std::endl;

		const auto& filename = ir_file_option.get();
		logger.info() << "Writing IR to " << *filename << '.' << std::endl;

		std::error_code error;
		llvm::raw_fd_ostream out_file(*filename, error, llvm::sys::fs::OpenFlags::OF_Text);
		if (out_file.has_error()) {
			logger.err() << out_file.error() << std::endl;
			out_file.close();
			std::abort();
		}
		graph.get_module().print(out_file, nullptr);
		out_file.close();

	}
} // namespace ara::step
