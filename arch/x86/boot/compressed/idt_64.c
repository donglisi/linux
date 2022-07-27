// SPDX-License-Identifier: GPL-2.0-only
#include <asm/trap_pf.h>
#include <asm/segment.h>
#include <asm/trapnr.h>
#include "misc.h"

static void set_idt_entry(int vector, void (*handler)(void))
{
}

/* Have this here so we don't need to include <asm/desc.h> */
static void load_boot_idt(const struct desc_ptr *dtr)
{
}

/* Setup IDT before kernel jumping to  .Lrelocated */
void load_stage1_idt(void)
{
}

void load_stage2_idt(void)
{
}

void cleanup_exception_handling(void)
{
}
