# SPDX-License-Identifier: GPL-2.0
#
# linux/arch/x86/boot/compressed/Makefile
#
# create a compressed vmlinux image from the original vmlinux
#
# vmlinuz is:
#	decompression code (*.o)
#	asm globals (piggy.S), including:
#		vmlinux.bin.(gz|bz2|lzma|...)
#
# vmlinux.bin is:
#	vmlinux stripped of debugging and comments
# vmlinux.bin.all is:
#	vmlinux.bin + vmlinux.relocs
# vmlinux.bin.(gz|bz2|lzma|...) is:
#	(see scripts/Makefile.lib size_append)
#	compressed vmlinux.bin.all + u32 size of vmlinux.bin.all

targets := vmlinux vmlinux.bin vmlinux.bin.gz

KBUILD_CFLAGS := -m$(BITS) -O2
KBUILD_CFLAGS += -fno-strict-aliasing -fPIE
KBUILD_CFLAGS += -Wundef
KBUILD_CFLAGS += -DDISABLE_BRANCH_PROFILING
KBUILD_CFLAGS += $(cflags-y)
KBUILD_CFLAGS += -mno-mmx -mno-sse
KBUILD_CFLAGS += -ffreestanding -fshort-wchar
KBUILD_CFLAGS += -fno-stack-protector
KBUILD_CFLAGS += $(call cc-disable-warning, address-of-packed-member)
KBUILD_CFLAGS += $(call cc-disable-warning, gnu)
KBUILD_CFLAGS += -Wno-pointer-sign
KBUILD_CFLAGS += $(call cc-option,-fmacro-prefix-map=$(srctree)/=)
KBUILD_CFLAGS += -fno-asynchronous-unwind-tables
KBUILD_CFLAGS += -D__DISABLE_EXPORTS
KBUILD_CFLAGS += -include /a/sources/linux/config.h
KBUILD_CFLAGS += -include $(srctree)/include/linux/hidden.h

KBUILD_AFLAGS  := $(KBUILD_CFLAGS) -D__ASSEMBLY__
GCOV_PROFILE := n
UBSAN_SANITIZE :=n

KBUILD_LDFLAGS := -m elf_$(UTS_MACHINE)
KBUILD_LDFLAGS += $(call ld-option,--no-ld-generated-unwind-info)

LDFLAGS_vmlinux := --no-dynamic-linker -T

hostprogs	:= mkpiggy
HOST_EXTRACFLAGS += -I$(srctree)/tools/include

targets += ../voffset.h

$(obj)/../voffset.h: vmlinux
	$(NM) $< | sed -n -e 's/^\([0-9a-fA-F]*\) [ABCDGRSTVW] \(_text\|__bss_start\|_end\)$$/\#define VO_\2 _AC(0x\1,UL)/p' > $@

$(obj)/misc.o: $(obj)/../voffset.h

vmlinux-objs-y := $(obj)/vmlinux.lds $(obj)/kernel_info.o $(obj)/head_$(BITS).o \
	$(obj)/misc.o $(obj)/string.o $(obj)/cmdline.o $(obj)/error.o \
	$(obj)/piggy.o $(obj)/cpuflags.o

vmlinux-objs-y += $(obj)/early_serial_console.o
vmlinux-objs-$(CONFIG_RANDOMIZE_BASE) += $(obj)/kaslr.o
	vmlinux-objs-y += $(obj)/ident_map_64.o
	vmlinux-objs-y += $(obj)/idt_64.o $(obj)/idt_handlers_64.o
	vmlinux-objs-y += $(obj)/mem_encrypt.o
	vmlinux-objs-y += $(obj)/pgtable_64.o

$(obj)/vmlinux: $(vmlinux-objs-y) $(efi-obj-y)
	$(LD) $(ld_flags) $(real-prereqs) -o $@

$(obj)/vmlinux.bin: vmlinux
	$(OBJCOPY) $(OBJCOPYFLAGS) -R .comment -S $< $@

targets += $(patsubst $(obj)/%,%,$(vmlinux-objs-y)) vmlinux.relocs

CMD_RELOCS = arch/x86/tools/relocs
$(obj)/vmlinux.relocs: vmlinux
	$(CMD_RELOCS) $< > $@;$(CMD_RELOCS) --abs-relocs $<

$(obj)/vmlinux.bin.gz: $(obj)/vmlinux.bin
	cat $(real-prereqs) | gzip -n -f -9 > $@

targets += piggy.S
$(obj)/piggy.S: $(obj)/vmlinux.bin.gz $(obj)/mkpiggy
	$(obj)/mkpiggy $< > $@
