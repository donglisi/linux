#include <linux/start_kernel.h>

#include <asm/setup.h>
#include <asm/desc.h>
#include <asm/tlbflush.h>
#include <asm/sections.h>

/*
 * Manage page tables very early on.
 */
extern pmd_t early_dynamic_pgts[EARLY_DYNAMIC_PAGE_TABLES][PTRS_PER_PMD];
static unsigned int __initdata next_early_pgt;
pmdval_t early_pmd_flags = __PAGE_KERNEL_LARGE & ~(_PAGE_GLOBAL | _PAGE_NX);

/*
 * GDT used on the boot CPU before switching to virtual addresses.
 */
static struct desc_struct startup_gdt[GDT_ENTRIES] = {
	[GDT_ENTRY_KERNEL32_CS]         = GDT_ENTRY_INIT(0xc09b, 0, 0xfffff),
	[GDT_ENTRY_KERNEL_CS]           = GDT_ENTRY_INIT(0xa09b, 0, 0xfffff),
	[GDT_ENTRY_KERNEL_DS]           = GDT_ENTRY_INIT(0xc093, 0, 0xfffff),
};

/*
 * Address needs to be set at runtime because it references the startup_gdt
 * while the kernel still uses a direct mapping.
 */
static struct desc_ptr startup_gdt_descr = {
	.size = sizeof(startup_gdt),
	.address = 0,
};

#define __head	__section(".head.text")

static void __head *fixup_pointer(void *ptr, unsigned long physaddr)
{
	return ptr - 0xffffffff80000000ULL;
}

/* Code in __startup_64() can be relocated during execution, but the compiler
 * doesn't have to generate PC-relative relocations when accessing globals from
 * that function. Clang actually does not generate them, which leads to
 * boot-time crashes. To work around this problem, every global pointer must
 * be adjusted using fixup_pointer().
 */
unsigned long __head __startup_64(unsigned long physaddr,
				  struct boot_params *bp)
{
	unsigned long *p;
	unsigned long pgtable_flags;
	pgdval_t *pgd;
	p4dval_t *p4d;
	pudval_t *pud;
	pmdval_t *pmd, pmd_entry;
	pteval_t *mask_ptr;
	int i;
	unsigned int *next_pgt_ptr;

	// asm("movq %0, %%rax" : : "b" (physaddr) : "rax");

	/* Fixup the physical addresses in the page table */
	pgd = fixup_pointer(&early_top_pgt, physaddr);
	p = pgd + pgd_index(__START_KERNEL_map);
	*p = (unsigned long)level3_kernel_pgt;
	*p += _PAGE_TABLE_NOENC - __START_KERNEL_map;

	pud = fixup_pointer(&level3_kernel_pgt, physaddr);

	pmd = fixup_pointer(level2_fixmap_pgt, physaddr);

	/*
	 * Set up the identity mapping for the switchover.  These
	 * entries should *NOT* have the global bit set!  This also
	 * creates a bunch of nonsense entries but that is fine --
	 * it avoids problems around wraparound.
	 */

	next_pgt_ptr = fixup_pointer(&next_early_pgt, physaddr);
	pud = fixup_pointer(early_dynamic_pgts[(*next_pgt_ptr)++], physaddr);
	pmd = fixup_pointer(early_dynamic_pgts[(*next_pgt_ptr)++], physaddr);

	pgtable_flags = _KERNPG_TABLE_NOENC;

	i = (physaddr >> PGDIR_SHIFT) % PTRS_PER_PGD;
	pgd[i + 0] = (pgdval_t)pud + pgtable_flags;
	pgd[i + 1] = (pgdval_t)pud + pgtable_flags;

	i = physaddr >> PUD_SHIFT;
	pud[(i + 0) % PTRS_PER_PUD] = (pudval_t)pmd + pgtable_flags;
	pud[(i + 1) % PTRS_PER_PUD] = (pudval_t)pmd + pgtable_flags;

	pmd_entry = __PAGE_KERNEL_LARGE_EXEC & ~_PAGE_GLOBAL;
	/* Filter out unsupported __PAGE_KERNEL_* bits: */
	mask_ptr = fixup_pointer(&__supported_pte_mask, physaddr);
	pmd_entry &= *mask_ptr;
	pmd_entry +=  physaddr;

	for (i = 0; i < DIV_ROUND_UP(_end - _text, PMD_SIZE); i++) {
		int idx = i + (physaddr >> PMD_SHIFT);
		pmd[idx % PTRS_PER_PMD] = pmd_entry + i * PMD_SIZE;
	}

	/*
	 * Fixup the kernel text+data virtual addresses. Note that
	 * we might write invalid pmds, when the kernel is relocated
	 * cleanup_highmap() fixes this up along with the mappings
	 * beyond _end.
	 *
	 * Only the region occupied by the kernel image has so far
	 * been checked against the table of usable memory regions
	 * provided by the firmware, so invalidate pages outside that
	 * region. A page table entry that maps to a reserved area of
	 * memory would allow processor speculation into that area,
	 * and on some hardware (particularly the UV platform) even
	 * speculative access to some reserved areas is caught as an
	 * error, causing the BIOS to halt the system.
	 */

	pmd = fixup_pointer(level2_kernel_pgt, physaddr);

	/* invalidate pages before the kernel image */
	for (i = 0; i < pmd_index((unsigned long)_text); i++)
		pmd[i] &= ~_PAGE_PRESENT;

	/* fixup pages that are part of the kernel image */
	for (; i <= pmd_index((unsigned long)_end); i++)
		;

	/* invalidate pages after the kernel image */
	for (; i < PTRS_PER_PMD; i++)
		pmd[i] &= ~_PAGE_PRESENT;

