/*
 * Copyright (C) 2009 Thomas Gleixner <tglx@linutronix.de>
 *
 *  For licencing details see kernel-base/COPYING
 */
#include <linux/init.h>
#include <linux/ioport.h>
#include <linux/export.h>
#include <linux/pci.h>

#include <asm/acpi.h>
#include <asm/bios_ebda.h>
#include <asm/paravirt.h>
#include <asm/pci_x86.h>
#include <asm/mpspec.h>
#include <asm/setup.h>
#include <asm/apic.h>
#include <asm/e820/api.h>
#include <asm/time.h>
#include <asm/irq.h>
#include <asm/io_apic.h>
#include <asm/hpet.h>
#include <asm/memtype.h>
#include <asm/tsc.h>
#include <asm/iommu.h>
#include <asm/mach_traps.h>
#include <asm/irqdomain.h>

void x86_init_noop(void) { }

/*
 * The platform setup functions are preset with the default functions
 * for standard PC hardware.
 */
struct x86_init_ops x86_init __initdata = {
	.resources = {
		.probe_roms		= probe_roms,
		.memory_setup		= e820__memory_setup_default,
	},

	.paging = {
		.pagetable_init		= native_pagetable_init,
	},
};

static void enc_status_change_prepare_noop(unsigned long vaddr, int npages, bool enc) { }
static bool enc_status_change_finish_noop(unsigned long vaddr, int npages, bool enc) { return false; }
static bool enc_tlb_flush_required_noop(bool enc) { return false; }
static bool enc_cache_flush_required_noop(void) { return false; }
