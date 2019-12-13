#pragma once

#include <functional>
#include <llvm/IR/Instructions.h>
#include <vector>

namespace ara {

	using MetaArguments = std::vector<std::reference_wrapper<const llvm::Constant>>;

	class Arguments : public MetaArguments {
	  private:
		std::vector<std::unique_ptr<const llvm::Constant>> owned_values;

	  public:
		using MetaArguments::MetaArguments;
		Arguments(const Arguments&) = delete;
		Arguments(Arguments&& o) : MetaArguments(std::move(o)), owned_values(std::move(o.owned_values)) {}

		void push_back(const llvm::Constant& c) { MetaArguments::push_back(c); }

		void push_back(std::unique_ptr<const llvm::Constant> value) {
			MetaArguments::push_back(std::ref(*value));
			owned_values.push_back(std::move(value));
		}

		void emplace_back(const llvm::Constant& c) { MetaArguments::emplace_back(c); }

		void emplace_back(std::unique_ptr<const llvm::Constant> value) {
			MetaArguments::emplace_back(std::ref(*value));
			owned_values.emplace_back(std::move(value));
		}
	};

} // namespace ara
