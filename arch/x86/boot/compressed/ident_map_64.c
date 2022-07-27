// SPDX-License-Identifier: GPL-2.0
/*
 * This code is used on x86_64 to create page table identity mappings on
 * demand by building up a new set of page tables (or appending to the
 * existing ones), and then switching over to them when ready.
 *
 * Copyright (C) 2015-2016  Yinghai Lu
 * Copyright (C)      2016  Kees Cook
 */

/*
 * Since we're dealing with identity mappings, physical and virtual
 * addresses are the same, so override these defines which are ultimately
 * used by the headers in misc.h.
 */
#define __pa(x)  ((unsigned long)(x))
#define __va(x)  ((void *)((unsigned long)(x)))

/* No PAGE_TABLE_ISOLATION support needed either: */
#undef CONFIG_PAGE_TABLE_ISOLATION

#include "error.h"
#include "misc.h"

/* These actually do the work of building the kernel identity maps. */
#include <linux/pgtable.h>
#include <asm/cmpxchg.h>
#include <asm/trap_pf.h>
#include <asm/trapnr.h>
#include <asm/init.h>
/* Use the static base for this part of the boot process */
#undef __PAGE_OFFSET
#define __PAGE_OFFSET __PAGE_OFFSET_BASE
#include "../../mm/ident_map.c"

#define _SETUP
#include <asm/setup.h>	/* For COMMAND_LINE_SIZE */
#undef _SETUP

extern unsigned long get_cmd_line_ptr(void);

/* Used by PAGE_KERN* macros: */
pteval_t __default_kernel_pte_mask __read_mostly = ~0;

/* Used to track our page table allocation area. */
struct alloc_pgt_data {
	unsigned char *pgt_buf;
	unsigned long pgt_buf_size;
	unsigned long pgt_buf_offset;
};

/*
 * Allocates space for a page table entry, using struct alloc_pgt_data
 * above. Besides the local callers, this is used as the allocation
 * callback in mapping_info below.
 */
static void *alloc_pgt_page(void *context)
{
	return 0;
}

/* Used to track our allocated page tables. */
static struct alloc_pgt_data pgt_data;

/* The top level page table entry pointer. */
static unsigned long top_level_pgt;

phys_addr_t physical_mask = (1ULL << __PHYSICAL_MASK_SHIFT) - 1;

/*
 * Mapping information structure passed to kernel_ident_mapping_init().
 * Due to relocation, pointers must be assigned at run time not build time.
 */
static struct x86_mapping_info mapping_info;

/*
 * Adds the specified range to the identity mappings.
 */
void kernel_add_identity_map(unsigned long start, unsigned long end)
{
}

/* Locates and clears a region for a new top level page table. */
void initialize_identity_maps(void *rmode)
{
}

static pte_t *split_large_pmd(struct x86_mapping_info *info,
			      pmd_t *pmdp, unsigned long __address)
{
	return 0;
}

static void clflush_page(unsigned long address)
{
}

static int set_clr_page_flags(struct x86_mapping_info *info,
			      unsigned long address,
			      pteval_t set, pteval_t clr)
{
	return 0;
}

int set_page_decrypted(unsigned long address)
{
	return set_clr_page_flags(&mapping_info, address, 0, _PAGE_ENC);
}

int set_page_encrypted(unsigned long address)
{
	return set_clr_page_flags(&mapping_info, address, _PAGE_ENC, 0);
}

int set_page_non_present(unsigned long address)
{
	return set_clr_page_flags(&mapping_info, address, 0, _PAGE_PRESENT);
}

void do_boot_page_fault(struct pt_regs *regs, unsigned long error_code)
{
}
