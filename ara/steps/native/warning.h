// SPDX-FileCopyrightText: 2019 Benedikt Steinmeier
// SPDX-FileCopyrightText: 2020 Gerion Entrup <entrup@sra.uni-hannover.de>
//
// SPDX-License-Identifier: GPL-3.0-or-later

#pragma once

#include <assert.h>
class Warning {

  public:
	const llvm::Instruction& warning_position;
	Warning(const llvm::Instruction& pos) : warning_position(pos) {}

	virtual std::string print_warning() const = 0;
	virtual std::string get_type() const = 0;

	std::string print() const {

		std::string stream = "";
		// stream += "Warning at abb " + warning_position->get_name() + ":\n";
		stream += print_warning();
		return stream;
	};

	virtual ~Warning(){};
};

typedef std::shared_ptr<Warning> shared_warning;

class DumbArgumentWarning : public Warning {

  private:
	int argument_index = 0;

  public:
	DumbArgumentWarning(int index, const llvm::Instruction& pos) : Warning(pos), argument_index(index) {}
	virtual std::string get_type() const override { return "DumpArgument"; }

	virtual std::string print_warning() const override {
		std::string stream = "";
		stream + "Argument at index " + std::to_string(argument_index) + " could not dump" + "\n";
		return stream;
	};
};