	return 0;
}

/* Wipe all early page tables except for the kernel symbol map */
static void __init reset_early_page_tables(void)
{
	memset(early_top_pgt, 0, sizeof(pgd_t)*(PTRS_PER_PGD-1));
	next_early_pgt = 0;
	write_cr3(__pa_nodebug(early_top_pgt));
}

/* Create a new PMD entry */
bool __init __early_make_pgtable(unsigned long address, pmdval_t pmd)
{
	pgdval_t *pgd_p;
	pudval_t *pud_p;
	pmdval_t *pmd_p;

	pgd_p = &early_top_pgt[pgd_index(address)].pgd;

	pud_p = (pudval_t *)early_dynamic_pgts[next_early_pgt++];
	memset(pud_p, 0, sizeof(*pud_p) * PTRS_PER_PUD);
	*pgd_p = (p4dval_t)pud_p - __START_KERNEL_map + phys_base + _KERNPG_TABLE;
	pud_p += pud_index(address);

	pmd_p = (pmdval_t *)early_dynamic_pgts[next_early_pgt++];
	memset(pmd_p, 0, sizeof(*pmd_p) * PTRS_PER_PMD);
	*pud_p = (pudval_t)pmd_p - __START_KERNEL_map + phys_base + _KERNPG_TABLE;
	pmd_p[pmd_index(address)] = pmd;

	return true;
}

static bool __init early_make_pgtable(unsigned long address)
{
	unsigned long physaddr = address - __PAGE_OFFSET;
	pmdval_t pmd;

	pmd = (physaddr & PMD_MASK) + early_pmd_flags;

	return __early_make_pgtable(address, pmd);
}

void __init do_early_exception(struct pt_regs *regs, int trapnr)
{
	early_make_pgtable(native_read_cr2());
}

/* Don't add a printk in there. printk relies on the PDA which is not initialized 
   yet. */
void __init clear_bss(void)
{
	memset(__bss_start, 0,
	       (unsigned long) __bss_stop - (unsigned long) __bss_start);
	memset(__brk_base, 0,
	       (unsigned long) __brk_limit - (unsigned long) __brk_base);
}

static unsigned long get_cmd_line_ptr(void)
{
	unsigned long cmd_line_ptr = boot_params.hdr.cmd_line_ptr;

	cmd_line_ptr |= (u64)boot_params.ext_cmd_line_ptr << 32;

	return cmd_line_ptr;
}

static void __init copy_bootdata(char *real_mode_data)
{
	char * command_line;
	unsigned long cmd_line_ptr;

	memcpy(&boot_params, real_mode_data, sizeof(boot_params));
	cmd_line_ptr = get_cmd_line_ptr();
	if (cmd_line_ptr) {
		command_line = __va(cmd_line_ptr);
		memcpy(boot_command_line, command_line, COMMAND_LINE_SIZE);
	}
}

asmlinkage __visible void __init x86_64_start_kernel(char * real_mode_data)
{
	cr4_init_shadow();

	/* Kill off the identity-map trampoline */
	reset_early_page_tables();

	clear_bss();

	/*
	 * This needs to happen *before* kasan_early_init() because latter maps stuff
	 * into that page.
	 */
	clear_page(init_top_pgt);

	idt_setup_early_handler();

	copy_bootdata(__va(real_mode_data));

	/* set init_top_pgt kernel high mapping*/
	init_top_pgt[511] = early_top_pgt[511];

	/* version is always not zero if it is copied */
	if (!boot_params.hdr.version)
		copy_bootdata(__va(real_mode_data));

	start_kernel();
}

/*
 * Data structures and code used for IDT setup in head_64.S. The bringup-IDT is
 * used until the idt_table takes over. On the boot CPU this happens in
 * x86_64_start_kernel(), on secondary CPUs in start_secondary(). In both cases
 * this happens in the functions called from head_64.S.
 *
 * The idt_table can't be used that early because all the code modifying it is
 * in idt.c and can be instrumented by tracing or KASAN, which both don't work
 * during early CPU bringup. Also the idt_table has the runtime vectors
 * configured which require certain CPU state to be setup already (like TSS),
 * which also hasn't happened yet in early CPU bringup.
 */
static gate_desc bringup_idt_table[NUM_EXCEPTION_VECTORS] __page_aligned_data;

static struct desc_ptr bringup_idt_descr = {
	.size		= (NUM_EXCEPTION_VECTORS * sizeof(gate_desc)) - 1,
	.address	= 0, /* Set at runtime */
};

/* This runs while still in the direct mapping */
static void startup_64_load_idt(unsigned long physbase)
{
	struct desc_ptr *desc = fixup_pointer(&bringup_idt_descr, physbase);
	gate_desc *idt = fixup_pointer(bringup_idt_table, physbase);
	desc->address = (unsigned long)idt;
	native_load_idt(desc);
}

/* This is used when running on kernel addresses */
void early_setup_idt(void)
{
	bringup_idt_descr.address = (unsigned long)bringup_idt_table;
	native_load_idt(&bringup_idt_descr);
}

/*
 * Setup boot CPU state needed before kernel switches to virtual addresses.
 */
void __head startup_64_setup_env(unsigned long physbase)
{
	/* Load GDT */
	startup_gdt_descr.address = (unsigned long)fixup_pointer(startup_gdt, physbase);
	native_load_gdt(&startup_gdt_descr);

	/* New GDT is live - reload data segment registers */
	asm volatile("movl %%eax, %%ds\n"
		     "movl %%eax, %%ss\n"
		     "movl %%eax, %%es\n" : : "a"(__KERNEL_DS) : "memory");

	startup_64_load_idt(physbase);
}
