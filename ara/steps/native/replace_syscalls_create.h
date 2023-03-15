// SPDX-FileCopyrightText: 2021 Bastian Fuhlenriede
// SPDX-FileCopyrightText: 2021 Björn Fiedler <fiedler@sra.uni-hannover.de>
// SPDX-FileCopyrightText: 2021 Gerion Entrup <entrup@sra.uni-hannover.de>
//
// SPDX-License-Identifier: GPL-3.0-or-later

// vim: set noet ts=4 sw=4:

#pragma once

#include "step.h"

#include <boost/python.hpp>
#include <graph.h>
#include <llvm/IR/Function.h>
#include <llvm/IR/IRBuilder.h>
#include <llvm/IR/Value.h>

namespace ara::step {
	class ReplaceSyscallsCreate : public ConfStep<ReplaceSyscallsCreate> {
	  private:
		using ConfStep<ReplaceSyscallsCreate>::ConfStep;

		PyObject* handle_tcb_ref_param(llvm::IRBuilder<>& Builder, llvm::Value* tcb_ref, llvm::Value* the_tcb);
		PyObject* replace_call_with_true(llvm::CallBase* call);
		llvm::Function* get_fn(const char* name);
		llvm::BasicBlock* create_bb(boost::python::object task);
		PyObject* replace_call_with_activate(llvm::CallBase* call, llvm::Value* tcb);
		PyObject* replace_task_create_static(boost::python::object o);
		PyObject* replace_task_create_initialized(boost::python::object o);
		PyObject* replace_queue_create_static(boost::python::object o);
		PyObject* replace_queue_create_initialized(boost::python::object o);
		PyObject* replace_mutex_create_static(boost::python::object o);
		PyObject* replace_mutex_create_initialized(boost::python::object o);
		PyObject* change_linkage_to_global(llvm::GlobalVariable* gv);

		PyObject* replace_mutex_create(boost::python::object pyo_task);
		PyObject* replace_queue_create(boost::python::object pyo_task);
		PyObject* replace_task_create(boost::python::object pyo_task);

	  public:
		virtual ~ReplaceSyscallsCreate(){};
		static std::string get_name() { return "ReplaceSyscallsCreate"; }
		static std::string get_description();

		virtual std::vector<std::string> get_single_dependencies() override { return {}; }

		virtual void run() override;
	};
} // namespace ara::step
