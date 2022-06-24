obj-y		+= access.o bus.o probe.o host-bridge.o \
				   remove.o pci.o pci-driver.o search.o \
				   pci-sysfs.o rom.o setup-res.o irq.o vpd.o \
				   setup-bus.o vc.o mmap.o setup-irq.o

obj-y		+= msi/
obj-y		+= pcie/

obj-y += proc.o
obj-y += slot.o

obj-$(CONFIG_OF)		+= of.o
obj-y	+= quirks.o
obj-$(CONFIG_PCI_ATS)		+= ats.o
obj-$(CONFIG_PCI_IOV)		+= iov.o
obj-$(CONFIG_PCI_BRIDGE_EMUL)	+= pci-bridge-emul.o
obj-y		+= pci-label.o
obj-$(CONFIG_X86_INTEL_MID)	+= pci-mid.o
obj-$(CONFIG_PCI_SYSCALL)	+= syscall.o
obj-$(CONFIG_PCI_STUB)		+= pci-stub.o
obj-$(CONFIG_PCI_PF_STUB)	+= pci-pf-stub.o
obj-$(CONFIG_PCI_ECAM)		+= ecam.o
obj-$(CONFIG_PCI_P2PDMA)	+= p2pdma.o
obj-$(CONFIG_XEN_PCIDEV_FRONTEND) += xen-pcifront.o
obj-y		+= vgaarb.o

subdir-ccflags-$(CONFIG_PCI_DEBUG) := -DDEBUG
