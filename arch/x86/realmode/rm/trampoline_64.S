/* SPDX-License-Identifier: GPL-2.0 */
/*
 *
 *	Trampoline.S	Derived from Setup.S by Linus Torvalds
 *
 *	4 Jan 1997 Michael Chastain: changed to gnu as.
 *	15 Sept 2005 Eric Biederman: 64bit PIC support
 *
 *	Entry: CS:IP point to the start of our code, we are
 *	in real mode with no stack, but the rest of the
 *	trampoline page to make our stack and everything else
 *	is a mystery.
 *
 *	On entry to trampoline_start, the processor is in real mode
 *	with 16-bit addressing and 16-bit data.  CS has some value
 *	and IP is zero.  Thus, data addresses need to be absolute
 *	(no relocation) and are taken with regard to r_base.
 *
 *	With the addition of trampoline_level4_pgt this code can
 *	now enter a 64bit kernel that lives at arbitrary 64bit
 *	physical addresses.
 *
 *	If you work on this file, check the object module with objdump
 *	--full-contents --reloc to make sure there are no relocation
 *	entries.
 */

#include <linux/linkage.h>
#include <asm/pgtable_types.h>
#include <asm/page_types.h>
#include <asm/msr.h>
#include <asm/segment.h>
#include <asm/processor-flags.h>
#include <asm/realmode.h>
#include "realmode.h"

	.text
	.code16

	.balign	PAGE_SIZE
SYM_CODE_START(trampoline_start)
SYM_CODE_END(trampoline_start)

#ifdef CONFIG_AMD_MEM_ENCRYPT
/* SEV-ES supports non-zero IP for entry points - no alignment needed */
SYM_CODE_START(sev_es_trampoline_start)
SYM_CODE_END(sev_es_trampoline_start)
#endif	/* CONFIG_AMD_MEM_ENCRYPT */

#include "../kernel/verify_cpu.S"

	.section ".text32","ax"
	.code32
	.balign 4
SYM_CODE_START(startup_32)
SYM_CODE_END(startup_32)

SYM_CODE_START(pa_trampoline_compat)
SYM_CODE_END(pa_trampoline_compat)

	.section ".text64","ax"
	.code64
	.balign 4
SYM_CODE_START(startup_64)
	# Now jump into the kernel using virtual addresses
	jmpq	*tr_start(%rip)
SYM_CODE_END(startup_64)

SYM_CODE_START(trampoline_start64)
SYM_CODE_END(trampoline_start64)

	.section ".rodata","a"
	# Duplicate the global descriptor table
	# so the kernel can live anywhere
	.balign	16
SYM_DATA_START(tr_gdt)
SYM_DATA_END_LABEL(tr_gdt, SYM_L_LOCAL, tr_gdt_end)

SYM_DATA_START(tr_gdt64)
SYM_DATA_END(tr_gdt64)

SYM_DATA_START(tr_compat)
SYM_DATA_END(tr_compat)

	.bss
	.balign	PAGE_SIZE
SYM_DATA(trampoline_pgd, .space PAGE_SIZE)

	.balign	8
SYM_DATA_START(trampoline_header)
	SYM_DATA_LOCAL(tr_start,	.space 8)
	SYM_DATA(tr_efer,		.space 8)
	SYM_DATA(tr_cr4,		.space 4)
	SYM_DATA(tr_flags,		.space 4)
SYM_DATA_END(trampoline_header)
