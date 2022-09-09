#include <linux/crash_dump.h>
#include <linux/memblock.h>
#include <linux/suspend.h>
#include <linux/acpi.h>
#include <linux/firmware-map.h>
#include <linux/sort.h>
#include <linux/memory_hotplug.h>

#include <asm/e820/api.h>
#include <asm/setup.h>

static struct e820_table e820_table_init		__initdata;

struct e820_table *e820_table __refdata			= &e820_table_init;

/*
 * Add a memory region to the kernel E820 map.
 */
static void __init __e820__range_add(struct e820_table *table, u64 start, u64 size, enum e820_type type)
{
	int x = table->nr_entries;

	if (x >= ARRAY_SIZE(table->entries)) {
		pr_err("too many entries; ignoring [mem %#010llx-%#010llx]\n",
		       start, start + size - 1);
		return;
	}

	table->entries[x].addr = start;
	table->entries[x].size = size;
	table->entries[x].type = type;
	table->nr_entries++;
}

void __init e820__range_add(u64 start, u64 size, enum e820_type type)
{
	__e820__range_add(e820_table, start, size, type);
}

static void __init e820_print_type(enum e820_type type)
{
	switch (type) {
	case E820_TYPE_RAM:		/* Fall through: */
	case E820_TYPE_RESERVED_KERN:	pr_cont("usable");			break;
	case E820_TYPE_RESERVED:	pr_cont("reserved");			break;
	case E820_TYPE_SOFT_RESERVED:	pr_cont("soft reserved");		break;
	case E820_TYPE_ACPI:		pr_cont("ACPI data");			break;
	case E820_TYPE_NVS:		pr_cont("ACPI NVS");			break;
	case E820_TYPE_UNUSABLE:	pr_cont("unusable");			break;
	case E820_TYPE_PMEM:		/* Fall through: */
	case E820_TYPE_PRAM:		pr_cont("persistent (type %u)", type);	break;
	default:			pr_cont("type %u", type);		break;
	}
}

void __init e820__print_table(char *who)
{
	int i;

	for (i = 0; i < e820_table->nr_entries; i++) {
		pr_info("%s: [mem %#018Lx-%#018Lx] ",
			who,
			e820_table->entries[i].addr,
			e820_table->entries[i].addr + e820_table->entries[i].size - 1);

		e820_print_type(e820_table->entries[i].type);
		pr_cont("\n");
	}
}

static int __init __append_e820_table(struct boot_e820_entry *entries, u32 nr_entries)
{
	struct boot_e820_entry *entry = entries;

	while (nr_entries) {
		u64 start = entry->addr;
		u64 size = entry->size;
		u64 end = start + size - 1;
		u32 type = entry->type;

		/* Ignore the entry on 64-bit overflow: */
		if (start > end && likely(size))
			return -1;

		e820__range_add(start, size, type);

		entry++;
		nr_entries--;
	}
	return 0;
}

/*
 * Copy the BIOS E820 map into a safe place.
 *
 * Sanity-check it while we're at it..
 *
 * If we're lucky and live on a modern system, the setup code
 * will have given us a memory map that we can use to properly
 * set up memory.  If we aren't, we'll fake a memory map.
 */
static int __init append_e820_table(struct boot_e820_entry *entries, u32 nr_entries)
{
	/* Only one memory region (or negative)? Ignore it */
	if (nr_entries < 2)
		return -1;

	return __append_e820_table(entries, nr_entries);
}

static u64 __init
__e820__range_update(struct e820_table *table, u64 start, u64 size, enum e820_type old_type, enum e820_type new_type)
{
	u64 end;
	unsigned int i;
	u64 real_updated_size = 0;

	BUG_ON(old_type == new_type);

	if (size > (ULLONG_MAX - start))
		size = ULLONG_MAX - start;

	end = start + size;
	printk(KERN_DEBUG "e820: update [mem %#010Lx-%#010Lx] ", start, end - 1);
	e820_print_type(old_type);
	pr_cont(" ==> ");
	e820_print_type(new_type);
	pr_cont("\n");

	for (i = 0; i < table->nr_entries; i++) {
		struct e820_entry *entry = &table->entries[i];
		u64 final_start, final_end;
		u64 entry_end;

		if (entry->type != old_type)
			continue;

		entry_end = entry->addr + entry->size;

		/* Completely covered by new range? */
		if (entry->addr >= start && entry_end <= end) {
			entry->type = new_type;
			real_updated_size += entry->size;
			continue;
		}

		/* New range is completely covered? */
		if (entry->addr < start && entry_end > end) {
			__e820__range_add(table, start, size, new_type);
			__e820__range_add(table, end, entry_end - end, entry->type);
			entry->size = start - entry->addr;
			real_updated_size += size;
			continue;
		}

		/* Partially covered: */
		final_start = max(start, entry->addr);
		final_end = min(end, entry_end);
		if (final_start >= final_end)
			continue;

		__e820__range_add(table, final_start, final_end - final_start, new_type);

		real_updated_size += final_end - final_start;

		/*
		 * Left range could be head or tail, so need to update
		 * its size first:
		 */
		entry->size -= final_end - final_start;
		if (entry->addr < final_start)
			continue;

		entry->addr = final_end;
	}
	return real_updated_size;
}

