MAKEFLAGS := -rR --no-print-directory
CC := gcc

ifeq ("$(origin V)", "command line")
        Q :=
        E = @\#
else
        Q := @
        E := @echo
endif

$(shell bash -c "mkdir -p build/{{mm,init,lib/math},arch/x86/{entry,kernel/cpu,mm,lib},kernel/{sched,locking,printk}}")

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

x86	:= $(addprefix arch/x86/, \
		$(addprefix entry/, entry_64.o) \
		$(addprefix lib/, hweight.o cmdline.o cpu.o memcpy_64.o clear_page_64.o memmove_64.o memset_64.o) \
		$(addprefix mm/, init.o init_64.o) \
		$(addprefix kernel/, idt.o setup.o x86_init.o e820.o head_64.o head64.o early_printk.o $(addprefix cpu/, common.o)))

init	:= $(addprefix init/, main.o init_task.o)

kernel	:= $(addprefix kernel/, params.o range.o $(addprefix printk/, printk.o printk_safe.o printk_ringbuffer.o))

lib	:= $(addprefix lib/, sort.o parser.o bitmap.o find_bit.o string_helpers.o hexdump.o kstrtox.o ctype.o string.o vsprintf.o cmdline.o rbtree.o sym.o \
		$(addprefix math/, div64.o gcd.o lcm.o int_pow.o int_sqrt.o reciprocal_div.o))

mm	:= $(addprefix mm/, swap.o util.o mmzone.o mm_init.o percpu.o page_alloc.o init-mm.o memblock.o sparse.o)

objs = $(addprefix build/, $(x86) $(init) $(kernel) $(lib) $(mm))
export objs

build/%.o: %.c
	$(E) "  CC     " $@
	$(Q) $(CC) $(include) $(CFLAGS) -c -o $@ $<

build/%.o: %.S
	$(E) "  AS     " $@
	$(Q) $(CC) $(include) $(CFLAGS) -D__ASSEMBLY__ -c -o $@ $<

build/%.lds: %.lds.S
	$(E) "  LDS    " $@
	$(Q) gcc -E $(include) -P -Ux86 -D__ASSEMBLY__ -DLINKER_SCRIPT -o $@ $<

CFLAGS_build/arch/x86/kernel/irq.o := -I arch/x86/kernel/../include/asm/trace
CFLAGS_build/arch/x86/mm/fault.o := -I arch/x86/kernel/../include/asm/trace

build/vmlinux: build/arch/x86/kernel/vmlinux.lds $(objs)
	$(Q) sh scripts/link-vmlinux.sh

build/vmlinux.bin: build/vmlinux
	$(E) "  OBJCOPY" $@
	$(Q) objcopy -O binary -R .note -R .comment -S $< $@

-include $(foreach obj,$(objs),$(dir $(obj)).$(notdir $(obj)).d)
