always-y := realmode.bin realmode.relocs

realmode-y			+= header.o
realmode-y			+= trampoline_64.o
realmode-y			+= stack.o
realmode-y			+= reboot.o

targets	+= $(realmode-y)

REALMODE_OBJS = $(addprefix $(obj)/,$(realmode-y))

targets += pasyms.h
$(obj)/pasyms.h: $(REALMODE_OBJS)
	$(NM) $(real-prereqs) | sed -n -r -e 's/^([0-9a-fA-F]+) [ABCDGRSTVW] (.+)$$/pa_\2 = \2;/p' | sort | uniq > $@

targets += realmode.lds
$(obj)/realmode.lds: $(obj)/pasyms.h

LDFLAGS_realmode.elf := -m elf_i386 --emit-relocs -T
CPPFLAGS_realmode.lds += -P -C -I$(objtree)/$(obj)

targets += realmode.elf
$(obj)/realmode.elf: $(obj)/realmode.lds $(REALMODE_OBJS)
	$(LD) $(ld_flags) $(real-prereqs) -o $@

OBJCOPYFLAGS_realmode.bin := -O binary

targets += realmode.bin
$(obj)/realmode.bin: $(obj)/realmode.elf $(obj)/realmode.relocs
	$(OBJCOPY) $(OBJCOPYFLAGS) $(OBJCOPYFLAGS_$(@F)) $< $@

targets += realmode.relocs
$(obj)/realmode.relocs: $(obj)/realmode.elf
	arch/x86/tools/relocs --realmode $< > $@

KBUILD_CFLAGS	:= $(REALMODE_CFLAGS) -D_SETUP -D_WAKEUP \
		   -I$(srctree)/arch/x86/boot
KBUILD_AFLAGS	:= $(KBUILD_CFLAGS) -D__ASSEMBLY__
KBUILD_CFLAGS	+= -fno-asynchronous-unwind-tables