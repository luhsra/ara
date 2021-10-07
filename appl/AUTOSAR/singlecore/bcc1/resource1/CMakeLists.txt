DOSEK_BINARY(
  NAME bcc1_resource1a
  SYSTEM_DESC system.oil
  LIBS libtest
  VERIFY verify_a.py
  SOURCES
  a.cc
)

DOSEK_BINARY(
  NAME bcc1_resource1b
  SYSTEM_DESC system.oil
  LIBS libtest
  VERIFY verify_b.py
  SOURCES
  b.cc
)

DOSEK_BINARY(
  NAME bcc1_resource1c
  SYSTEM_DESC system.oil
  LIBS libtest
  VERIFY verify_a.py # Same constraints as A
  SOURCES
  c.cc
)

DOSEK_BINARY(
  NAME bcc1_resource1d
  SYSTEM_DESC system.oil
  LIBS libtest
  VERIFY verify_d.py
  SOURCES
  d.cc
)

DOSEK_BINARY(
  NAME bcc1_resource1e
  SYSTEM_DESC system.oil
  LIBS libtest
  VERIFY verify_e.py
  SOURCES
  e.cc
)

DOSEK_BINARY(
  NAME bcc1_resource1f
  SYSTEM_DESC system.oil
  LIBS libtest
  VERIFY verify_f.py
  SOURCES
  f.cc
)


DOSEK_BINARY(
  NAME bcc1_resource1g
  SYSTEM_DESC system.oil
  LIBS libtest
  VERIFY verify_g.py
  SOURCES
  g.cc
)

DOSEK_BINARY(
  NAME bcc1_resource1h
  SYSTEM_DESC system.oil
  LIBS libtest
  VERIFY verify_h.py
  SOURCES
  h.cc
)

DOSEK_BINARY(
  NAME bcc1_resource1j
  SYSTEM_DESC system.oil
  LIBS libtest
  #VERIFY verify_j.py
  SOURCES
  j.cc
)

DOSEK_BINARY(
  NAME bcc1_resource1k
  SYSTEM_DESC system.oil
  LIBS libtest
  VERIFY verify_k.py
  SOURCES
  k.cc
)