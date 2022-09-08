OUTPUT_FORMAT("elf64-x86-64")
OUTPUT_ARCH(i386:x86-64)
ENTRY(phys_startup_64)
jiffies = 0;
PHDRS {
	text PT_LOAD FLAGS(5);
	data PT_LOAD FLAGS(6);
	init PT_LOAD FLAGS(7);
	note PT_NOTE FLAGS(0);
}
SECTIONS
{
	. = (0xffffffff80000000 + ALIGN(0x200000, 0x200000));
	phys_startup_64 = ABSOLUTE(startup_64 - 0xffffffff80000000);
	.text : AT(ADDR(.text) - 0xffffffff80000000) {
		_text = .;
		_stext = .;
		KEEP(*(.head.text))
	} :text =0xcccc
	_etext = .;
	. = ALIGN(((1 << 12)));
	.rodata : AT(ADDR(.rodata) - 0xffffffff80000000) {
		__start_rodata = .;
		*(.rodata) *(.rodata.*) . = ALIGN(32);
	}
	. = ALIGN(16);
	__ex_table : AT(ADDR(__ex_table) - 0xffffffff80000000) {
		KEEP(*(__ex_table)) __stop___ex_table = .;
	}
	__end_rodata = .;
	.data : AT(ADDR(.data) - 0xffffffff80000000) {
		_sdata = .;
		. = ALIGN(((1 << 12) << (2 + 0)));
		__start_init_task = .;
		init_thread_union = .;
		init_stack = .;
		__end_init_task = .;
		_edata = .;
	} :data
	.init.begin : AT(ADDR(.init.begin) - 0xffffffff80000000) {
		__init_begin = .;
	}
	. = ALIGN((1 << 12));
	.init.text : AT(ADDR(.init.text) - 0xffffffff80000000) {
		_sinittext = .;
		*(.init.text .init.text.*) *(.text.startup) *(.meminit.text*) _einittext = .;
	}
	:init
	.init.data : AT(ADDR(.init.data) - 0xffffffff80000000) {
		__setup_start = .;
		KEEP(*(.init.setup)) __setup_end = .;
	}
	.init.end : AT(ADDR(.init.end) - 0xffffffff80000000) {
		__init_end = .;
	}
	.bss : AT(ADDR(.bss) - 0xffffffff80000000) {
		__bss_start = .;
		*(.bss..page_aligned)
		*(.bss)
		__bss_stop = .;
	}
	__end_of_kernel_reserve = .;
	.brk : AT(ADDR(.brk) - 0xffffffff80000000) {
		__brk_base = .;
		. += 64 * 1024;
		*(.bss..brk)
		__brk_limit = .;
	}
	_end = .;
	/DISCARD/ : { *(.exitcall.exit) *(.discard) *(.discard.*) *(.modinfo) *(.gnu.version*) *(.comment) }
}
. = ASSERT((_end - 0xffffffff80000000 <= (512 * 1024 * 1024)),
		  "kernel image bigger than KERNEL_IMAGE_SIZE");
init_per_cpu__gdt_page = ABSOLUTE(gdt_page);
init_per_cpu__fixed_percpu_data = ABSOLUTE(fixed_percpu_data);
