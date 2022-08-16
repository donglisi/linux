MAKEFLAGS += -rR --include-dir=$(abs_srctree) --no-print-directory
export Q = @

ifneq ($(sub_make_done),1)
export sub_make_done := 1

KBUILD_OUTPUT := $(O)
abs_objtree := $(realpath $(shell mkdir -p $(KBUILD_OUTPUT) && cd $(KBUILD_OUTPUT) && pwd))
abs_srctree := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))
export abs_srctree abs_objtree

a:
	$(Q) $(MAKE) -C $(abs_objtree) -f $(abs_srctree)/Makefile

endif

srctree := $(abs_srctree)
objtree	:= .
VPATH	:= $(srctree)
export srctree objtree VPATH

export CONFIG_SHELL := sh

all: bzImage

export KBUILD_CFLAGS := -Wall -Wundef -Werror=strict-prototypes -Wno-trigraphs \
		   -fno-strict-aliasing -fno-common -fshort-wchar -fno-PIE \
		   -Werror=implicit-function-declaration -Werror=implicit-int \
		   -Werror=return-type -Wno-format-security \
		   -std=gnu11
KBUILD_CFLAGS += -mno-sse -mno-mmx -mno-sse2 -mno-3dnow -mno-avx
KBUILD_CFLAGS += -falign-jumps=1
KBUILD_CFLAGS += -falign-loops=1
KBUILD_CFLAGS += -mno-80387
KBUILD_CFLAGS += -mno-fp-ret-in-387
KBUILD_CFLAGS += -mskip-rax-setup
KBUILD_CFLAGS += -mno-red-zone
KBUILD_CFLAGS += -mcmodel=kernel
KBUILD_CFLAGS += -Wno-sign-compare
KBUILD_CFLAGS += -fno-asynchronous-unwind-tables
KBUILD_CFLAGS += -fno-delete-null-pointer-checks
KBUILD_CFLAGS += -Wno-frame-address
KBUILD_CFLAGS += -Wno-format-truncation
KBUILD_CFLAGS += -Wno-format-overflow
KBUILD_CFLAGS += -Wno-address-of-packed-member
KBUILD_CFLAGS += -O2
KBUILD_CFLAGS += -fno-allow-store-data-races
KBUILD_CFLAGS += -Wno-main
KBUILD_CFLAGS += -fno-stack-protector
KBUILD_CFLAGS += -Wimplicit-fallthrough=5
KBUILD_CFLAGS += -Wno-declaration-after-statement
KBUILD_CFLAGS += -Wno-vla
KBUILD_CFLAGS += -Wno-pointer-sign
KBUILD_CFLAGS += -Wno-cast-function-type
KBUILD_CFLAGS += -Wno-unused-const-variable
KBUILD_CFLAGS += -Wno-unused-but-set-variable
KBUILD_CFLAGS += -Wno-stringop-truncation
KBUILD_CFLAGS += -Wno-stringop-overflow
KBUILD_CFLAGS += -Wno-restrict
KBUILD_CFLAGS += -Wno-maybe-uninitialized
KBUILD_CFLAGS += -fno-strict-overflow
KBUILD_CFLAGS += -fno-stack-check
KBUILD_CFLAGS += -fconserve-stack
KBUILD_CFLAGS += -Wno-error=date-time
KBUILD_CFLAGS += -Werror=incompatible-pointer-types
KBUILD_CFLAGS += -Werror=designated-init
KBUILD_CFLAGS += -D__KERNEL__

export CPP	= $(CC) -E
export CC	= gcc
export LD	= ld
export AR	= ar
export NM	= nm
export OBJCOPY	= objcopy
export REALMODE_CFLAGS := -m16 -g -Os -DDISABLE_BRANCH_PROFILING -D__DISABLE_EXPORTS -Wall -Wstrict-prototypes -march=i386 -mregparm=3 -fno-strict-aliasing -fomit-frame-pointer -fno-pic -mno-mmx -mno-sse -fcf-protection=none -ffreestanding -fno-stack-protector -Wno-address-of-packed-member  -D_SETUP

core-y := init/ arch/x86/ kernel/ mm/ fs/ security/ block/ drivers/ net/
libs-y := arch/x86/lib/ lib/

bzImage: vmlinux FORCE
	$(Q) $(MAKE) -f $(srctree)/scripts/Makefile.build obj=arch/x86/boot arch/x86/boot/bzImage

vmlinux-dirs	:= $(patsubst %/, %, $(filter %/, $(core-y) $(libs-y)))

KBUILD_VMLINUX_OBJS := $(patsubst %/, %/built-in.a, $(core-y))
KBUILD_VMLINUX_OBJS += $(addsuffix built-in.a, $(filter %/, $(libs-y)))
export KBUILD_VMLINUX_OBJS

export KBUILD_VMLINUX_LIBS := $(patsubst %/, %/lib.a, $(libs-y))

export KBUILD_LDS := arch/x86/kernel/vmlinux.lds

vmlinux-deps := $(KBUILD_LDS) $(KBUILD_VMLINUX_OBJS) $(KBUILD_VMLINUX_LIBS)
$(vmlinux-deps): $(vmlinux-dirs)

vmlinux: scripts/link-vmlinux.sh $(vmlinux-deps) FORCE
	$(Q) $(CONFIG_SHELL) $< "$(LD)"

prepare0:
	@ mkdir -p $(abs_objtree)/include/generated/uapi/linux/ $(abs_objtree)/scripts $(abs_objtree)/lib $(abs_objtree)/arch/x86/boot/compressed $(abs_objtree)/arch/x86/entry/vdso $(abs_objtree)/arch/x86/tools $(abs_objtree)/arch/x86/boot/tools
	@ echo '#define UTS_RELEASE "5.19.0"' > $(abs_objtree)/include/generated/utsrelease.h
	@ cp $(srctree)/scripts/compile.h $(abs_objtree)/include/generated/
	@ cp $(srctree)/scripts/version.h $(abs_objtree)/include/generated/uapi/linux/
	@ cp $(srctree)/lib/gen_crc32table $(abs_objtree)/lib/
	@ cp $(srctree)/arch/x86/tools/relocs $(abs_objtree)/arch/x86/tools/
	@ cp $(srctree)/arch/x86/boot/compressed/mkpiggy $(abs_objtree)/arch/x86/boot/compressed/
	@ cp $(srctree)/arch/x86/boot/mkcpustr $(abs_objtree)/arch/x86/boot/
	@ cp $(srctree)/arch/x86/boot/tools/build $(abs_objtree)/arch/x86/boot/tools
	@ cp $(srctree)/arch/x86/entry/vdso/vdso2c $(abs_objtree)/arch/x86/entry/vdso/
	$(Q) $(MAKE) -f $(srctree)/scripts/Makefile.build obj=arch/x86/entry/syscalls all
	$(Q) $(MAKE) -f $(srctree)/scripts/Makefile.asm-generic obj=arch/x86/include/generated/uapi/asm generic=include/uapi/asm-generic
	$(Q) $(MAKE) -f $(srctree)/scripts/Makefile.asm-generic obj=arch/x86/include/generated/asm generic=include/asm-generic
	$(Q) $(MAKE) -f $(srctree)/scripts/Makefile.build_

build-dirs := $(vmlinux-dirs)
$(build-dirs): prepare0
	$(Q) $(MAKE) -f $(srctree)/scripts/Makefile.build obj=$@

PHONY += FORCE
FORCE:

PHONY += $(build-dirs)
.PHONY: $(PHONY)
