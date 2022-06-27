# SPDX-License-Identifier: GPL-2.0

obj-y := irqdesc.o handle.o manage.o spurious.o resend.o chip.o dummychip.o devres.o
obj-$(CONFIG_IRQ_TIMINGS) += timings.o
ifeq ($(CONFIG_TEST_IRQ_TIMINGS),y)
	CFLAGS_timings.o += -DDEBUG
endif
obj-$(CONFIG_GENERIC_IRQ_CHIP) += generic-chip.o
obj-y += autoprobe.o
obj-y += irqdomain.o
obj-$(CONFIG_IRQ_SIM) += irq_sim.o
obj-y += proc.o
obj-y += migration.o
obj-y += cpuhotplug.o
obj-$(CONFIG_PM_SLEEP) += pm.o
obj-$(CONFIG_GENERIC_MSI_IRQ) += msi.o
obj-$(CONFIG_GENERIC_IRQ_IPI) += ipi.o
obj-y += affinity.o
obj-$(CONFIG_GENERIC_IRQ_DEBUGFS) += debugfs.o
obj-y += matrix.o
