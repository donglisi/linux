// SPDX-License-Identifier: GPL-2.0
#include "misc.h"
#include <asm/e820/types.h>
#include <asm/processor.h>
#include "pgtable.h"
#include "../string.h"

struct paging_config {
	unsigned long trampoline_start;
	unsigned long l5_required;
};

/*
 * Trampoline address will be printed by extract_kernel() for debugging
 * purposes.
 *
 * Avoid putting the pointer into .bss as it will be cleared between
 * paging_prepare() and extract_kernel().
 */
unsigned long *trampoline_32bit __section(".data");

extern struct boot_params *boot_params;
int cmdline_find_option_bool(const char *option);

struct paging_config paging_prepare(void *rmode)
{
	struct paging_config paging_config = {};

	/* Initialize boot_params. Required for cmdline_find_option_bool(). */
	boot_params = rmode;

	paging_config.trampoline_start = 0x9d000;

	trampoline_32bit = (unsigned long *)paging_config.trampoline_start;

	/* Clear trampoline memory first */
	memset(trampoline_32bit, 0, TRAMPOLINE_32BIT_SIZE);

	/* Copy trampoline code in place */
	memcpy(trampoline_32bit + TRAMPOLINE_32BIT_CODE_OFFSET / sizeof(unsigned long),
			&trampoline_32bit_src, TRAMPOLINE_32BIT_CODE_SIZE);

	unsigned long src;

	src = *(unsigned long *)__native_read_cr3() & PAGE_MASK;
	memcpy(trampoline_32bit, (void *)src, PAGE_SIZE);

out:
	return paging_config;
}
