MAKEFLAGS := -rR --no-print-directory
Q = @

ifeq ("$(origin V)", "command line")
	Q :=
	E = @\#
else
	Q := @
	E := @echo
endif

$(shell bash -c "mkdir -p build/arch/x86/{kernel,boot/compressed}")

all: build/arch/x86/boot/bzImage

clean:
	rm -rf build arch/x86/boot/compressed/piggy.S

include = -nostdinc -Iinclude -Iinclude/uapi -Iarch/x86/include -Iarch/x86/include/uapi -I $(subst build/,,$(dir $@)) -I $(dir $@) \
		-Iinclude/generated/uapi -Iarch/x86/include/generated -Iarch/x86/include/generated/uapi \
		-include include/linux/kconfig.h -include include/linux/compiler_types.h -include include/linux/compiler-version.h

realmode_cflags := -m16 -g -Os -DDISABLE_BRANCH_PROFILING -D__DISABLE_EXPORTS -Wall -Wstrict-prototypes -march=i386 -mregparm=3 \
			-fno-strict-aliasing -fomit-frame-pointer -fno-pic -mno-mmx -mno-sse -fcf-protection=none -ffreestanding \
			-fno-stack-protector -Wno-address-of-packed-member -D_SETUP -D__KERNEL__

build/%.o: %.c
	$(E) "  CC     " $@
	$(Q) gcc $(include) $(c_flags) -c -o $@ $<

build/%.o: %.S
	$(E) "  AS     " $@
	$(Q) gcc $(include) $(c_flags) -D__ASSEMBLY__ -c -o $@ $<

build/%.lds: %.lds.S
	$(E) "  LDS    " $@
	$(Q) gcc -E $(include) -P -Ux86 -D__ASSEMBLY__ -DLINKER_SCRIPT -o $@ $<

setup_objs := $(addprefix build/arch/x86/boot/, bioscall.o \
			header.o main.o pm.o pmjump.o regs.o)
$(setup_objs): c_flags = $(realmode_cflags) -fmacro-prefix-map== -fno-asynchronous-unwind-tables

build/arch/x86/boot/bzImage: build/arch/x86/boot/setup.bin build/arch/x86/boot/vmlinux.bin build/vmlinux
	$(E) "  BUILD  " $@
	$(Q) arch/x86/boot/tools/build build/arch/x86/boot/setup.bin build/arch/x86/boot/vmlinux.bin build/arch/x86/boot/zoffset.h $@

build/arch/x86/boot/vmlinux.bin: build/arch/x86/boot/compressed/vmlinux
	$(E) "  OBJCOPY" $@
	$(Q) objcopy -O binary -R .note -R .comment -S $< $@

build/arch/x86/boot/zoffset.h: build/arch/x86/boot/compressed/vmlinux
	$(E) "  ZOFFSET" $@
	$(Q) nm $< | sed -n -e 's/^\([0-9a-fA-F]*\) [a-zA-Z] \(startup_32\|startup_64\|input_data\|_end\|_ehead\|_text\|z_.*\)$$/\#define ZO_\2 0x\1/p' > $@

build/arch/x86/boot/header.o: build/arch/x86/boot/zoffset.h

build/arch/x86/boot/setup.elf: arch/x86/boot/setup.ld $(setup_objs)
	$(E) "  LD     " $@
	$(Q) ld -m elf_i386 -T $^ -o $@

build/arch/x86/boot/setup.bin: build/arch/x86/boot/setup.elf
	$(E) "  OBJCOPY" $@
	$(Q) objcopy -O binary $< $@

vmlinux_objs = $(addprefix build/arch/x86/boot/compressed/, head_64.o misc.o string.o piggy.o pgtable_64.o)
$(vmlinux_objs): c_flags = -m64 -O2 -fno-strict-aliasing -fPIE -Wundef -mno-mmx -mno-sse -ffreestanding -fshort-wchar -fno-stack-protector \
			-Wno-address-of-packed-member -Wno-gnu -Wno-pointer-sign -fmacro-prefix-map== -fno-asynchronous-unwind-tables \
			-D__DISABLE_EXPORTS -include include/linux/hidden.h -D__KERNEL__

build/arch/x86/boot/compressed/vmlinux: arch/x86/boot/compressed/vmlinux.lds $(vmlinux_objs)
	$(E) "  LD     " $@
	$(Q) ld -m elf_x86_64 --no-ld-generated-unwind-info --no-dynamic-linker -T $^ -o $@

build/arch/x86/boot/compressed/vmlinux.bin: build/vmlinux
	$(E) "  OBJCOPY" $@
	$(Q) objcopy -R .comment -S $< $@

build/arch/x86/boot/compressed/vmlinux.bin.gz: build/arch/x86/boot/compressed/vmlinux.bin
	$(E) "  GZIP   " $@
	$(Q) cat $< | gzip -n -f -9 > $@

arch/x86/boot/compressed/piggy.S: build/arch/x86/boot/compressed/vmlinux.bin.gz
	$(E) "  MKPIGGY" $@
	$(Q) arch/x86/boot/compressed/mkpiggy $< > $@

build/vmlinux: build/arch/x86/kernel/head.o
	$(E) "  LD     " $@
	$(Q) ld -m elf_x86_64 -z max-page-size=0x200000 -T arch/x86/kernel/vmlinux.lds -o $@ $^
