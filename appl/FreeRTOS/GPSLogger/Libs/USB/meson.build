src_files = [
  'Core/usbd_conf.c',
  'Core/usbd_core.c',
  'Core/usbd_ctlreq.c',
  'Core/usbd_desc.c',
  'Core/usbd_ioreq.c',
  'CDC/usbd_cdc.c',
  'CDC/usbd_cdc_if.c',
  'MSC/usbd_msc.c',
  'MSC/usbd_msc_bot.c',
  'MSC/usbd_msc_data.c',
  'MSC/usbd_msc_scsi.c',
  'MSC_CDC/usbd_msc_cdc.c',
]

libusb_targets = []
foreach file : src_files
  libusb_targets += gpslogger_compile.process(file)
endforeach

libusb = custom_target('libusb-link',
                       input: libusb_targets,
                       output: 'libusb.ll',
                       command: llvm_link_cmd
                      )

gpslogger_libs += libusb
