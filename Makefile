# SPDX-License-Identifier: GPL-2.0
VERSION = 5
PATCHLEVEL = 19
SUBLEVEL = 0
EXTRAVERSION = -rc1

PHONY := __all

ifneq ($(sub_make_done),1)

MAKEFLAGS += -rR --include-dir=$(abs_srctree) --no-print-directory
Q = @
export Q

KBUILD_OUTPUT := $(O)
abs_objtree := $(realpath $(shell mkdir -p $(KBUILD_OUTPUT) && cd $(KBUILD_OUTPUT) && pwd))
abs_srctree := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))
export abs_srctree abs_objtree

export sub_make_done := 1

__all:
	mkdir -p build/include/generated/
	cp compile.h build/include/generated/
	$(Q) $(MAKE) -C $(abs_objtree) -f $(abs_srctree)/Makefile

endif # sub_make_done

srctree := $(abs_srctree)
objtree		:= .
VPATH		:= $(srctree)
export srctree objtree VPATH

version_h := include/generated/uapi/linux/version.h

kecho := :
define filechk
	mkdir -p $(dir $@);					\
	{ $(filechk_$(1)); } > $(dot-target).tmp;		\
	if [ ! -r $@ ] || ! cmp -s $@ $(dot-target).tmp; then	\
		$(kecho) '  UPD     $@';			\
		mv -f $(dot-target).tmp $@;			\
	fi
endef

KERNELRELEASE = $(shell cat include/config/kernel.release 2> /dev/null)
KERNELVERSION = $(VERSION)$(if $(PATCHLEVEL),.$(PATCHLEVEL)$(if $(SUBLEVEL),.$(SUBLEVEL)))$(EXTRAVERSION)
export VERSION PATCHLEVEL SUBLEVEL KERNELRELEASE KERNELVERSION

ARCH := x86
UTS_MACHINE := x86_64
SRCARCH := x86

CONFIG_SHELL := sh

HOSTCC	= gcc

KBUILD_USERHOSTCFLAGS := -Wall -Wmissing-prototypes -Wstrict-prototypes \
			 -O2 -fomit-frame-pointer -std=gnu11 \
			 -Wdeclaration-after-statement -include /a/sources/linux/config.h

KBUILD_HOSTCFLAGS   := $(KBUILD_USERHOSTCFLAGS) $(HOST_LFS_CFLAGS) $(HOSTCFLAGS)
KBUILD_HOSTLDFLAGS  := $(HOST_LFS_LDFLAGS) $(HOSTLDFLAGS)
KBUILD_HOSTLDLIBS   := $(HOST_LFS_LIBS) $(HOSTLDLIBS)

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
CFLAGS_KERNEL	=

USERINCLUDE    := \
		-I$(srctree)/arch/x86/include/uapi \
		-I$(objtree)/arch/x86/include/generated/uapi \
		-I$(srctree)/include/uapi \
		-I$(objtree)/include/generated/uapi \
                -include $(srctree)/include/linux/compiler-version.h \
                -include $(srctree)/include/linux/kconfig.h

export LINUXINCLUDE    := \
		-I$(srctree)/arch/x86/include \
		-I$(objtree)/arch/x86/include/generated \
		-I$(srctree)/include \
		-I$(objtree)/include \
		$(USERINCLUDE)

KBUILD_AFLAGS   := -D__ASSEMBLY__ -fno-PIE -include /a/sources/linux/config.h

export KBUILD_CPPFLAGS := -D__KERNEL__ -include /a/sources/linux/config.h -fmacro-prefix-map=$(srctree)/=

export ARCH SRCARCH CONFIG_SHELL BASH HOSTCC KBUILD_HOSTCFLAGS LD CC
export CPP AR NM STRIP OBJCOPY OBJDUMP LEX YACC AWK
export CHECK MAKE UTS_MACHINE
export KBUILD_HOSTLDFLAGS KBUILD_HOSTLDLIBS
export NOSTDINC_FLAGS
export KBUILD_CFLAGS CFLAGS_KERNEL
export KBUILD_AFLAGS

quiet_cmd_makefile = GEN     Makefile
      cmd_makefile = { \
	echo "\# Automatically generated by $(srctree)/Makefile: don't edit"; \
	echo "include $(srctree)/Makefile"; \
	} > Makefile

all: bzImage

core-y := init/ arch/x86/ kernel/ mm/ fs/ security/ crypto/ block/
drivers-y := drivers/
drivers-y += net/
libs-y := lib/

export REALMODE_CFLAGS	:= -m16 -g -Os -DDISABLE_BRANCH_PROFILING -D__DISABLE_EXPORTS -Wall -Wstrict-prototypes -march=i386 -mregparm=3 -fno-strict-aliasing -fomit-frame-pointer -fno-pic -mno-mmx -mno-sse -fcf-protection=none -include /a/sources/linux/config.h -ffreestanding -fno-stack-protector -Wno-address-of-packed-member

