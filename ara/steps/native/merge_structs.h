#pragma once

#include "step.h"
#include <map>
#include <list>
#include <string>

#include "llvm/IR/Function.h"
#include "llvm/IR/Module.h"
#include "llvm/Transforms/Utils/ValueMapper.h"

#include <Python.h>
#include <graph.h>

namespace ara::step {

	class ValueMapTypeRemapperImpl: public llvm::ValueMapTypeRemapper {
	public:
		llvm::Type *remapType(llvm::Type*);
		std::map<llvm::Type*, llvm::Type*> map;
	};

	class MergeStructs : public ConfStep<MergeStructs> {
		using ConfStep<MergeStructs>::ConfStep;
		ValueMapTypeRemapperImpl TypeMapper;
		std::map<std::string, std::vector<llvm::StructType *>> structs;
		
		std::list<std::string> StructNames = {
			"k_sem",
			"k_mutex",
			"k_msgq",
			"k_thread",
			"k_timer",
		};

		void collectStructs(llvm::Module& M);
		llvm::Function *replaceFunctionReturnType(llvm::Function *oldFunc, llvm::Module &M);
		llvm::Function *replaceFunctionArgumentType(llvm::Function *oldFunc, llvm::Module &M);
		llvm::Constant* convertInitializer(llvm::Constant *OldInitializer);
		void findStructTypeUses(llvm::StructType *current, llvm::StructType *ST, llvm::Module &M);
		void insertType(llvm::Type* ST, llvm::Type* current);
		void replaceStructs(llvm::Module &M);
		bool testIndices(std::vector<std::vector<size_t>> at, std::vector<size_t> indices);
		std::vector<std::vector<size_t>> searchStructType(llvm::StructType *current, llvm::StructType *target, std::vector<size_t> indices);
		llvm::Type* cloneStructType(llvm::StructType *root, llvm::StructType *replaceWith, std::vector<std::vector<size_t>> at, std::vector<size_t> indices);
		llvm::StructType* getReplacementStruct(llvm::StructType *root, llvm::StructType *replaceWith, llvm::StructType *ST);
		std::map<llvm::StructType *, llvm::StructType *> replaceEmbeddedStruct(llvm::Module &M, llvm::StructType* replaceWith, llvm::StructType* ST);
		void processModule(llvm::Module &M);

	  public:
		static std::string get_name() { return "MergeStructs"; }
		static std::string get_description();
		static Step::OptionVec get_local_options() { return {}; }

		 std::vector<std::string> get_single_dependencies() override { return {"IRReader"}; }

		 void run() override;
	};
} // namespace ara::step
