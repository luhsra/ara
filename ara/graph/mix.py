#include <ostream>

#define EQUAL_OPERATOR(Name) bool operator==(const Name&, const int); bool operator==(const int, const Name&);
#define NOT_EQUAL_OPERATOR(Name) bool operator!=(const Name&, const int); bool operator!=(const int, const Name&);
#define STREAM_OPERATOR(Name) std::ostream& operator<<(std::ostream&, const Name&);
#define STANDARD_OPERATORS(Name) EQUAL_OPERATOR(Name) NOT_EQUAL_OPERATOR(Name) STREAM_OPERATOR(Name)
#define MIX 1 /*
# NOTE: This is a special file that can be read from Python and C++.
# It is used to define common enums between the Python model and C++ model.
import enum
class ABBType(enum.IntEnum): # */
    #undef pass
    #define pass namespace ara::graph { enum class ABBType {
    pass

    not_implemented = 0,
    syscall = 0b1,
    call = 0b10,
    computation = 0b100,

    #undef pass
    #define pass }; STANDARD_OPERATORS(ABBType)}
    pass


#undef MIX
#define MIX 1 /*
# lcf = local control flow
# icf = interprocedural control flow
# gcf = global control flow
# f2a = function to ABB
# a2f = ABB to function
class CFType(enum.IntEnum): # */
    #undef pass
    #define pass namespace ara::graph { enum class CFType {
    pass

    lcf = 0,
    icf = 1,
    gcf = 2,
    f2a = 3,
    a2f = 4

    #undef pass
    #define pass }; STANDARD_OPERATORS(CFType)}
    pass

#undef MIX
#define MIX 1 /*
# undefined = as the name says
# every = syscall belongs to every category
# create = syscall creates an instance
# comm = syscall is causes some kind of communication
# ATTENTION: This enum must kept in sync with syscall_category.inc
class SyscallCategory(enum.IntEnum): # */
    #undef pass
    #define pass namespace ara::graph { enum class SyscallCategory {
    pass

    undefined = 0,
    every  = 0b11,
    create = 0b10,
    comm   = 0b01,

    #undef pass
    #define pass }; STANDARD_OPERATORS(SyscallCategory)}
    pass

#undef MIX
#define MIX 1 /*
# Signature Type, whether the syscall argument is expected to be a value or
# symbol
#
# undefined = as the name says
# every = syscall belongs to every category
# create = syscall creates an instance
# comm = syscall is causes some kind of communication
# ATTENTION: This enum must kept in sync with syscall_category.inc
class SigType(enum.IntEnum): # */
    #undef pass
    #define pass namespace ara::graph { enum class SigType {
    pass

    undefined = 0,
    value = 1,
    symbol = 2,

    #undef pass
    #define pass }; STANDARD_OPERATORS(SigType)}
    pass

#undef MIX

#undef EQUAL_OPERATOR
#undef NOT_EQUAL_OPERATOR
#undef STREAM_OPERATOR
#undef STANDARD_OPERATORS
