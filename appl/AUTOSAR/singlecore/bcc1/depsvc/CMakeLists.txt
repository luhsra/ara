if( (${CONFIG_ARCH} STREQUAL "posix") OR (${CONFIG_ARCH} STREQUAL "i386") )
  DOSEK_BINARY (
    NAME bcc1_depsvc
    LIBS libdepsvc libtest
    SYSTEM_DESC system.oil
    TEST disable
    SOURCES depsvc.cc
    )
endif()
