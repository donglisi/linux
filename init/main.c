#include <linux/list.h>
#include <linux/mmzone.h>
#include <linux/memblock.h>

#include <asm/setup.h>

enum system_states system_state __read_mostly;

bool static_key_initialized __read_mostly;

/* Report memory auto-initialization states for this boot. */
static void __init report_meminit(void)
{
	const char *stack;

	if (IS_ENABLED(CONFIG_INIT_STACK_ALL_PATTERN))
		stack = "all(pattern)";
	else if (IS_ENABLED(CONFIG_INIT_STACK_ALL_ZERO))
		stack = "all(zero)";
	else if (IS_ENABLED(CONFIG_GCC_PLUGIN_STRUCTLEAK_BYREF_ALL))
		stack = "byref_all(zero)";
	else if (IS_ENABLED(CONFIG_GCC_PLUGIN_STRUCTLEAK_BYREF))
		stack = "byref(zero)";
	else if (IS_ENABLED(CONFIG_GCC_PLUGIN_STRUCTLEAK_USER))
		stack = "__user(zero)";
	else
		stack = "off";

	pr_info("mem auto-init: stack:%s, heap alloc:%s, heap free:%s\n",
		stack, want_init_on_alloc(GFP_KERNEL) ? "on" : "off",
		want_init_on_free() ? "on" : "off");
	if (want_init_on_free())
		pr_info("mem auto-init: clearing system memory may take some time...\n");
}

/*
 * Set up kernel memory allocators
 */
static void __init mm_init(void)
{
	report_meminit();
	mem_init();
	mem_init_print_info();
}

extern struct pglist_data contig_page_data;
static void __init print_buddy_info(void)
{
	struct zone *zone = contig_page_data.node_zonelists[0]._zonerefs[0].zone;

	printk("10 %u\t\t9 %u\t\t8 %u\t\t7 %u\t\t6 %u\t\t5 %u\t\t4 %u\t\t3 %u\t\t2 %u\t\t1 %u\t\t0 %u\n",
			zone->free_area[10].nr_free, zone->free_area[9].nr_free, zone->free_area[8].nr_free,
			zone->free_area[7].nr_free, zone->free_area[6].nr_free, zone->free_area[5].nr_free,
			zone->free_area[4].nr_free, zone->free_area[3].nr_free, zone->free_area[2].nr_free,
			zone->free_area[1].nr_free, zone->free_area[0].nr_free);
}

static void test_buddy(void)
{
	struct page *p;
	void *addr;
	int order;
	int i = 0;

	for (order = 0; order < 11; order++) {
		p = alloc_pages(GFP_KERNEL, order);
		addr = page_to_virt(p);
		printk("addr %llx %llx %u %d\n", addr, virt_to_phys(addr), page_to_pfn(p), i++);
		memset(addr, 0xf4, 4096 << order);
		if (order == 10)
			order = -1;
	}
}

static void test_buddy2(void)
{
	struct page *p;

	print_buddy_info();
	p = alloc_pages(GFP_KERNEL, 10);
	print_buddy_info();
	p = alloc_pages(GFP_KERNEL, 9);
	print_buddy_info();
	p = alloc_pages(GFP_KERNEL, 8);
	print_buddy_info();
	p = alloc_pages(GFP_KERNEL, 5);
	print_buddy_info();
	p = alloc_pages(GFP_KERNEL, 0);
	print_buddy_info();
	while (1)
		asm("hlt;");
}

asmlinkage __visible void __init __no_sanitize_address start_kernel(void)
{
	setup_arch(NULL);

	build_all_zonelists(NULL);

	mm_init();

	test_buddy();
}
