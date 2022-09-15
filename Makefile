MAKEFLAGS := -rR --no-print-directory
CC := gcc

ifeq ("$(origin V)", "command line")
        Q :=
        E := @\#
else
        Q := @
        E := @echo
endif

$(shell mkdir -p `find -type d | grep -v ./build | sed 's/\./build/'`)

all: build/vmlinux.bin

clean:
	rm -rf build arch/x86/realmode/rm/realmode.relocs arch/x86/realmode/rm/realmode.bin

include = -nostdinc -Iinclude -Iinclude/uapi -Iarch/x86/include -Iarch/x86/include/uapi -I $(subst build/,,$(dir $@)) -I $(dir $@) \
		-Iinclude/generated/uapi -Iarch/x86/include/generated -Iarch/x86/include/generated/uapi \
		-include include/linux/kconfig.h -include include/linux/compiler_types.h -include include/linux/compiler-version.h

basetarget = $(subst -,_,$(basename $(notdir $@)))
CFLAGS = -D__KERNEL__ -fmacro-prefix-map=/dev/shm/linux/= -Wall -Wundef -Werror=strict-prototypes -Wno-trigraphs -fno-strict-aliasing -fno-common -fshort-wchar -fno-PIE -Werror=implicit-function-declaration -Werror=implicit-int -Werror=return-type -Wno-format-security -std=gnu11 -mno-sse -mno-mmx -mno-sse2 -mno-3dnow -mno-avx -fcf-protection=none -m64 -falign-jumps=1 -falign-loops=1 -mno-80387 -mno-fp-ret-in-387 -mpreferred-stack-boundary=3 -mskip-rax-setup -mtune=generic -mno-red-zone -mcmodel=kernel -Wno-sign-compare -fno-asynchronous-unwind-tables -fno-delete-null-pointer-checks -Wno-frame-address -Wno-format-truncation -Wno-format-overflow -Wno-address-of-packed-member -O2 -fno-allow-store-data-races -Wframe-larger-than=2048 -fno-stack-protector -Wno-array-bounds -Wimplicit-fallthrough=5 -Wno-main -Wno-unused-but-set-variable -Wno-unused-const-variable -Wno-dangling-pointer -fomit-frame-pointer -ftrivial-auto-var-init=zero -fno-stack-clash-protection -Wdeclaration-after-statement -Wvla -Wno-pointer-sign -Wcast-function-type -Wno-stringop-truncation -Wno-stringop-overflow -Wno-restrict -Wno-maybe-uninitialized -Wno-alloc-size-larger-than -fno-strict-overflow -fno-stack-check -fconserve-stack -Werror=date-time -Werror=incompatible-pointer-types -Werror=designated-init -Wno-packed-not-aligned -Wp,-MD,$(dir $@).$(notdir $@).d -Wp,-MT,$@ $(CFLAGS_$(basename $@).o) -DKBUILD_MODFILE='"$(basename $@)"' -DKBUILD_BASENAME='"$(basetarget)"' -DKBUILD_MODNAME='"$(basetarget)"' -D__KBUILD_MODNAME=kmod_$(basetarget)

kvm	:= $(addprefix build/, $(shell cat kvm))
$(kvm): c_flags = $(CFLAGS) -Iarch/x86/kvm

vmlinux	:= $(addprefix build/, $(shell cat files)) 
$(vmlinux): c_flags = $(CFLAGS)

objs	:= $(vmlinux) $(kvm)
export objs

build/%.o: %.c
	$(E) "  CC     " $@
	$(Q) $(CC) $(include) $(c_flags) -c -o $@ $<

build/%.o: %.S
	$(E) "  AS     " $@
	$(Q) $(CC) $(include) $(c_flags) -D__ASSEMBLY__ -c -o $@ $<

build/%.lds: %.lds.S
	$(E) "  LDS    " $@
	$(Q) gcc -E $(include) -P -Ux86 -D__ASSEMBLY__ -DLINKER_SCRIPT -o $@ $<

CFLAGS_build/arch/x86/kernel/irq.o := -I arch/x86/kernel/../include/asm/trace
CFLAGS_build/arch/x86/mm/fault.o := -I arch/x86/kernel/../include/asm/trace

realmode_objs := $(addprefix build/arch/x86/realmode/rm/, header.o trampoline_64.o stack.o reboot.o)
$(realmode_objs): c_flags := -m16 -g -Os -DDISABLE_BRANCH_PROFILING -D__DISABLE_EXPORTS -Wall -Wstrict-prototypes -march=i386 -mregparm=3 \
			-fno-strict-aliasing -fomit-frame-pointer -fno-pic -mno-mmx -mno-sse -fcf-protection=none -ffreestanding \
			-fno-stack-protector -Wno-address-of-packed-member -D_SETUP -D_WAKEUP -Iarch/x86/boot

build/arch/x86/realmode/rmpiggy.o: arch/x86/realmode/rm/realmode.bin

build/arch/x86/realmode/rm/pasyms.h: $(realmode_objs)
	@echo "  PASYMS " $@
	$(Q) nm $^ | sed -n -r -e 's/^([0-9a-fA-F]+) [ABCDGRSTVW] (.+)$$/pa_\2 = \2;/p' | sort | uniq > $@

build/arch/x86/realmode/rm/realmode.lds: build/arch/x86/realmode/rm/pasyms.h

build/arch/x86/realmode/rm/realmode.elf: build/arch/x86/realmode/rm/realmode.lds $(realmode_objs)
	@echo "  LD     " $@
	$(Q) ld -m elf_i386 --emit-relocs -T $^ -o $@

arch/x86/realmode/rm/realmode.bin: build/arch/x86/realmode/rm/realmode.elf arch/x86/realmode/rm/realmode.relocs
	@echo "  OBJCOPY" $@
	$(Q) objcopy -O binary $< $@

arch/x86/realmode/rm/realmode.relocs: build/arch/x86/realmode/rm/realmode.elf
	@echo "  RELOCS " $@
	$(Q) arch/x86/tools/relocs --realmode $< > $@

build/vmlinux: build/arch/x86/kernel/vmlinux.lds $(objs)
	$(Q) sh scripts/link-vmlinux.sh

build/vmlinux.bin: build/vmlinux
	$(E) "  OBJCOPY" $@
	$(Q) objcopy -O binary -R .note -R .comment -S $< $@

-include $(foreach obj,$(objs),$(dir $(obj)).$(notdir $(obj)).d)
