obj-y := block/virtio_blk.o net/loopback.o clocksource/i8253.o
obj-y += $(addprefix virtio/, virtio.o virtio_ring.o virtio_pci_modern_dev.o virtio_pci_modern.o virtio_pci_common.o)
obj-y += $(addprefix tty/, tty_io.o n_tty.o tty_ioctl.o tty_ldisc.o tty_buffer.o tty_port.o tty_mutex.o  tty_ldsem.o tty_baudrate.o tty_jobctrl.o n_null.o pty.o hvc/hvc_console.o)
obj-y += $(addprefix rtc/, lib.o rtc-mc146818-lib.o)
obj-y += $(addprefix char/, mem.o random.o misc.o virtio_console.o)
obj-y += $(addprefix pci/, access.o bus.o probe.o host-bridge.o remove.o pci.o pci-driver.o search.o pci-sysfs.o \
		rom.o setup-res.o irq.o vpd.o setup-bus.o vc.o mmap.o setup-irq.o proc.o $(addprefix msi/, pcidev_msi.o msi.o irqdomain.o))
obj-y += $(addprefix base/, component.o core.o bus.o dd.o syscore.o driver.o class.o platform.o cpu.o firmware.o \
		init.o map.o devres.o attribute_container.o transport_class.o topology.o container.o property.o \
		cacheinfo.o swnode.o devtmpfs.o $(addprefix firmware_loader/, main.o builtin/main.o))
