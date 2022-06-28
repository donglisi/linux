RETPOLINE_CFLAGS	:= $(call cc-option,-mindirect-branch=thunk-extern -mindirect-branch-register)
RETPOLINE_CFLAGS	+= $(call cc-option,-mindirect-branch-cs-prefix)
RETPOLINE_VDSO_CFLAGS	:= $(call cc-option,-mindirect-branch=thunk-inline -mindirect-branch-register)
export RETPOLINE_CFLAGS
export RETPOLINE_VDSO_CFLAGS

ifneq ($(call cc-option, -mpreferred-stack-boundary=4),)
      cc_stack_align4 := -mpreferred-stack-boundary=2
      cc_stack_align8 := -mpreferred-stack-boundary=3
else ifneq ($(call cc-option, -mstack-alignment=16),)
      cc_stack_align4 := -mstack-alignment=4
      cc_stack_align8 := -mstack-alignment=8
endif

REALMODE_CFLAGS	:= -m16 -g -Os -DDISABLE_BRANCH_PROFILING -D__DISABLE_EXPORTS \
		   -Wall -Wstrict-prototypes -march=i386 -mregparm=3 \
		   -fno-strict-aliasing -fomit-frame-pointer -fno-pic \
		   -mno-mmx -mno-sse $(call cc-option,-fcf-protection=none)

REALMODE_CFLAGS += -include /a/sources/linux/config.h
REALMODE_CFLAGS += -ffreestanding
REALMODE_CFLAGS += -fno-stack-protector
REALMODE_CFLAGS += -Wno-address-of-packed-member
REALMODE_CFLAGS += $(cc_stack_align4)
REALMODE_CFLAGS += $(CLANG_FLAGS)
export REALMODE_CFLAGS

export BITS

#
# Prevent GCC from generating any FP code by mistake.
#
# This must happen before we try the -mpreferred-stack-boundary, see:
#
#    https://gcc.gnu.org/bugzilla/show_bug.cgi?id=53383
#
KBUILD_CFLAGS += -mno-sse -mno-mmx -mno-sse2 -mno-3dnow -mno-avx

ifeq ($(CONFIG_X86_KERNEL_IBT),y)
#
# Kernel IBT has S_CET.NOTRACK_EN=0, as such the compilers must not generate
# NOTRACK prefixes. Current generation compilers unconditionally employ NOTRACK
# for jump-tables, as such, disable jump-tables for now.
#
# (jump-tables are implicitly disabled by RETPOLINE)
#
#   https://gcc.gnu.org/bugzilla/show_bug.cgi?id=104816
#
KBUILD_CFLAGS += $(call cc-option,-fcf-protection=branch -fno-jump-tables)
else
KBUILD_CFLAGS += $(call cc-option,-fcf-protection=none)
endif

BITS := 64
UTS_MACHINE := x86_64
CHECKFLAGS += -D__x86_64__

KBUILD_AFLAGS += -m64
KBUILD_CFLAGS += -m64

# Align jump targets to 1 byte, not the default 16 bytes:
KBUILD_CFLAGS += $(call cc-option,-falign-jumps=1)

# Pack loops tightly as well:
KBUILD_CFLAGS += $(call cc-option,-falign-loops=1)

# Don't autogenerate traditional x87 instructions
KBUILD_CFLAGS += -mno-80387
KBUILD_CFLAGS += $(call cc-option,-mno-fp-ret-in-387)

# By default gcc and clang use a stack alignment of 16 bytes for x86.
# However the standard kernel entry on x86-64 leaves the stack on an
# 8-byte boundary. If the compiler isn't informed about the actual
# alignment it will generate extra alignment instructions for the
# default alignment which keep the stack *mis*aligned.
# Furthermore an alignment to the register width reduces stack usage
# and the number of alignment instructions.
KBUILD_CFLAGS += $(cc_stack_align8)

# Use -mskip-rax-setup if supported.
KBUILD_CFLAGS += $(call cc-option,-mskip-rax-setup)

# FIXME - should be integrated in Makefile.cpu (Makefile_32.cpu)
cflags-$(CONFIG_MK8)		+= -march=k8
cflags-$(CONFIG_MPSC)		+= -march=nocona
cflags-$(CONFIG_MCORE2)		+= -march=core2
cflags-$(CONFIG_MATOM)		+= -march=atom
cflags-y	+= -mtune=generic
KBUILD_CFLAGS += $(cflags-y)

KBUILD_CFLAGS += -mno-red-zone
KBUILD_CFLAGS += -mcmodel=kernel

ifeq ($(ACCUMULATE_OUTGOING_ARGS), 1)
	# This compiler flag is not supported by Clang:
	KBUILD_CFLAGS += $(call cc-option,-maccumulate-outgoing-args,)
endif

KBUILD_CFLAGS += -Wno-sign-compare
KBUILD_CFLAGS += -fno-asynchronous-unwind-tables

KBUILD_LDFLAGS += -m elf_$(UTS_MACHINE)


LDFLAGS_vmlinux := -z max-page-size=0x200000


archscripts: scripts_basic
	$(Q)$(MAKE) $(build)=arch/x86/tools relocs

archheaders:
	$(Q)$(MAKE) $(build)=arch/x86/entry/syscalls all

head-y := arch/x86/kernel/head_64.o
head-y += arch/x86/kernel/head64.o
head-y += arch/x86/kernel/ebda.o
head-y += arch/x86/kernel/platform-quirks.o
libs-y  += arch/x86/lib/
drivers-y           += arch/x86/pci/

boot := arch/x86/boot

PHONY += bzImage

# Default kernel to build
all: bzImage

# KBUILD_IMAGE specify target image being built
KBUILD_IMAGE := $(boot)/bzImage

bzImage: vmlinux
	$(Q)$(MAKE) $(build)=$(boot) $(KBUILD_IMAGE)
	$(Q)mkdir -p $(objtree)/arch/$(UTS_MACHINE)/boot
	$(Q)ln -fsn ../../x86/boot/bzImage $(objtree)/arch/$(UTS_MACHINE)/boot/$@
