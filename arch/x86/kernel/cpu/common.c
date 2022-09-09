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

/* These bits should not change their value after CPU init is finished. */
static const unsigned long cr4_pinned_mask =
	X86_CR4_SMEP | X86_CR4_SMAP | X86_CR4_UMIP |
	X86_CR4_FSGSBASE | X86_CR4_CET;
static DEFINE_STATIC_KEY_FALSE_RO(cr_pinning);
static unsigned long cr4_pinned_bits __ro_after_init;

void native_write_cr0(unsigned long val)
{
	unsigned long bits_missing = 0;

set_register:
	asm volatile("mov %0,%%cr0": "+r" (val) : : "memory");

	if (static_branch_likely(&cr_pinning)) {
		if (unlikely((val & X86_CR0_WP) != X86_CR0_WP)) {
			bits_missing = X86_CR0_WP;
			val |= bits_missing;
			goto set_register;
		}
		/* Warn after we've set the missing bits. */
		WARN_ONCE(bits_missing, "CR0 WP bit went missing!?\n");
	}
}
EXPORT_SYMBOL(native_write_cr0);

void __no_profile native_write_cr4(unsigned long val)
{
	unsigned long bits_changed = 0;

set_register:
	asm volatile("mov %0,%%cr4": "+r" (val) : : "memory");

	if (static_branch_likely(&cr_pinning)) {
		if (unlikely((val & cr4_pinned_mask) != cr4_pinned_bits)) {
			bits_changed = (val & cr4_pinned_mask) ^ cr4_pinned_bits;
			val = (val & ~cr4_pinned_mask) | cr4_pinned_bits;
			goto set_register;
		}
		/* Warn after we've corrected the changed bits. */
		WARN_ONCE(bits_changed, "pinned CR4 bits changed: 0x%lx!?\n",
			  bits_changed);
	}
}

DEFINE_PER_CPU_FIRST(struct fixed_percpu_data,
		     fixed_percpu_data) __aligned(PAGE_SIZE) __visible;
EXPORT_PER_CPU_SYMBOL_GPL(fixed_percpu_data);

struct task_struct init_task;
/*
 * The following percpu variables are hot.  Align current_task to
 * cacheline size such that they fall in the same cacheline.
 */
DEFINE_PER_CPU(struct task_struct *, current_task) ____cacheline_aligned =
	&init_task;
EXPORT_PER_CPU_SYMBOL(current_task);

DEFINE_PER_CPU(void *, hardirq_stack_ptr);
DEFINE_PER_CPU(bool, hardirq_stack_inuse);

DEFINE_PER_CPU(int, __preempt_count) = INIT_PREEMPT_COUNT;
EXPORT_PER_CPU_SYMBOL(__preempt_count);

DEFINE_PER_CPU(unsigned long, cpu_current_top_of_stack) = TOP_OF_INIT_STACK;
