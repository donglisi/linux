#include <linux/pci.h>

#include <asm/setup.h>
#include <asm/e820/api.h>

void x86_init_noop(void) { }

/*
 * The platform setup functions are preset with the default functions
 * for standard PC hardware.
 */
struct x86_init_ops x86_init __initdata = {
	.resources = {
		.probe_roms		= probe_roms,
		.memory_setup		= e820__memory_setup_default,
	},

	.paging = {
		.pagetable_init		= native_pagetable_init,
	},
};
