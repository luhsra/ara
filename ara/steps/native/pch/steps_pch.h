#ifndef ARA_STEP_PCH_H
#define ARA_STEP_PCH_H

// extracted with:
// rg "#include <" -N -I -g '!pch' | sort | uniq

// clang-format off
#include <graph_tool.hh> // this must stand at the beginning, see https://git.skewed.de/count0/graph-tool/-/issues/704
// clang-format on

#include <Graphs/ICFG.h>
#include <Graphs/PAG.h>
#include <Graphs/PTACallGraph.h>
#include <Graphs/VFGNode.h>
#include <Python.h>
#include <SVF-FE/BreakConstantExpr.h>
#include <SVF-FE/PAGBuilder.h>
#include <Util/BasicTypes.h>
#include <Util/SVFUtil.h>
#include <WPA/Andersen.h>
#include <assert.h>
#include <boost/algorithm/string.hpp>
#include <boost/bimap.hpp>
#include <boost/functional/hash.hpp>
#include <boost/graph/filtered_graph.hpp>
#include <boost/iterator/iterator_facade.hpp>
#include <boost/property_tree/json_parser.hpp>
#include <boost/python.hpp>
#include <boost/range/adaptor/indexed.hpp>
#include <boost/range/adaptor/map.hpp>
#include <boost/type_traits.hpp>
#include <cassert>
#include <common/llvm_common.h>
#include <filesystem>
#include <fstream>
#include <functional>
#include <graph.h>
#include <graph_tool.hh>
#include <iostream>
#include <list>
#include <llvm/ADT/GraphTraits.h>
#include <llvm/ADT/SCCIterator.h>
#include <llvm/Analysis/CFGPrinter.h>
#include <llvm/Analysis/LoopInfo.h>
#include <llvm/IR/BasicBlock.h>
#include <llvm/IR/CFG.h>
#include <llvm/IR/Function.h>
#include <llvm/IR/IRBuilder.h>
#include <llvm/IR/Instructions.h>
#include <llvm/IR/Intrinsics.h>
#include <llvm/IR/LegacyPassManager.h>
#include <llvm/IR/Module.h>
#include <llvm/IR/PassManager.h>
#include <llvm/IR/TypeFinder.h>
#include <llvm/IR/Value.h>
#include <llvm/IRReader/IRReader.h>
#include <llvm/Linker/Linker.h>
#include <llvm/Passes/PassBuilder.h>
#include <llvm/Support/Casting.h>
#include <llvm/Support/Error.h>
#include <llvm/Support/FileSystem.h>
#include <llvm/Support/JSON.h>
#include <llvm/Support/SourceMgr.h>
#include <llvm/Support/raw_os_ostream.h>
#include <llvm/Support/raw_ostream.h>
#include <llvm/Transforms/Utils.h>
#include <llvm/Transforms/Utils/BasicBlockUtils.h>
#include <llvm/Transforms/Utils/UnifyFunctionExitNodes.h>
#include <map>
#include <memory>
#include <optional>
#include <pyllco.h>
#include <queue>
#include <sstream>
#include <stdexcept>
#include <string>
#include <tuple>
#include <type_traits>
#include <typeinfo>
#include <unordered_set>
#include <utility>
#include <variant>
#include <vector>

#endif // ARA_STEP_PCH_H
