#include "merge_structs.h"

#include <string>
#include <regex>
#include <llvm/IR/Attributes.h>
#include <llvm/IR/Instructions.h>
#include <llvm/IR/Constants.h>
#include <llvm/IR/LLVMContext.h>
#include <llvm/IR/Module.h>
#include <llvm/IR/Function.h>
#include <llvm/IRReader/IRReader.h>
#include <llvm/Support/SourceMgr.h>
#include <llvm/Support/InitLLVM.h>
#include <llvm/Support/TargetSelect.h>
#include <llvm/Support/raw_ostream.h>
#include <llvm/Support/CommandLine.h>
#include <llvm/ExecutionEngine/ExecutionEngine.h>
#include <llvm/ExecutionEngine/MCJIT.h>
#include <llvm/ExecutionEngine/GenericValue.h>
#include <llvm/Transforms/Utils/Cloning.h>
#include <llvm/ADT/APInt.h>
#include <llvm/ADT/StringRef.h>
#include <llvm/IR/DerivedTypes.h>
#include <llvm/IR/IRBuilder.h>
#include <llvm/IR/Type.h>
#include <llvm/IR/Verifier.h>
#include <llvm/IR/GlobalVariable.h>
#include <llvm/IR/GetElementPtrTypeIterator.h>
#include <llvm/IR/DebugInfoMetadata.h>
#include <llvm/IR/DebugInfo.h>
#include <llvm/Support/Host.h>
#include <llvm/Support/Debug.h>
#include <llvm/Linker/Linker.h>
#include <llvm/Support/FileSystem.h>
#include <llvm/IR/Value.h>
#include "llvm/Transforms/Utils/ValueMapper.h"

#include <common/llvm_common.h>
#include <os.h>

using namespace std;
using namespace llvm;

namespace ara::step {

	Type *ValueMapTypeRemapperImpl::remapType(Type *SrcTy) {
		for (auto &m : map) {
			if (SrcTy == m.first) {
				return m.second;
			}
		}
		
		// TODO move array and pointer handling to here
		
		return SrcTy;
	}

	std::string MergeStructs::get_description() {
		return "Merges duplicates of structs to make all system call signatures unified.\n";
	}

	void MergeStructs::collectStructs(Module& M) {
		for (StructType* ST : M.getIdentifiedStructTypes()) {
			if (ST->hasName()) {
				std::string name = ST->getName().str();
				std::regex structRegex("^struct\\.(\\S+)\\.[0-9]+");
				std::smatch match;
				if (std::regex_match(name, match, structRegex)) {
					std::string stName = match.str(1);
					for (auto& allow : StructNames) {
						if (stName == allow) {
							structs[stName].push_back(ST);
						}
					}
				}
			}
		}
	}

	Function *MergeStructs::replaceFunctionReturnType(Function *oldFunc, Module &M) {
        return replaceFunctionArgumentType(oldFunc, M);
    }
    
    Function *MergeStructs::replaceFunctionArgumentType(Function *oldFunc, Module &M) {
        FunctionType *oldType = oldFunc->getFunctionType();
        Type *returnType = TypeMapper.remapType(oldType->getReturnType());
        vector<Type *> newArgs;
        
        for(auto &p : oldType->params()) {
            newArgs.push_back(TypeMapper.remapType(p));
        }
        
        FunctionType *newType = FunctionType::get(returnType, newArgs, oldType->isVarArg());
        Function *newFunc = Function::Create(newType, oldFunc->getLinkage(), oldFunc->getName(), M);
        
        if(!oldFunc->isDeclaration()) {
            ValueToValueMapTy VMap;
            
            IRBuilder<> Builder(oldFunc->getContext());
            
            auto oldArg = oldFunc->arg_begin();
            auto newArg = newFunc->arg_begin();
            for (; oldArg != oldFunc->arg_end(); ++oldArg, ++newArg) {
                newArg->setName(oldArg->getName());
                VMap[&*oldArg] = &*newArg;
            }
            
            SmallVector<ReturnInst*, 8> Returns;
            CloneFunctionInto(newFunc, oldFunc, VMap, CloneFunctionChangeType::GlobalChanges, Returns, "", nullptr, &TypeMapper);
        }
        
        oldFunc->replaceAllUsesWith(newFunc);
        auto oldName = oldFunc->getName();
        oldFunc->setName(oldName + ".removed");
        newFunc->setName(oldName);
        
        return newFunc;
    }
    
