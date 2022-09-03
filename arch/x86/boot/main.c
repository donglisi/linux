#include "boot.h"
#include <string.h>

#define SMAP	0x534d4150	/* ASCII "SMAP" */

struct boot_params boot_params __attribute__((aligned(16)));

static void detect_memory_e820(void)
{
	int count = 0;
	struct biosregs ireg, oreg;
	struct boot_e820_entry *desc = boot_params.e820_table;
	static struct boot_e820_entry buf; /* static so it is zeroed */

	initregs(&ireg);
	ireg.ax  = 0xe820;
	ireg.cx  = sizeof(buf);
	ireg.edx = SMAP;
	ireg.di  = (size_t)&buf;

	do {
		intcall(0x15, &ireg, &oreg);
		ireg.ebx = oreg.ebx; /* for next iteration... */

		*desc++ = buf;
		count++;
	} while (ireg.ebx && count < ARRAY_SIZE(boot_params.e820_table));

	boot_params.e820_entries = count;
}

void main(void)
{
	memcpy(&boot_params.hdr, &hdr, sizeof(hdr));

	detect_memory_e820();

	go_to_protected_mode();
}
