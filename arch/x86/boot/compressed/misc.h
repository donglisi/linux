/* SPDX-License-Identifier: GPL-2.0 */
#ifndef BOOT_COMPRESSED_MISC_H
#define BOOT_COMPRESSED_MISC_H

/*
 * Special hack: we have to be careful, because no indirections are allowed here,
 * and paravirt_ops is a kind of one. As it will only run in baremetal anyway,
 * we just keep it from happening. (This list needs to be extended when new
 * paravirt and debugging variants are added.)
 */
#undef CONFIG_PARAVIRT
#undef CONFIG_PARAVIRT_XXL
#undef CONFIG_PARAVIRT_SPINLOCKS
#undef CONFIG_KASAN
#undef CONFIG_KASAN_GENERIC

#define __NO_FORTIFY

#include <linux/linkage.h>
#include <linux/screen_info.h>
#include <linux/elf.h>
#include <asm/page.h>
#include <asm/boot.h>
#include <asm/bootparam.h>
#include <asm/desc_defs.h>

#define BOOT_CTYPE_H

#define BOOT_BOOT_H

#define memptr long

/* boot/compressed/vmlinux start and end markers */
extern char _head[], _end[];

/* misc.c */
extern memptr free_mem_ptr;
extern memptr free_mem_end_ptr;
void *malloc(int size);
void free(void *where);
extern struct boot_params *boot_params;

int cmdline_find_option(const char *option, char *buffer, int bufsize);
int cmdline_find_option_bool(const char *option);

extern unsigned char _pgtable[];

void kernel_add_identity_map(unsigned long start, unsigned long end);

#endif /* BOOT_COMPRESSED_MISC_H */
