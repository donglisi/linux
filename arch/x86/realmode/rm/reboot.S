/* SPDX-License-Identifier: GPL-2.0 */
#include <linux/linkage.h>
#include <asm/segment.h>
#include <asm/page_types.h>
#include <asm/processor-flags.h>
#include <asm/msr-index.h>
#include "realmode.h"

/*
 * The following code and data reboots the machine by switching to real
 * mode and jumping to the BIOS reset entry point, as if the CPU has
 * really been reset.  The previous version asked the keyboard
 * controller to pulse the CPU reset line, which is more thorough, but
 * doesn't work with at least one type of 486 motherboard.  It is easy
 * to stop this code working; hence the copious comments.
 *
 * This code is called with the restart type (0 = BIOS, 1 = APM) in
 * the primary argument register (%eax for 32 bit, %edi for 64 bit).
 */
	.section ".text32", "ax"
	.code32
SYM_CODE_START(machine_real_restart_asm)
SYM_CODE_END(machine_real_restart_asm)

/*
 * This is 16-bit protected mode code to disable paging and the cache,
 * switch to real mode and jump to the BIOS reset code.
 *
 * The instruction that switches to real mode by writing to CR0 must be
 * followed immediately by a far jump instruction, which set CS to a
 * valid value for real mode, and flushes the prefetch queue to avoid
 * running instructions that have already been decoded in protected
 * mode.
 *
 * Clears all the flags except ET, especially PG (paging), PE
 * (protected-mode enable) and TS (task switch for coprocessor state
 * save).  Flushes the TLB after paging has been disabled.  Sets CD and
 * NW, to disable the cache on a 486, and invalidates the cache.  This
 * is more like the state of a 486 after reset.  I don't know if
 * something else should be done for other chips.
 *
 * More could be done here to set up the registers as if a CPU reset had
 * occurred; hopefully real BIOSs don't assume much.  This is not the
 * actual BIOS entry point, anyway (that is at 0xfffffff0).
 *
 * Most of this work is probably excessive, but it is what is tested.
 */
	.text
	.code16

	.balign	16
SYM_DATA_START(machine_real_restart_idt)
SYM_DATA_END(machine_real_restart_idt)

	.balign	16
SYM_DATA_START(machine_real_restart_gdt)
SYM_DATA_END(machine_real_restart_gdt)
