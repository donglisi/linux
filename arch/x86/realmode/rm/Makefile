realmode-y := header.o trampoline_64.o stack.o reboot.o

REALMODE_OBJS = $(addprefix $(obj)/,$(realmode-y))

$(obj)/pasyms.h: $(REALMODE_OBJS)
	$(Q) $(NM) $(real-prereqs) | sed -n -r -e 's/^([0-9a-fA-F]+) [ABCDGRSTVW] (.+)$$/pa_\2 = \2;/p' | sort | uniq > $@

$(obj)/realmode.lds: $(obj)/pasyms.h

CPPFLAGS_realmode.lds += -P -C -I$(objtree)/$(obj)

$(obj)/realmode.elf: $(obj)/realmode.lds $(REALMODE_OBJS)
	$(Q) $(LD) -m elf_i386 --emit-relocs -T $(real-prereqs) -o $@

$(obj)/realmode.bin: $(obj)/realmode.elf $(obj)/realmode.relocs
	$(Q) $(OBJCOPY) -O binary $< $@

$(obj)/realmode.relocs: $(obj)/realmode.elf
	$(Q) arch/x86/tools/relocs --realmode $< > $@

KBUILD_CFLAGS	:= $(REALMODE_CFLAGS) -D_SETUP -D_WAKEUP -I$(srctree)/arch/x86/boot
KBUILD_AFLAGS	:= $(KBUILD_CFLAGS) -D__ASSEMBLY__
KBUILD_CFLAGS	+= -fno-asynchronous-unwind-tables