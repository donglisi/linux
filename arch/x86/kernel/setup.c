#include <linux/memblock.h>
#include <linux/pci.h>
#include <asm/gart.h>

#include <asm/prom.h>

unsigned long max_pfn_mapped;

unsigned long _brk_start = (unsigned long)__brk_base;
unsigned long _brk_end   = (unsigned long)__brk_base;

struct boot_params boot_params;

struct cpuinfo_x86 boot_cpu_data __read_mostly;
EXPORT_SYMBOL(boot_cpu_data);

static char __initdata command_line[COMMAND_LINE_SIZE];

void * __init extend_brk(size_t size, size_t align)
{
	size_t mask = align - 1;
	void *ret;

	BUG_ON(_brk_start == 0);
	BUG_ON(align & mask);

	_brk_end = (_brk_end + mask) & ~mask;
	BUG_ON((char *)(_brk_end + size) > __brk_limit);

	ret = (void *)_brk_end;
	_brk_end += size;

	memset(ret, 0, size);

	return ret;
}

int __init setup_early_printk(char *buf);

void __init setup_arch(char **cmdline_p)
{
	memblock_reserve(0, (1024 << 10) * 16);

	e820__memory_setup();

	setup_early_printk("earlyprintk=serial");

	max_pfn = e820__end_of_ram_pfn();

	e820__memblock_setup();

	init_mem_mapping();

	paging_init();
}

