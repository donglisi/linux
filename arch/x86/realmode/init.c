// SPDX-License-Identifier: GPL-2.0
#include <linux/io.h>
#include <linux/slab.h>
#include <linux/memblock.h>
#include <linux/cc_platform.h>
#include <linux/pgtable.h>

#include <asm/set_memory.h>
#include <asm/realmode.h>
#include <asm/tlbflush.h>
#include <asm/crash.h>
#include <asm/sev.h>

struct real_mode_header *real_mode_header;
u32 *trampoline_cr4_features;

/* Hold the pgd entry used on booting additional CPUs */
pgd_t trampoline_pgd_entry;

void load_trampoline_pgtable(void)
{
}

void __init reserve_real_mode(void)
{
}

static void __init sme_sev_setup_real_mode(struct trampoline_header *th)
{
}

static void __init setup_real_mode(void)
{
}

/*
 * reserve_real_mode() gets called very early, to guarantee the
 * availability of low memory. This is before the proper kernel page
 * tables are set up, so we cannot set page permissions in that
 * function. Also trampoline code will be executed by APs so we
 * need to mark it executable at do_pre_smp_initcalls() at least,
 * thus run it as a early_initcall().
 */
static void __init set_real_mode_permissions(void)
{
}

static int __init init_real_mode(void)
{
	return 0;
}
