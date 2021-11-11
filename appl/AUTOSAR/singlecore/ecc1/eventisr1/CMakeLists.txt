DOSEK_BINARY(
  NAME ecc1_eventisr1a
  SYSTEM_DESC system.oil
  VERIFY verify_a.py
  LIBS libtest
  GENERATOR_ARGS -fsse
  SOURCES
  a.cc
)


DOSEK_BINARY(
  NAME ecc1_eventisr1b
  SYSTEM_DESC system.oil
  VERIFY verify_b.py
  LIBS libtest
  GENERATOR_ARGS -fsse
  SOURCES
  b.cc
)

DOSEK_BINARY(
  NAME ecc1_eventisr1c
  SYSTEM_DESC system.oil
  VERIFY verify_c.py
  LIBS libtest
  GENERATOR_ARGS -fsse
  SOURCES
  c.cc
)

DOSEK_BINARY(
  NAME ecc1_eventisr1d
  SYSTEM_DESC system.oil
  VERIFY verify_d.py
  LIBS libtest
  GENERATOR_ARGS -fsse
  SOURCES
  d.cc
)

DOSEK_BINARY(
  NAME ecc1_eventisr1e
  SYSTEM_DESC system.oil
  GENERATOR_ARGS -fsse
  LIBS libtest
  SOURCES
  e.cc
)

DOSEK_BINARY(
  NAME ecc1_eventisr1f
  SYSTEM_DESC system.oil
  GENERATOR_ARGS -fsse
  LIBS libtest
  SOURCES
  f.cc
)