    Constant* MergeStructs::convertInitializer(Constant *OldInitializer) {
        Type *newTy = TypeMapper.remapType(OldInitializer->getType());
        if(ConstantStruct *CS = dyn_cast<ConstantStruct>(OldInitializer)) {
            std::vector<Constant *> args;
            for(unsigned i = 0; i < CS->getNumOperands(); ++i) {
                Constant *Element = CS->getOperand(i);
                args.push_back(convertInitializer(Element));
            }
            
            return ConstantStruct::get(cast<StructType>(newTy), args);
        } else if(ConstantArray *CS = dyn_cast<ConstantArray>(OldInitializer)) {
            std::vector<Constant *> args;
            for(unsigned i = 0; i < CS->getNumOperands(); ++i) {
                Constant *Element = CS->getOperand(i);
                Element = convertInitializer(Element);
                args.push_back(Element);
            }
            
            newTy = TypeMapper.remapType(OldInitializer->getType()->getArrayElementType());
            return ConstantArray::get(ArrayType::get(newTy, args.size()), args);
        }
        
        Constant *NewInitializer = ConstantExpr::getBitCast(OldInitializer, newTy);
        return NewInitializer;
    }
        
    void MergeStructs::findStructTypeUses(StructType *current, StructType *ST, Module &M) {
        std::list<GlobalVariable*> removeGlobals;

        for (GlobalVariable &GV : M.globals()) {
            if (GV.getValueType() == ST
                || (GV.getValueType()->isPointerTy() && GV.getValueType()->getPointerElementType() == ST)
                || (GV.getValueType()->isArrayTy() && GV.getValueType()->getArrayElementType() == ST)) {
                Constant *NewInitializer = nullptr;
                if (GV.hasInitializer()) {
                    Constant *OldInitializer = GV.getInitializer();
                    NewInitializer = convertInitializer(OldInitializer);
                }
                
                Type *Ty = current;
                if(GV.getValueType()->isArrayTy()) {
                    ArrayType *AT = cast<ArrayType>(GV.getValueType());
                    Ty = ArrayType::get(Ty, AT->getNumElements());
                }
                
                if(GV.getType()->isPointerTy()){
                    if(GV.getType()->getPointerElementType()->isPointerTy()){
                        Ty = PointerType::get(Ty, 0);
                    }
                }

                auto name = GV.getName();
                GlobalVariable *NewGV = new GlobalVariable(
                    M,
                    Ty,
                    GV.isConstant(),
                    GV.getLinkage(),
                    NewInitializer,
                    name,
                    &GV,
                    GV.getThreadLocalMode(),
                    GV.getAddressSpace()
                );
                
                NewGV->setAlignment(GV.getAlign());
                NewGV->setUnnamedAddr(GV.getUnnamedAddr());
                NewGV->setSection(GV.getSection());
                NewGV->setDSOLocal(GV.isDSOLocal());
                
                SmallVector<std::pair<unsigned, MDNode *>, 1> MDs;
                GV.getAllMetadata(MDs);
                
                ValueToValueMapTy VMap;
                for (auto MD : MDs) {
                    NewGV->addMetadata(MD.first, *MapMetadata(MD.second, VMap));
                }
                
                GV.replaceAllUsesWith(NewGV);
                // GV.eraseFromParent();
                removeGlobals.push_back(&GV);
                
                GV.setName(name + ".removed");
                NewGV->setName(name);
            }
        }
        
        for(auto GV : removeGlobals) {
            GV->eraseFromParent();
        }
    }
    
    void MergeStructs::insertType(Type* ST, Type* current) {
        if(ST->isPointerTy()) {
            ST = ST->getPointerElementType();
        }
        
        if(current->isPointerTy()) {
            current = current->getPointerElementType();
        }
        
        TypeMapper.map.insert(pair(ST, current));
        PointerType *pST = PointerType::get(ST, 0);
        PointerType *pCurrent = PointerType::get(current, 0);
        TypeMapper.map.insert(pair(pST, pCurrent));
        TypeMapper.map.insert(pair(
            (Type*) PointerType::get(pST, 0),
            (Type*) PointerType::get(pCurrent, 0)
        ));
    }
        
