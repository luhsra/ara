#define MIX 1 /*
# NOTE: This is a special file that can be read from Python and C++.
# It is used to define common enums between the Python model and C++ model.
import enum
class ABBType(enum.IntEnum): # */
    #undef pass
    #define pass namespace ara::graph { enum ABBType {
    pass

    not_implemented = 0,
    syscall = 0b1,
    call = 0b10,
    computation = 0b100,

    #undef pass
    #define pass };}
    pass


#undef MIX
#define MIX 1 /*
# lcf = local control flow
# icf = interprocedural control flow
# gcf = global control flow
# f2a = function to ABB
# a2f = ABB to function
import enum
class CFType(enum.IntEnum): # */
    #undef pass
    #define pass namespace ara::graph { enum CFType {
    pass

    lcf = 0,
    icf = 1,
    gcf = 2,
    f2a = 3,
    a2f = 4

    #undef pass
    #define pass };}
    pass
