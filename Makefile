VERSION = 5
PATCHLEVEL = 19
SUBLEVEL = 0
EXTRAVERSION = -rc1

PHONY := __all

ifneq ($(sub_make_done),1)

MAKEFLAGS += -rR --include-dir=$(abs_srctree) --no-print-directory
export Q = @

KBUILD_OUTPUT := $(O)
abs_objtree := $(realpath $(shell mkdir -p $(KBUILD_OUTPUT) && cd $(KBUILD_OUTPUT) && pwd))
abs_srctree := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))
export abs_srctree abs_objtree

export sub_make_done := 1

__all:
	$(Q) $(MAKE) -C $(abs_objtree) -f $(abs_srctree)/Makefile

endif # sub_make_done

srctree := $(abs_srctree)
objtree		:= .
VPATH		:= $(srctree)
export srctree objtree VPATH

CONFIG_SHELL := sh

HOSTCC	= gcc

CPP		= $(CC) -E
CC		= gcc
LD		= ld
AR		= ar
NM		= nm
OBJCOPY		= objcopy
OBJDUMP		= objdump
STRIP		= strip
AWK		= awk
BASH		= bash

NOSTDINC_FLAGS :=

export KBUILD_AFLAGS   := -D__ASSEMBLY__ -fno-PIE -include $(srctree)/config.h

export KBUILD_CPPFLAGS := -D__KERNEL__ -include $(srctree)/config.h -fmacro-prefix-map=$(srctree)/=

export CONFIG_SHELL BASH HOSTCC LD CC
export CPP AR NM STRIP OBJCOPY OBJDUMP LEX YACC AWK
export MAKE
export NOSTDINC_FLAGS

all: bzImage

export REALMODE_CFLAGS := -m16 -g -Os -DDISABLE_BRANCH_PROFILING -D__DISABLE_EXPORTS -Wall -Wstrict-prototypes -march=i386 -mregparm=3 -fno-strict-aliasing -fomit-frame-pointer -fno-pic -mno-mmx -mno-sse -fcf-protection=none -include $(srctree)/config.h -ffreestanding -fno-stack-protector -Wno-address-of-packed-member

export KBUILD_CFLAGS := -Wall -Wundef -Werror=strict-prototypes -Wno-trigraphs \
		   -fno-strict-aliasing -fno-common -fshort-wchar -fno-PIE \
		   -Werror=implicit-function-declaration -Werror=implicit-int \
		   -Werror=return-type -Wno-format-security \
		   -std=gnu11 -include $(srctree)/config.h 
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

head-y := arch/x86/kernel/head_64.o arch/x86/kernel/head64.o arch/x86/kernel/ebda.o arch/x86/kernel/platform-quirks.o
core-y := init/ arch/x86/ kernel/ mm/ fs/ security/ crypto/ block/
drivers-y := arch/x86/pci/ drivers/ net/
libs-y := arch/x86/lib/ lib/

bzImage: vmlinux
	$(Q) $(MAKE) -f $(srctree)/scripts/Makefile.build obj=arch/x86/boot arch/x86/boot/bzImage

NOSTDINC_FLAGS += -nostdinc

vmlinux-dirs	:= $(patsubst %/, %, $(filter %/, $(core-y) $(drivers-y) $(libs-y)))

build-dirs	:= $(vmlinux-dirs)

KBUILD_VMLINUX_OBJS := $(head-y) $(patsubst %/, %/built-in.a, $(core-y))
KBUILD_VMLINUX_OBJS += $(addsuffix built-in.a, $(filter %/, $(libs-y)))
KBUILD_VMLINUX_OBJS += $(patsubst %/, %/built-in.a, $(drivers-y))
export KBUILD_VMLINUX_OBJS

export KBUILD_VMLINUX_LIBS := $(patsubst %/, %/lib.a, $(libs-y))

export KBUILD_LDS := arch/x86/kernel/vmlinux.lds

vmlinux-deps := $(KBUILD_LDS) $(KBUILD_VMLINUX_OBJS) $(KBUILD_VMLINUX_LIBS)
$(vmlinux-deps): $(vmlinux-dirs)

vmlinux: scripts/link-vmlinux.sh $(vmlinux-deps)
	$(Q) $(CONFIG_SHELL) $< "$(LD)"

prepare0:
	mkdir -p $(abs_objtree)/include/generated/uapi/linux/
	echo '#define UTS_RELEASE "5.19.0-rc1"' > $(abs_objtree)/include/generated/utsrelease.h
	cp $(srctree)/compile.h $(abs_objtree)/include/generated/
	cp $(srctree)/version.h $(abs_objtree)/include/generated/uapi/linux/
	$(Q) $(MAKE) -f $(srctree)/scripts/Makefile.build obj=arch/x86/entry/syscalls all
	$(Q) $(MAKE) -f $(srctree)/scripts/Makefile.build obj=arch/x86/tools relocs
	$(Q) $(MAKE) -f $(srctree)/scripts/Makefile.asm-generic obj=arch/x86/include/generated/uapi/asm generic=include/uapi/asm-generic
	$(Q) $(MAKE) -f $(srctree)/scripts/Makefile.asm-generic obj=arch/x86/include/generated/asm generic=include/asm-generic
	$(Q) $(MAKE) -f $(srctree)/scripts/Makefile.build obj=.

PHONY += $(build-dirs)
$(build-dirs): prepare0
	$(Q) $(MAKE) -f $(srctree)/scripts/Makefile.build obj=$@

.PHONY: $(PHONY)