    void MergeStructs::replaceStructs(Module &M) {
        std::map<StructType *, StructType *> AllreplaceMapST;
        
        for (auto const& map : structs) {
            StructType *current = nullptr;
            for (auto &ST : map.second) {
                if (ST->hasName()) {
                    if(current == nullptr) {
                        current = ST;
                        ST->setName("struct." + map.first);
                        continue;
                    }
                    
                    // dbgs() << "replacing " << ST->getName().str() << " -> " << current->getName().str() << "\n";
                    
                    std::map<StructType *, StructType *> replaceMapST = replaceEmbeddedStruct(M, current, ST);
                    
                    for(auto &e : replaceMapST) {
                        insertType(e.first, e.second);
                        AllreplaceMapST.insert(e);
                    }
                    
                    insertType(ST, current);
                }
            }
        }
        
        for (auto const& map : structs) {
            StructType *current = nullptr;
            for (auto &ST : map.second) {
                if (ST->hasName()) {
                    if(current == nullptr) {
                        current = ST;
                        continue;
                    }
                    findStructTypeUses(current, ST, M);

                    for(auto &e : AllreplaceMapST) {
                        findStructTypeUses(e.second, e.first, M);
                    }
                }
            }
        }
        
        std::list<Function*> removeFunctions;
        vector<Function*> functions;
        for (Function &F : M.functions()) {
            functions.push_back(&F);
        }
        
        for (Function *F : functions) {
            if(F->getName().startswith("llvm")) continue;

            replaceFunctionArgumentType(F, M);
            removeFunctions.push_back(F);
        }

        for(auto oldFunc : removeFunctions) {
            oldFunc->eraseFromParent();
        }
        
        vector<Instruction*> removeInstructions;
        
        for (Function &F : M.functions()) {
            for (auto &BB : F) {
            ValueToValueMapTy VMapBB;
                for (auto &Inst : BB) {
                    if (auto *GEPI = dyn_cast<GetElementPtrInst>(&Inst)) {
                        Type *sourceTy = GEPI->getSourceElementType();
                        Type *newTy = TypeMapper.remapType(sourceTy);
                        
                        if(sourceTy->isArrayTy()) {
                            newTy = ArrayType::get(TypeMapper.remapType(sourceTy->getArrayElementType()), sourceTy->getArrayNumElements());
                        }
                        
                        if(sourceTy != newTy) {
                            GEPI->setSourceElementType(newTy);
                        }
                    }
                    if (auto *CI = dyn_cast<CallInst>(&Inst)) {
                        if (auto *BC = dyn_cast<BitCastOperator>(CI->getCalledOperand())) {
                            IRBuilder<> Builder(CI);
                            if(FunctionType *FT = cast<FunctionType>(BC->getDestTy()->getPointerElementType())) {
                                bool replace = false;
                                vector<Type*> args;
                                for(auto &T : FT->params()) {
                                    Type *newType = TypeMapper.remapType(T);
                                    args.push_back(newType);
                                    if(newType != T) {
                                        replace = true;
                                    }
                                }
                                
                                if(!replace) {
                                    continue;
                                }
                                
                                Function *CalleeF = dyn_cast<Function>(BC->getOperand(0));
                                PointerType *newFTP = PointerType::get(CalleeF->getFunctionType(), 0);
                                auto *NewBC = Builder.CreateBitCast(CalleeF, newFTP);
                                SmallVector<Value *, 4> Args(CI->args());
                                auto name = CI->getName();
                                CI->setName(name + ".remove");
                                CallInst *NewCall = Builder.CreateCall(CalleeF->getFunctionType(), NewBC, Args, name);
                                size_t i = 0;
                                for(auto &a : CalleeF->args()) {
                                    if(a.hasAttribute(Attribute::NoUndef)) {
                                        NewCall->addParamAttr(i++, Attribute::NoUndef);
                                    }
                                }
                                VMapBB[CI] = NewCall;
                                llvm::RemapInstruction(CI, VMapBB, RF_ReuseAndMutateDistinctMDs);
                                CI->replaceAllUsesWith(NewCall);
                                removeInstructions.push_back(CI);                
                            }
                        }
                    }
                }
            }
        }
        
        for(auto *I : removeInstructions) {
            I->eraseFromParent();
        }
    }
    
