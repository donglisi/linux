KBUILD_CFLAGS := -m64 -O2
KBUILD_CFLAGS += -fno-strict-aliasing -fPIE
KBUILD_CFLAGS += -Wundef
KBUILD_CFLAGS += -DDISABLE_BRANCH_PROFILING
KBUILD_CFLAGS += -mno-mmx -mno-sse
KBUILD_CFLAGS += -ffreestanding -fshort-wchar
KBUILD_CFLAGS += -fno-stack-protector
KBUILD_CFLAGS += -Wno-address-of-packed-member
KBUILD_CFLAGS += -Wno-gnu
KBUILD_CFLAGS += -Wno-pointer-sign
KBUILD_CFLAGS += -fmacro-prefix-map=$(srctree)/=
KBUILD_CFLAGS += -fno-asynchronous-unwind-tables
KBUILD_CFLAGS += -D__DISABLE_EXPORTS
KBUILD_CFLAGS += -include $(srctree)/config.h
KBUILD_CFLAGS += -include $(srctree)/include/linux/hidden.h

KBUILD_AFLAGS  := $(KBUILD_CFLAGS) -D__ASSEMBLY__

hostprogs	:= mkpiggy

$(obj)/../voffset.h: vmlinux
	$(Q) $(NM) $< | sed -n -e 's/^\([0-9a-fA-F]*\) [ABCDGRSTVW] \(_text\|__bss_start\|_end\)$$/\#define VO_\2 _AC(0x\1,UL)/p' > $@

$(obj)/misc.o: $(obj)/../voffset.h

vmlinux-objs-y := vmlinux.lds kernel_info.o head_64.o misc.o string.o cmdline.o error.o piggy.o cpuflags.o early_serial_console.o ident_map_64.o idt_64.o idt_handlers_64.o mem_encrypt.o pgtable_64.o

VMLINUX_OBJS = $(addprefix $(obj)/,$(vmlinux-objs-y))

$(obj)/vmlinux: $(VMLINUX_OBJS)
	$(Q) $(LD) -m elf_x86_64 --no-ld-generated-unwind-info --no-dynamic-linker -T $^ -o $@

$(obj)/vmlinux.bin: vmlinux
	$(Q) $(OBJCOPY) -R .comment -S $< $@

$(obj)/vmlinux.bin.gz: $(obj)/vmlinux.bin
	$(Q) cat $< | gzip -n -f -9 > $@

$(obj)/piggy.S: $(obj)/vmlinux.bin.gz $(obj)/mkpiggy
	$(Q) $(obj)/mkpiggy $< > $@
