#include "warning.h"

std::string  Warning::print() const {
    std::string stream = "";
    if(warning_position!= nullptr)stream += "Warning at abb " + warning_position->get_name() + ":\n";
    stream += print_warning();
    return stream;
}
