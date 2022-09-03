OUTPUT_FORMAT("elf64-x86-64")
OUTPUT_ARCH(i386:x86-64)
PHDRS {
	text PT_LOAD FLAGS(5);
}
SECTIONS
{
	. = (0xffffffff80000000 + ALIGN(0x200000, 0x200000));
	.text : AT(ADDR(.text) - 0xffffffff80000000) {
	} :text =0xcccc
}