KBUILD_CFLAGS := -Wall -Wundef -Werror=strict-prototypes -Wno-trigraphs \
		   -fno-strict-aliasing -fno-common -fshort-wchar -fno-PIE \
		   -Werror=implicit-function-declaration -Werror=implicit-int \
		   -Werror=return-type -Wno-format-security \
		   -std=gnu11 -include /a/sources/linux/config.h 
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

archscripts:
	$(Q) $(MAKE) -f $(srctree)/scripts/Makefile.build obj=arch/x86/tools relocs

archheaders:
	$(Q) $(MAKE) -f $(srctree)/scripts/Makefile.build obj=arch/x86/entry/syscalls all

head-y := arch/x86/kernel/head_64.o
head-y += arch/x86/kernel/head64.o
head-y += arch/x86/kernel/ebda.o
head-y += arch/x86/kernel/platform-quirks.o
libs-y  += arch/x86/lib/
drivers-y += arch/x86/pci/

bzImage: vmlinux
	$(Q) $(MAKE) -f $(srctree)/scripts/Makefile.build obj=arch/x86/boot arch/x86/boot/bzImage

NOSTDINC_FLAGS += -nostdinc

vmlinux-dirs	:= $(patsubst %/,%,$(filter %/, $(core-y) $(drivers-y) $(libs-y)))

build-dirs	:= $(vmlinux-dirs)

KBUILD_VMLINUX_OBJS := $(head-y) $(patsubst %/,%/built-in.a, $(core-y))
KBUILD_VMLINUX_OBJS += $(addsuffix built-in.a, $(filter %/, $(libs-y)))
KBUILD_VMLINUX_OBJS += $(patsubst %/,%/built-in.a, $(drivers-y))
export KBUILD_VMLINUX_OBJS

export KBUILD_VMLINUX_LIBS := $(patsubst %/,%/lib.a, $(libs-y))

export KBUILD_LDS := arch/x86/kernel/vmlinux.lds

vmlinux-deps := $(KBUILD_LDS) $(KBUILD_VMLINUX_OBJS) $(KBUILD_VMLINUX_LIBS)
$(vmlinux-deps): $(vmlinux-dirs)

vmlinux: scripts/link-vmlinux.sh $(vmlinux-deps)
	$(Q) $(CONFIG_SHELL) $< "$(LD)"

include/config/kernel.release:

PHONY += prepare0 archprepare

archprepare: archheaders archscripts scripts include/config/kernel.release \
	asm-generic $(version_h) include/generated/utsrelease.h

prepare0: archprepare
	$(Q) $(MAKE) -f $(srctree)/scripts/Makefile.build obj=.

asm-generic := -f $(srctree)/scripts/Makefile.asm-generic obj

PHONY += asm-generic uapi-asm-generic
asm-generic: uapi-asm-generic
	$(Q) $(MAKE) $(asm-generic)=arch/x86/include/generated/asm generic=include/asm-generic

uapi-asm-generic:
	$(Q) $(MAKE) $(asm-generic)=arch/x86/include/generated/uapi/asm generic=include/uapi/asm-generic

uts_len := 64
define filechk_utsrelease.h
	echo \#define UTS_RELEASE \"$(KERNELRELEASE)\"
endef

define filechk_version.h
	if [ $(SUBLEVEL) -gt 255 ]; then                                 \
		echo \#define LINUX_VERSION_CODE $(shell                 \
		expr $(VERSION) \* 65536 + $(PATCHLEVEL) \* 256 + 255); \
	else                                                             \
		echo \#define LINUX_VERSION_CODE $(shell                 \
		expr $(VERSION) \* 65536 + $(PATCHLEVEL) \* 256 + $(SUBLEVEL)); \
	fi;                                                              \
	echo '#define KERNEL_VERSION(a,b,c) (((a) << 16) + ((b) << 8) +  \
	((c) > 255 ? 255 : (c)))';                                       \
	echo \#define LINUX_VERSION_MAJOR $(VERSION);                    \
	echo \#define LINUX_VERSION_PATCHLEVEL $(PATCHLEVEL);            \
	echo \#define LINUX_VERSION_SUBLEVEL $(SUBLEVEL)
endef

$(version_h):
	$(call filechk,version.h)

include/generated/utsrelease.h: include/config/kernel.release
	$(call filechk,utsrelease.h)

PHONY += $(build-dirs)
$(build-dirs): prepare0
	$(Q) $(MAKE) -f $(srctree)/scripts/Makefile.build obj=$@

.PHONY: $(PHONY)
