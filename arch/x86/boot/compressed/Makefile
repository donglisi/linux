KBUILD_CFLAGS := -m64 -O2
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

KBUILD_LDFLAGS := -m elf_x86_64 --no-ld-generated-unwind-info

LDFLAGS_vmlinux := --no-dynamic-linker -T

hostprogs	:= mkpiggy

HOST_EXTRACFLAGS += -I$(srctree)/tools/include

$(obj)/../voffset.h: vmlinux
	$(Q) $(NM) $< | sed -n -e 's/^\([0-9a-fA-F]*\) [ABCDGRSTVW] \(_text\|__bss_start\|_end\)$$/\#define VO_\2 _AC(0x\1,UL)/p' > $@

$(obj)/misc.o: $(obj)/../voffset.h

vmlinux-objs-y := vmlinux.lds kernel_info.o head_64.o misc.o string.o cmdline.o error.o piggy.o cpuflags.o early_serial_console.o ident_map_64.o idt_64.o idt_handlers_64.o mem_encrypt.o pgtable_64.o

VMLINUX_OBJS = $(addprefix $(obj)/,$(vmlinux-objs-y))

$(obj)/vmlinux: $(VMLINUX_OBJS)
	$(Q) $(LD) $(ld_flags) $(real-prereqs) -o $@

$(obj)/vmlinux.bin: vmlinux
	$(Q) $(OBJCOPY) $(OBJCOPYFLAGS) -R .comment -S $< $@

$(obj)/vmlinux.bin.gz: $(obj)/vmlinux.bin
	$(Q) cat $(real-prereqs) | gzip -n -f -9 > $@

$(obj)/piggy.S: $(obj)/vmlinux.bin.gz $(obj)/mkpiggy
	$(Q) $(obj)/mkpiggy $< > $@
