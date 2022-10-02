/* SPDX-License-Identifier: GPL-2.0 */
#ifndef __X86_MM_INTERNAL_H
#define __X86_MM_INTERNAL_H

void *alloc_low_pages(unsigned int num);
static inline void *alloc_low_page(void)
{
	return alloc_low_pages(1);
}

unsigned long kernel_physical_mapping_init(unsigned long start,
					     unsigned long end,
					     unsigned long page_size_mask,
					     pgprot_t prot);
void zone_sizes_init(void);

#endif	/* __X86_MM_INTERNAL_H */
