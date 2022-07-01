always-y := realmode.bin realmode.relocs

realmode-y			+= header.o
realmode-y			+= trampoline_$(BITS).o
realmode-y			+= stack.o
realmode-y			+= reboot.o

targets	+= $(realmode-y)

REALMODE_OBJS = $(addprefix $(obj)/,$(realmode-y))

sed-pasyms := -n -r -e 's/^([0-9a-fA-F]+) [ABCDGRSTVW] (.+)$$/pa_\2 = \2;/p'

quiet_cmd_pasyms = PASYMS  $@
      cmd_pasyms = $(NM) $(real-prereqs) | sed $(sed-pasyms) | sort | uniq > $@

targets += pasyms.h
$(obj)/pasyms.h: $(REALMODE_OBJS) FORCE
	$(call if_changed,pasyms)

targets += realmode.lds
$(obj)/realmode.lds: $(obj)/pasyms.h

LDFLAGS_realmode.elf := -m elf_i386 --emit-relocs -T
CPPFLAGS_realmode.lds += -P -C -I$(objtree)/$(obj)

targets += realmode.elf
$(obj)/realmode.elf: $(obj)/realmode.lds $(REALMODE_OBJS) FORCE
	$(call if_changed,ld)

OBJCOPYFLAGS_realmode.bin := -O binary

targets += realmode.bin
$(obj)/realmode.bin: $(obj)/realmode.elf $(obj)/realmode.relocs FORCE
	$(call if_changed,objcopy)

targets += realmode.relocs
$(obj)/realmode.relocs: $(obj)/realmode.elf
	arch/x86/tools/relocs --realmode $< > $@

KBUILD_CFLAGS	:= $(REALMODE_CFLAGS) -D_SETUP -D_WAKEUP \
		   -I$(srctree)/arch/x86/boot
KBUILD_AFLAGS	:= $(KBUILD_CFLAGS) -D__ASSEMBLY__
KBUILD_CFLAGS	+= -fno-asynchronous-unwind-tables