#define MAX_ARCH_PFN MAXMEM>>PAGE_SHIFT

/*
 * Find the highest page frame number we have available
 */
static unsigned long __init e820_end_pfn(unsigned long limit_pfn, enum e820_type type)
{
	int i;
	unsigned long last_pfn = 0;
	unsigned long max_arch_pfn = MAX_ARCH_PFN;

	for (i = 0; i < e820_table->nr_entries; i++) {
		struct e820_entry *entry = &e820_table->entries[i];
		unsigned long start_pfn;
		unsigned long end_pfn;

		if (entry->type != type)
			continue;

		start_pfn = entry->addr >> PAGE_SHIFT;
		end_pfn = (entry->addr + entry->size) >> PAGE_SHIFT;

		if (start_pfn >= limit_pfn)
			continue;
		if (end_pfn > limit_pfn) {
			last_pfn = limit_pfn;
			break;
		}
		if (end_pfn > last_pfn)
			last_pfn = end_pfn;
	}

	if (last_pfn > max_arch_pfn)
		last_pfn = max_arch_pfn;

	pr_info("last_pfn = %#lx max_arch_pfn = %#lx\n",
		last_pfn, max_arch_pfn);
	return last_pfn;
}

unsigned long __init e820__end_of_ram_pfn(void)
{
	return e820_end_pfn(MAX_ARCH_PFN, E820_TYPE_RAM);
}

unsigned long __init e820__end_of_low_ram_pfn(void)
{
	return e820_end_pfn(1UL << (32 - PAGE_SHIFT), E820_TYPE_RAM);
}

/*
 * Pass the firmware (bootloader) E820 map to the kernel and process it:
 */
char *__init e820__memory_setup_default(void)
{
	char *who = "BIOS-e820";

	/*
	 * Try to copy the BIOS-supplied E820-map.
	 *
	 * Otherwise fake a memory map; one section from 0k->640k,
	 * the next section from 1mb->appropriate_mem_k
	 */
	if (append_e820_table(boot_params.e820_table, boot_params.e820_entries) < 0) {
		u64 mem_size;

		/* Compare results from other methods and take the one that gives more RAM: */
		if (boot_params.alt_mem_k < boot_params.screen_info.ext_mem_k) {
			mem_size = boot_params.screen_info.ext_mem_k;
			who = "BIOS-88";
		} else {
			mem_size = boot_params.alt_mem_k;
			who = "BIOS-e801";
		}

		e820_table->nr_entries = 0;
		e820__range_add(0, LOWMEMSIZE(), E820_TYPE_RAM);
		e820__range_add(HIGH_MEMORY, mem_size << 10, E820_TYPE_RAM);
	}

	return who;
}

/*
 * Calls e820__memory_setup_default() in essence to pick up the firmware/bootloader
 * E820 map - with an optional platform quirk available for virtual platforms
 * to override this method of boot environment processing:
 */
void __init e820__memory_setup(void)
{
	char *who;

	/* This is a firmware interface ABI - make sure we don't break it: */
	BUILD_BUG_ON(sizeof(struct boot_e820_entry) != 20);

	who = x86_init.resources.memory_setup();

	pr_info("BIOS-provided physical RAM map:\n");
	e820__print_table(who);
}

void __init e820__memblock_setup(void)
{
	int i;
	u64 end;

	/*
	 * The bootstrap memblock region count maximum is 128 entries
	 * (INIT_MEMBLOCK_REGIONS), but EFI might pass us more E820 entries
	 * than that - so allow memblock resizing.
	 *
	 * This is safe, because this call happens pretty late during x86 setup,
	 * so we know about reserved memory regions already. (This is important
	 * so that memblock resizing does no stomp over reserved areas.)
	 */
	memblock_allow_resize();

	for (i = 0; i < e820_table->nr_entries; i++) {
		struct e820_entry *entry = &e820_table->entries[i];

		end = entry->addr + entry->size;
		if (end != (resource_size_t)end)
			continue;

		if (entry->type == E820_TYPE_SOFT_RESERVED)
			memblock_reserve(entry->addr, entry->size);

		if (entry->type != E820_TYPE_RAM && entry->type != E820_TYPE_RESERVED_KERN)
			continue;

		memblock_add(entry->addr, entry->size);
	}

	/* Throw away partial pages: */
	memblock_trim_memory(PAGE_SIZE);

	memblock_dump_all();
}
