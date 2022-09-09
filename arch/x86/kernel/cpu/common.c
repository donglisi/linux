#include <asm/mmu_context.h>

DEFINE_PER_CPU_PAGE_ALIGNED(struct gdt_page, gdt_page) = { .gdt = {
	/*
	 * We need valid kernel segments for data and code in long mode too
	 * IRET will check the segment types  kkeil 2000/10/28
	 * Also sysret mandates a special GDT layout
	 *
	 * TLS descriptors are currently at a different place compared to i386.
	 * Hopefully nobody expects them at a fixed place (Wine?)
	 */
	[GDT_ENTRY_KERNEL32_CS]		= GDT_ENTRY_INIT(0xc09b, 0, 0xfffff),
	[GDT_ENTRY_KERNEL_CS]		= GDT_ENTRY_INIT(0xa09b, 0, 0xfffff),
	[GDT_ENTRY_KERNEL_DS]		= GDT_ENTRY_INIT(0xc093, 0, 0xfffff),
	[GDT_ENTRY_DEFAULT_USER32_CS]	= GDT_ENTRY_INIT(0xc0fb, 0, 0xfffff),
	[GDT_ENTRY_DEFAULT_USER_DS]	= GDT_ENTRY_INIT(0xc0f3, 0, 0xfffff),
	[GDT_ENTRY_DEFAULT_USER_CS]	= GDT_ENTRY_INIT(0xa0fb, 0, 0xfffff),
} };
EXPORT_PER_CPU_SYMBOL_GPL(gdt_page);

DEFINE_PER_CPU_FIRST(struct fixed_percpu_data,
		     fixed_percpu_data) __aligned(PAGE_SIZE) __visible;

struct task_struct init_task;
/*
 * The following percpu variables are hot.  Align current_task to
 * cacheline size such that they fall in the same cacheline.
 */
DEFINE_PER_CPU(struct task_struct *, current_task) ____cacheline_aligned =
	&init_task;
EXPORT_PER_CPU_SYMBOL(current_task);

DEFINE_PER_CPU(int, __preempt_count) = INIT_PREEMPT_COUNT;