    vector<vector<size_t>> MergeStructs::searchStructType(StructType *current, StructType *target, vector<size_t> indices) {
        vector<vector<size_t>> foundAt;
        for(indices.push_back(0); indices.back() < current->getNumElements(); ++indices.back()) {
            bool pointer = false;
            Type *e = current->getElementType(indices.back());
            if(PointerType *PTy = dyn_cast<PointerType>(e)) {
                e = e->getPointerElementType();
                pointer = true;
            }
            if(StructType *STy = dyn_cast<StructType>(e)) {
                if(STy == target) {
                    foundAt.push_back(indices);
                }
                if(!pointer) {
                    auto newFoundAt = searchStructType(STy, target, indices);
                    foundAt.insert(foundAt.end(), newFoundAt.begin(), newFoundAt.end());
                }
            }
        }
        return foundAt;
    }

    bool MergeStructs::testIndices(vector<vector<size_t>> at, vector<size_t> indices) {
        for(vector<size_t> i : at) {
            if(i == indices) {
                return true;
            }
        }
        return false;
    }
    
    Type* MergeStructs::cloneStructType(StructType *root, StructType *replaceWith, vector<vector<size_t>> at, vector<size_t> indices) {
        std::vector<Type *> elements;
        
        Type *T = root;
        for(size_t i : indices) {
            T = dyn_cast<StructType>(T)->getElementType(i);
        }
        
        if(StructType *ST = dyn_cast<StructType>(T)) {
            bool replaced = false;
            for(indices.push_back(0); indices.back() < ST->getNumElements(); ++indices.back()) {
                if(!testIndices(at, indices)) {
                    elements.push_back(cloneStructType(root, replaceWith, at, indices));
                } else {
                    Type *Ty = replaceWith;
                    Type *elementTy = ST->getElementType(indices.back());
                    if(elementTy->isPointerTy()){
                        Ty = PointerType::get(Ty, 0);
                        if(elementTy->getPointerElementType()->isPointerTy()){
                            Ty = PointerType::get(Ty, 0);
                        }
                    }
                    elements.push_back(Ty);
                    replaced = true;
                }
            }
            if(replaced) {
                return StructType::create(root->getContext(), elements, ST->getName());
            }
        }
        
        return T;
    }
    
    StructType* MergeStructs::getReplacementStruct(StructType *root, StructType *replaceWith, StructType *ST) {
        StructType *STNew = nullptr;
        vector<size_t> indices;
        vector<vector<size_t>> foundAt = searchStructType(root, ST, indices);
        if(!foundAt.empty()) {
            indices.clear();
            STNew = dyn_cast<StructType>(cloneStructType(root, replaceWith, foundAt, indices));
        }
        
        return STNew;
    }
    
    std::map<StructType *, StructType *> MergeStructs::replaceEmbeddedStruct(Module &M, StructType* replaceWith, StructType* ST) {
        std::map<StructType *, StructType *> replace;
        
        for (StructType *root : M.getIdentifiedStructTypes()) {
            StructType *replacementST = getReplacementStruct(root, replaceWith, ST);
            
            if(replacementST) {
                auto name = root->getName();
                root->setName(name.str() + ".removed");
                replacementST->setName(name);
                
                replace.insert(pair(root, replacementST));
            }
        }
        
        return replace;
    }

    void MergeStructs::processModule(Module &M) {
        collectStructs(M);
        replaceStructs(M);
    }


	void MergeStructs::run() {
		Module& module = graph.get_module();

        processModule(module);

		assert(!llvm::verifyModule(module, &llvm::errs()) && "LLVM-IR Module has errors");

		if (*dump.get()) {
			std::string ir_file = *dump_prefix.get() + "ll";
			llvm::json::Value ir_printer_conf(llvm::json::Object{{"name", "IRWriter"}, {"ir_file", ir_file}});
			step_manager.chain_step(ir_printer_conf);
		}
	}
} // namespace ara::step
