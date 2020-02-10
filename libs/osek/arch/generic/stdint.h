#ifndef __ARCH_GENERIC_STDINT_H
#define __ARCH_GENERIC_STDINT_H

/* This is a fixup for the following problem:

   - gcc always defines the __UINT* types when it generates defines
   for the __INT* types
   - clang does this not, just because trollin
   - therefore we define the same types, just as unsigned, if they do not exist and do a force
   include for this file.
*/

#ifdef __INT8_TYPE__
#ifndef __UINT8_TYPE__
#define __UINT8_TYPE__ unsigned __INT8_TYPE__
#endif
#endif

#ifdef __INT16_TYPE__
#ifndef __UINT16_TYPE__
#define __UINT16_TYPE__ unsigned __INT16_TYPE__
#endif
#endif

#ifdef __INT32_TYPE__
#ifndef __UINT32_TYPE__
#define __UINT32_TYPE__ unsigned __INT32_TYPE__
#endif
#endif

#ifdef __INT64_TYPE__
#ifndef __UINT64_TYPE__
#define __UINT64_TYPE__ unsigned __INT64_TYPE__
#endif
#endif

#ifdef __INTPTR_TYPE__
#ifndef __UINTPTR_TYPE__
#define __UINTPTR_TYPE__ unsigned __INTPTR_TYPE__
#endif
#endif

typedef __UINT8_TYPE__   uint8_t;
typedef __UINT16_TYPE__  uint16_t;
typedef __UINT32_TYPE__  uint32_t;
typedef __UINT64_TYPE__  uint64_t;
typedef __UINTPTR_TYPE__ uintptr_t;

typedef __UINTPTR_TYPE__    size_t;

typedef __INT8_TYPE__   int8_t;
typedef __INT16_TYPE__  int16_t;
typedef __INT32_TYPE__  int32_t;
typedef __INT64_TYPE__  int64_t;
typedef __INTPTR_TYPE__ intptr_t;

typedef __INTPTR_TYPE__ ptrdiff_t;


#endif
