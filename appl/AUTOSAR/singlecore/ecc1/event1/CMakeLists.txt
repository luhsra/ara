DOSEK_BINARY(
  NAME ecc1_event1a
  SYSTEM_DESC system.oil
  VERIFY verify_a.py
  LIBS libtest
  GENERATOR_ARGS -fsse
  SOURCES
  a.cc
)

DOSEK_BINARY(
  NAME ecc1_event1b
  SYSTEM_DESC system.oil
  VERIFY verify_b.py
  LIBS libtest
  GENERATOR_ARGS -fsse
  SOURCES
  b.cc
)

DOSEK_BINARY(
  NAME ecc1_event1c
  SYSTEM_DESC system.oil
  VERIFY verify_c.py
  LIBS libtest
  GENERATOR_ARGS -fsse
  SOURCES
  c.cc
)

DOSEK_BINARY(
  NAME ecc1_event1d
  SYSTEM_DESC system.oil
  VERIFY verify_d.py
  LIBS libtest
  GENERATOR_ARGS -fsse
  SOURCES
  d.cc
)

DOSEK_BINARY(
  NAME ecc1_event1e
  SYSTEM_DESC system.oil
  VERIFY verify_e.py
  LIBS libtest
  GENERATOR_ARGS -fsse
  SOURCES
  e.cc
)

DOSEK_BINARY(
  NAME ecc1_event1f
  SYSTEM_DESC system.oil
  LIBS libtest
  GENERATOR_ARGS -fsse
  SOURCES
  f.cc
)

DOSEK_BINARY(
  NAME ecc1_event1g
  SYSTEM_DESC system.oil
  LIBS libtest
  GENERATOR_ARGS -fsse
  SOURCES
  g.cc
)
