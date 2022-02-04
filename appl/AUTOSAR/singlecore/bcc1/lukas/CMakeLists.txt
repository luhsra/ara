DOSEK_BINARY(
  NAME bcc1_lukas_dispatch
  SYSTEM_DESC dispatch.oil
  LIBS libtest
  SOURCES
  dispatch.cc
)


DOSEK_BINARY(
  NAME bcc1_lukas_alarmstress
  SYSTEM_DESC alarmstress.oil
  LIBS libtest
  SOURCES
  alarmstress.cc
)

DOSEK_BINARY(
  NAME bcc1_lukas_isr2
  SYSTEM_DESC isr2.oil
  LIBS libtest
  SOURCES
  isr2.cc
)

