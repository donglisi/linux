MAKEFLAGS := -rR --no-print-directory
CC := gcc

ifeq ("$(origin V)", "command line")
        Q :=
        E = @\#
else
        Q := @
        E := @echo
endif

$(shell bash -c "mkdir -p build/{{mm,init,lib/math},arch/x86/{kernel/cpu,mm,lib},kernel/{sched,locking,printk}}")

all: build/vmlinux.bin

clean:
	rm -rf build

include = -nostdinc -Iinclude -Iinclude/uapi -Iarch/x86/include -Iarch/x86/include/uapi -I $(subst build/,,$(dir $@)) -I $(dir $@) \
		-Iinclude/generated/uapi -Iarch/x86/include/generated -Iarch/x86/include/generated/uapi \
		-include include/linux/kconfig.h -include include/linux/compiler_types.h -include include/linux/compiler-version.h

basetarget = $(subst -,_,$(basename $(notdir $@)))
CFLAGS = -D__KERNEL__ -fshort-wchar -O1 -mcmodel=kernel -mno-sse -mno-red-zone -fno-stack-protector -fno-PIE -Wno-format-security -Wno-format-truncation \
		-Wno-address-of-packed-member -Wno-pointer-sign -Wno-unused-but-set-variable -Wno-stringop-overflow -Wno-maybe-uninitialized \
		-Wp,-MD,$(dir $@).$(notdir $@).d -Wp,-MT,$@ $(CFLAGS_$(basename $@).o) -DKBUILD_MODFILE='"$(basename $@)"' \
		-DKBUILD_BASENAME='"$(basetarget)"' -DKBUILD_MODNAME='"$(basetarget)"' -D__KBUILD_MODNAME=kmod_$(basetarget)

x86	:= $(addprefix arch/x86/, $(addprefix mm/, init.o init_64.o) \
		$(addprefix lib/, hweight.o memcpy_64.o clear_page_64.o memmove_64.o memset_64.o) \
		$(addprefix kernel/, idt.o setup.o x86_init.o e820.o head_64.o head64.o early_printk.o cpu/common.o))
kernel	:= $(addprefix kernel/, params.o range.o $(addprefix printk/, printk.o printk_safe.o printk_ringbuffer.o))
lib	:= $(addprefix lib/, sort.o parser.o find_bit.o hexdump.o kstrtox.o ctype.o string.o vsprintf.o cmdline.o sym.o func.o)
mm	:= $(addprefix mm/, util.o mmzone.o page_alloc.o init-mm.o memblock.o sparse.o vmstat.o)
objs	:= $(addprefix build/, $(x86) $(kernel) $(lib) $(mm) init/main.o)

build/%.o: %.c
	$(E) "  CC     " $@
	$(Q) $(CC) $(include) $(CFLAGS) -c -o $@ $<

build/%.o: %.S
	$(E) "  AS     " $@
	$(Q) $(CC) $(include) $(CFLAGS) -D__ASSEMBLY__ -c -o $@ $<

build/%.lds: %.lds.S
	$(E) "  LDS    " $@
	$(Q) gcc -E $(include) -P -Ux86 -D__ASSEMBLY__ -DLINKER_SCRIPT -o $@ $<

build/vmlinux: arch/x86/kernel/vmlinux.lds $(objs)
	$(E) "  LD     " $@
	$(Q) ld -m elf_x86_64 -z max-page-size=0x200000 --script=$< -o $@ $(objs)

build/vmlinux.bin: build/vmlinux
	$(E) "  OBJCOPY" $@
	$(Q) objcopy -O binary -R .note -R .comment -S $< $@

-include $(foreach obj,$(objs),$(dir $(obj)).$(notdir $(obj)).d)
