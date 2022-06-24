# SPDX-License-Identifier: GPL-2.0
VERSION = 5
PATCHLEVEL = 19
SUBLEVEL = 0
EXTRAVERSION = -rc1
NAME = Superb Owl

$(if $(filter __%, $(MAKECMDGOALS)), \
	$(error targets prefixed with '__' are only for internal use))

PHONY := __all
__all:

ifneq ($(sub_make_done),1)

MAKEFLAGS += -rR

unexport LC_ALL
LC_COLLATE=C
LC_NUMERIC=C
export LC_COLLATE LC_NUMERIC

unexport GREP_OPTIONS

ifeq ("$(origin V)", "command line")
  KBUILD_VERBOSE = $(V)
endif
ifndef KBUILD_VERBOSE
  KBUILD_VERBOSE = 0
endif

ifeq ($(KBUILD_VERBOSE),1)
  quiet =
  Q =
else
  quiet=quiet_
  Q = @
endif

ifneq ($(findstring s,$(filter-out --%,$(MAKEFLAGS))),)
  quiet=silent_
  KBUILD_VERBOSE = 0
endif

export quiet Q KBUILD_VERBOSE

ifeq ("$(origin C)", "command line")
  KBUILD_CHECKSRC = $(C)
endif
ifndef KBUILD_CHECKSRC
  KBUILD_CHECKSRC = 0
endif

export KBUILD_CHECKSRC

# Use make M=dir or set the environment variable KBUILD_EXTMOD to specify the
# directory of external module to build. Setting M= takes precedence.
ifeq ("$(origin M)", "command line")
  KBUILD_EXTMOD := $(M)
endif

$(if $(word 2, $(KBUILD_EXTMOD)), \
	$(error building multiple external modules is not supported))

# Remove trailing slashes
ifneq ($(filter %/, $(KBUILD_EXTMOD)),)
KBUILD_EXTMOD := $(shell dirname $(KBUILD_EXTMOD).)
endif

export KBUILD_EXTMOD

ifeq ("$(origin O)", "command line")
  KBUILD_OUTPUT := $(O)
endif

ifneq ($(KBUILD_OUTPUT),)
# Make's built-in functions such as $(abspath ...), $(realpath ...) cannot
# expand a shell special character '~'. We use a somewhat tedious way here.
abs_objtree := $(shell mkdir -p $(KBUILD_OUTPUT) && cd $(KBUILD_OUTPUT) && pwd)
$(if $(abs_objtree),, \
     $(error failed to create output directory "$(KBUILD_OUTPUT)"))

# $(realpath ...) resolves symlinks
abs_objtree := $(realpath $(abs_objtree))
else
abs_objtree := $(CURDIR)
endif # ifneq ($(KBUILD_OUTPUT),)

ifeq ($(abs_objtree),$(CURDIR))
# Suppress "Entering directory ..." unless we are changing the work directory.
MAKEFLAGS += --no-print-directory
else
need-sub-make := 1
endif

this-makefile := $(lastword $(MAKEFILE_LIST))
abs_srctree := $(realpath $(dir $(this-makefile)))

ifneq ($(words $(subst :, ,$(abs_srctree))), 1)
$(error source directory cannot contain spaces or colons)
endif

ifneq ($(abs_srctree),$(abs_objtree))
# Look for make include files relative to root of kernel src
#
# --included-dir is added for backward compatibility, but you should not rely on
# it. Please add $(srctree)/ prefix to include Makefiles in the source tree.
MAKEFLAGS += --include-dir=$(abs_srctree)
endif

ifneq ($(filter 3.%,$(MAKE_VERSION)),)
# 'MAKEFLAGS += -rR' does not immediately become effective for GNU Make 3.x
# We need to invoke sub-make to avoid implicit rules in the top Makefile.
need-sub-make := 1
# Cancel implicit rules for this Makefile.
$(this-makefile): ;
endif

export abs_srctree abs_objtree
export sub_make_done := 1

ifeq ($(need-sub-make),1)

PHONY += $(MAKECMDGOALS) __sub-make

$(filter-out $(this-makefile), $(MAKECMDGOALS)) __all: __sub-make
	@:

# Invoke a second make in the output directory, passing relevant variables
__sub-make:
	$(Q)$(MAKE) -C $(abs_objtree) -f $(abs_srctree)/Makefile $(MAKECMDGOALS)

endif # need-sub-make
endif # sub_make_done

# We process the rest of the Makefile if this is the final invocation of make
ifeq ($(need-sub-make),)

# Do not print "Entering directory ...",
# but we want to display it when entering to the output directory
# so that IDEs/editors are able to understand relative filenames.
MAKEFLAGS += --no-print-directory

ifeq ($(abs_srctree),$(abs_objtree))
        # building in the source tree
        srctree := .
	building_out_of_srctree :=
else
        ifeq ($(abs_srctree)/,$(dir $(abs_objtree)))
                # building in a subdirectory of the source tree
                srctree := ..
        else
                srctree := $(abs_srctree)
        endif
	building_out_of_srctree := 1
endif

ifneq ($(KBUILD_ABS_SRCTREE),)
srctree := $(abs_srctree)
endif

objtree		:= .
VPATH		:= $(srctree)

export building_out_of_srctree srctree objtree VPATH

# To make sure we do not include .config for any of the *config targets
# catch them early, and hand them over to scripts/kconfig/Makefile
# It is allowed to specify more targets when calling make, including
# mixing *config targets and build targets.
# For example 'make oldconfig all'.
# Detect when mixed targets is specified, and make a second invocation
# of make so .config is not included in this case either (for *config).

version_h := include/generated/uapi/linux/version.h

clean-targets := %clean mrproper cleandocs
no-dot-config-targets := $(clean-targets) \
			 cscope gtags TAGS tags help% %docs check% coccicheck \
			 $(version_h) headers headers_% archheaders archscripts \
			 %asm-generic kernelversion %src-pkg dt_binding_check \
			 outputmakefile
# Installation targets should not require compiler. Unfortunately, vdso_install
# is an exception where build artifacts may be updated. This must be fixed.
no-compiler-targets := $(no-dot-config-targets) install dtbs_install \
			headers_install modules_install kernelrelease image_name
no-sync-config-targets := $(no-dot-config-targets) %install kernelrelease \
			  image_name
single-targets := %.a %.i %.ko %.lds %.ll %.lst %.mod %.o %.s %.symtypes %/

config-build	:=
mixed-build	:=
need-config	:= 1
need-compiler	:= 1
may-sync-config	:= 1
single-build	:=

ifneq ($(filter $(no-dot-config-targets), $(MAKECMDGOALS)),)
	ifeq ($(filter-out $(no-dot-config-targets), $(MAKECMDGOALS)),)
		need-config :=
	endif
endif

ifneq ($(filter $(no-compiler-targets), $(MAKECMDGOALS)),)
	ifeq ($(filter-out $(no-compiler-targets), $(MAKECMDGOALS)),)
		need-compiler :=
	endif
endif

ifneq ($(filter $(no-sync-config-targets), $(MAKECMDGOALS)),)
	ifeq ($(filter-out $(no-sync-config-targets), $(MAKECMDGOALS)),)
		may-sync-config :=
	endif
endif

ifneq ($(KBUILD_EXTMOD),)
	may-sync-config :=
endif

ifeq ($(KBUILD_EXTMOD),)
        ifneq ($(filter %config,$(MAKECMDGOALS)),)
		config-build := 1
                ifneq ($(words $(MAKECMDGOALS)),1)
			mixed-build := 1
                endif
        endif
endif

# We cannot build single targets and the others at the same time
ifneq ($(filter $(single-targets), $(MAKECMDGOALS)),)
	single-build := 1
	ifneq ($(filter-out $(single-targets), $(MAKECMDGOALS)),)
		mixed-build := 1
	endif
endif

# For "make -j clean all", "make -j mrproper defconfig all", etc.
ifneq ($(filter $(clean-targets),$(MAKECMDGOALS)),)
        ifneq ($(filter-out $(clean-targets),$(MAKECMDGOALS)),)
		mixed-build := 1
        endif
endif

# install and modules_install need also be processed one by one
ifneq ($(filter install,$(MAKECMDGOALS)),)
        ifneq ($(filter modules_install,$(MAKECMDGOALS)),)
		mixed-build := 1
        endif
endif

ifdef mixed-build
# ===========================================================================
# We're called with mixed targets (*config and build targets).
# Handle them one by one.

PHONY += $(MAKECMDGOALS) __build_one_by_one

$(MAKECMDGOALS): __build_one_by_one
	@:

__build_one_by_one:
	$(Q)set -e; \
	for i in $(MAKECMDGOALS); do \
		$(MAKE) -f $(srctree)/Makefile $$i; \
	done

else # !mixed-build

include $(srctree)/scripts/Kbuild.include

# Read KERNELRELEASE from include/config/kernel.release (if it exists)
KERNELRELEASE = $(shell cat include/config/kernel.release 2> /dev/null)
KERNELVERSION = $(VERSION)$(if $(PATCHLEVEL),.$(PATCHLEVEL)$(if $(SUBLEVEL),.$(SUBLEVEL)))$(EXTRAVERSION)
export VERSION PATCHLEVEL SUBLEVEL KERNELRELEASE KERNELVERSION

include $(srctree)/scripts/subarch.include

# Cross compiling and selecting different set of gcc/bin-utils
# ---------------------------------------------------------------------------
#
# When performing cross compilation for other architectures ARCH shall be set
# to the target architecture. (See arch/* for the possibilities).
# ARCH can be set during invocation of make:
# make ARCH=ia64
# Another way is to have ARCH set in the environment.
# The default ARCH is the host where make is executed.

# CROSS_COMPILE specify the prefix used for all executables used
# during compilation. Only gcc and related bin-utils executables
# are prefixed with $(CROSS_COMPILE).
# CROSS_COMPILE can be set on the command line
# make CROSS_COMPILE=ia64-linux-
# Alternatively CROSS_COMPILE can be set in the environment.
# Default value for CROSS_COMPILE is not to prefix executables
# Note: Some architectures assign CROSS_COMPILE in their arch/*/Makefile
ARCH		?= $(SUBARCH)

# Architecture as present in compile.h
UTS_MACHINE 	:= $(ARCH)
SRCARCH 	:= $(ARCH)

ifeq ($(ARCH),x86_64)
        SRCARCH := x86
endif

KCONFIG_CONFIG	?= .config
export KCONFIG_CONFIG

# SHELL used by kbuild
CONFIG_SHELL := sh

HOST_LFS_CFLAGS := $(shell getconf LFS_CFLAGS 2>/dev/null)
HOST_LFS_LDFLAGS := $(shell getconf LFS_LDFLAGS 2>/dev/null)
HOST_LFS_LIBS := $(shell getconf LFS_LIBS 2>/dev/null)

HOSTCC	= gcc
HOSTCXX	= g++
HOSTPKG_CONFIG	= pkg-config

KBUILD_USERHOSTCFLAGS := -Wall -Wmissing-prototypes -Wstrict-prototypes \
			 -O2 -fomit-frame-pointer -std=gnu11 \
			 -Wdeclaration-after-statement
KBUILD_USERCFLAGS  := $(KBUILD_USERHOSTCFLAGS) $(USERCFLAGS)
KBUILD_USERLDFLAGS := $(USERLDFLAGS)

KBUILD_HOSTCFLAGS   := $(KBUILD_USERHOSTCFLAGS) $(HOST_LFS_CFLAGS) $(HOSTCFLAGS)
KBUILD_HOSTCXXFLAGS := -Wall -O2 $(HOST_LFS_CFLAGS) $(HOSTCXXFLAGS)
KBUILD_HOSTLDFLAGS  := $(HOST_LFS_LDFLAGS) $(HOSTLDFLAGS)
KBUILD_HOSTLDLIBS   := $(HOST_LFS_LIBS) $(HOSTLDLIBS)

# Make variables (CC, etc...)
CPP		= $(CC) -E
CC		= $(CROSS_COMPILE)gcc
LD		= $(CROSS_COMPILE)ld
AR		= $(CROSS_COMPILE)ar
NM		= $(CROSS_COMPILE)nm
OBJCOPY		= $(CROSS_COMPILE)objcopy
OBJDUMP		= $(CROSS_COMPILE)objdump
READELF		= $(CROSS_COMPILE)readelf
STRIP		= $(CROSS_COMPILE)strip
PAHOLE		= pahole
RESOLVE_BTFIDS	= $(objtree)/tools/bpf/resolve_btfids/resolve_btfids
LEX		= flex
YACC		= bison
AWK		= awk
INSTALLKERNEL  := installkernel
DEPMOD		= depmod
PERL		= perl
PYTHON3		= python3
CHECK		= sparse
BASH		= bash
KGZIP		= gzip
KBZIP2		= bzip2
KLZOP		= lzop
LZMA		= lzma
LZ4		= lz4c
XZ		= xz
ZSTD		= zstd

PAHOLE_FLAGS	= $(shell PAHOLE=$(PAHOLE) $(srctree)/scripts/pahole-flags.sh)

CHECKFLAGS     := -D__linux__ -Dlinux -D__STDC__ -Dunix -D__unix__ \
		  -Wbitwise -Wno-return-void -Wno-unknown-attribute $(CF)
NOSTDINC_FLAGS :=
CFLAGS_MODULE   =
AFLAGS_MODULE   =
LDFLAGS_MODULE  =
CFLAGS_KERNEL	=
AFLAGS_KERNEL	=
LDFLAGS_vmlinux =

# Use USERINCLUDE when you must reference the UAPI directories only.
USERINCLUDE    := \
		-I$(srctree)/arch/$(SRCARCH)/include/uapi \
		-I$(objtree)/arch/$(SRCARCH)/include/generated/uapi \
		-I$(srctree)/include/uapi \
		-I$(objtree)/include/generated/uapi \
                -include $(srctree)/include/linux/compiler-version.h \
                -include $(srctree)/include/linux/kconfig.h

# Use LINUXINCLUDE when you must reference the include/ directory.
# Needed to be compatible with the O= option
LINUXINCLUDE    := \
		-I$(srctree)/arch/$(SRCARCH)/include \
		-I$(objtree)/arch/$(SRCARCH)/include/generated \
		$(if $(building_out_of_srctree),-I$(srctree)/include) \
		-I$(objtree)/include \
		$(USERINCLUDE)

KBUILD_AFLAGS   := -D__ASSEMBLY__ -fno-PIE
KBUILD_CFLAGS   := -Wall -Wundef -Werror=strict-prototypes -Wno-trigraphs \
		   -fno-strict-aliasing -fno-common -fshort-wchar -fno-PIE \
		   -Werror=implicit-function-declaration -Werror=implicit-int \
		   -Werror=return-type -Wno-format-security \
		   -std=gnu11

KBUILD_CFLAGS += -DCONFIG_KERNFS
KBUILD_CFLAGS += -DCONFIG_SYSCTL
KBUILD_CFLAGS += -DCONFIG_PCI_DIRECT
KBUILD_CFLAGS += -DCONFIG_SYSFS
KBUILD_CFLAGS += -DCONFIG_PROC_PID_ARCH_STATUS
KBUILD_CFLAGS += -DCONFIG_PROC_PAGE_MONITOR
KBUILD_CFLAGS += -DCONFIG_PROC_SYSCTL
KBUILD_CFLAGS += -DCONFIG_PROC_FS
KBUILD_CFLAGS += -DCONFIG_FILE_LOCKING
KBUILD_CFLAGS += -DCONFIG_IO_WQ
KBUILD_CFLAGS += -DCONFIG_ARCH_HAS_COPY_MC
KBUILD_CFLAGS += -DCONFIG_ARCH_HAS_UACCESS_FLUSHCACHE
KBUILD_CFLAGS += -DCONFIG_ARCH_HAS_PMEM_API
KBUILD_CFLAGS += -DCONFIG_ARCH_STACKWALK
KBUILD_CFLAGS += -DCONFIG_STACK_HASH_ORDER=20
KBUILD_CFLAGS += -DCONFIG_COREDUMP
KBUILD_CFLAGS += -DCONFIG_BLOCK
KBUILD_CFLAGS += -DCONFIG_SG_POOL
KBUILD_CFLAGS += -DCONFIG_CPUMASK_OFFSTACK
KBUILD_CFLAGS += -DCONFIG_GENERIC_IOMAP
KBUILD_CFLAGS += -DCONFIG_GENERIC_PCI_IOMAP
KBUILD_CFLAGS += -DCONFIG_HAS_IOPORT_MAP
KBUILD_CFLAGS += -DCONFIG_HAS_IOMEM
KBUILD_CFLAGS += -DCONFIG_GENERIC_STRNLEN_USER
KBUILD_CFLAGS += -DCONFIG_GENERIC_STRNCPY_FROM_USER
KBUILD_CFLAGS += -DCONFIG_BINARY_PRINTF
KBUILD_CFLAGS += -DCONFIG_CHECK_SIGNATURE
KBUILD_CFLAGS += -DCONFIG_SGL_ALLOC
KBUILD_CFLAGS += -DCONFIG_CRC32_SLICEBY8
KBUILD_CFLAGS += -DCONFIG_GENERIC_GETTIMEOFDAY
KBUILD_CFLAGS += -DCONFIG_SWIOTLB
KBUILD_CFLAGS += -DCONFIG_NEED_DMA_MAP_STATE
KBUILD_CFLAGS += -DCONFIG_NEED_SG_DMA_LENGTH
KBUILD_CFLAGS += -DCONFIG_HAS_DMA
KBUILD_CFLAGS += -DCONFIG_DEBUG_BUGVERBOSE
KBUILD_CFLAGS += -DCONFIG_DEBUG_MEMORY_INIT
KBUILD_CFLAGS += -DCONFIG_HARDLOCKUP_CHECK_TIMESTAMP
KBUILD_CFLAGS += -DCONFIG_PRINTK_TIME
KBUILD_CFLAGS += -DCONFIG_STACKTRACE
KBUILD_CFLAGS += -DCONFIG_HAVE_EBPF_JIT
KBUILD_CFLAGS += -DCONFIG_ARCH_DMA_ADDR_T_64BIT
KBUILD_CFLAGS += -DCONFIG_ARCH_USE_CMPXCHG_LOCKREF
KBUILD_CFLAGS += -DCONFIG_ARCH_HAS_FAST_MULTIPLIER
KBUILD_CFLAGS += -DCONFIG_ARCH_USE_SYM_ANNOTATIONS
KBUILD_CFLAGS += -DCONFIG_SRCU
KBUILD_CFLAGS += -DCONFIG_CRYPTO_HASH
KBUILD_CFLAGS += -DCONFIG_HAVE_HARDENED_USERCOPY_ALLOCATOR
KBUILD_CFLAGS += -DCONFIG_DEFAULT_TCP_CONG='"cubic"'
KBUILD_CFLAGS += -DCONFIG_AF_UNIX_OOB
KBUILD_CFLAGS += -DCONFIG_UNIX
KBUILD_CFLAGS += -DCONFIG_NET_FLOW_LIMIT
KBUILD_CFLAGS += -DCONFIG_NET_RX_BUSY_POLL
KBUILD_CFLAGS += -DCONFIG_RFS_ACCEL
KBUILD_CFLAGS += -DCONFIG_INET
KBUILD_CFLAGS += -DCONFIG_SERIAL_8250_RUNTIME_UARTS=4
KBUILD_CFLAGS += -DCONFIG_SERIAL_8250_NR_UARTS=4
KBUILD_CFLAGS += -DCONFIG_SERIAL_8250_CONSOLE
KBUILD_CFLAGS += -DCONFIG_SERIAL_EARLYCON
KBUILD_CFLAGS += -DCONFIG_VT_HW_CONSOLE_BINDING
KBUILD_CFLAGS += -DCONFIG_UNIX98_PTYS
KBUILD_CFLAGS += -DCONFIG_HW_CONSOLE
KBUILD_CFLAGS += -DCONFIG_VT_CONSOLE_SLEEP
KBUILD_CFLAGS += -DCONFIG_CONSOLE_TRANSLATIONS
KBUILD_CFLAGS += -DCONFIG_VT_CONSOLE
KBUILD_CFLAGS += -DCONFIG_NET
KBUILD_CFLAGS += -DCONFIG_SERIAL_CORE_CONSOLE
KBUILD_CFLAGS += -DCONFIG_CLKEVT_I8253
KBUILD_CFLAGS += -DCONFIG_CLKSRC_I8253
KBUILD_CFLAGS += -DCONFIG_CONSOLE_LOGLEVEL_QUIET=4
KBUILD_CFLAGS += -DCONFIG_MESSAGE_LOGLEVEL_DEFAULT=4
KBUILD_CFLAGS += -DCONFIG_CONSOLE_LOGLEVEL_DEFAULT=7
KBUILD_CFLAGS += -DCONFIG_RCU_CPU_STALL_TIMEOUT=21
KBUILD_CFLAGS += -DCONFIG_RCU_EXP_CPU_STALL_TIMEOUT=0
KBUILD_CFLAGS += -DCONFIG_HAVE_SYSCALL_TRACEPOINTS
KBUILD_CFLAGS += -DCONFIG_PANIC_ON_OOPS_VALUE=0
KBUILD_CFLAGS += -DCONFIG_PANIC_TIMEOUT=0
KBUILD_CFLAGS += -DCONFIG_IO_DELAY_0X80
KBUILD_CFLAGS += -DCONFIG_UNWINDER_ORC
KBUILD_CFLAGS += -DCONFIG_PCIEASPM
KBUILD_CFLAGS += -DCONFIG_VGA_ARB_MAX_GPUS=16
KBUILD_CFLAGS += -DCONFIG_VGA_ARB
KBUILD_CFLAGS += -DCONFIG_PCI_QUIRKS
KBUILD_CFLAGS += -DCONFIG_PCI_DOMAINS
KBUILD_CFLAGS += -DCONFIG_PCI
KBUILD_CFLAGS += -DCONFIG_DMI_SCAN_MACHINE_NON_EFI_FALLBACK
KBUILD_CFLAGS += -DCONFIG_FIRMWARE_MEMMAP
KBUILD_CFLAGS += -DCONFIG_VIRTIO_PCI_LEGACY
KBUILD_CFLAGS += -DCONFIG_GENERIC_CPU_AUTOPROBE
KBUILD_CFLAGS += -DCONFIG_DEVTMPFS_MOUNT
KBUILD_CFLAGS += -DCONFIG_DEVTMPFS
KBUILD_CFLAGS += -DCONFIG_AS_TPAUSE
KBUILD_CFLAGS += -DCONFIG_RPS
KBUILD_CFLAGS += -DCONFIG_FW_LOADER
KBUILD_CFLAGS += -DGENERIC_CPU_VULNERABILITIES
KBUILD_CFLAGS += -DCONFIG_VGA_CONSOLE
KBUILD_CFLAGS += -DCONFIG_RANDOM_TRUST_CPU
KBUILD_CFLAGS += -DCONFIG_BPF
KBUILD_CFLAGS += -DCONFIG_EARLY_PRINTK
KBUILD_CFLAGS += -DCONFIG_DUMMY_CONSOLE_ROWS=25
KBUILD_CFLAGS += -DCONFIG_DUMMY_CONSOLE_COLUMNS=80
KBUILD_CFLAGS += -DCONFIG_DUMMY_CONSOLE
KBUILD_CFLAGS += -DCONFIG_VT
KBUILD_CFLAGS += -DCONFIG_TTY
KBUILD_CFLAGS += -DCONFIG_NLATTR
KBUILD_CFLAGS += -DCONFIG_GENERIC_NET_UTILS

KBUILD_CPPFLAGS := -D__KERNEL__
KBUILD_AFLAGS_KERNEL :=
KBUILD_AFLAGS_MODULE  := -DMODULE
KBUILD_CFLAGS_MODULE  := -DMODULE
KBUILD_LDFLAGS_MODULE :=
KBUILD_LDFLAGS :=
CLANG_FLAGS :=

CONFIG_FRAME_WARN=1024

export ARCH SRCARCH CONFIG_SHELL BASH HOSTCC KBUILD_HOSTCFLAGS CROSS_COMPILE LD CC HOSTPKG_CONFIG
export CPP AR NM STRIP OBJCOPY OBJDUMP READELF PAHOLE RESOLVE_BTFIDS LEX YACC AWK INSTALLKERNEL
export PERL PYTHON3 CHECK CHECKFLAGS MAKE UTS_MACHINE HOSTCXX
export KGZIP KBZIP2 KLZOP LZMA LZ4 XZ ZSTD
export KBUILD_HOSTCXXFLAGS KBUILD_HOSTLDFLAGS KBUILD_HOSTLDLIBS LDFLAGS_MODULE
export KBUILD_USERCFLAGS KBUILD_USERLDFLAGS

export KBUILD_CPPFLAGS NOSTDINC_FLAGS LINUXINCLUDE OBJCOPYFLAGS KBUILD_LDFLAGS
export KBUILD_CFLAGS CFLAGS_KERNEL CFLAGS_MODULE
export KBUILD_AFLAGS AFLAGS_KERNEL AFLAGS_MODULE
export KBUILD_AFLAGS_MODULE KBUILD_CFLAGS_MODULE KBUILD_LDFLAGS_MODULE
export KBUILD_AFLAGS_KERNEL KBUILD_CFLAGS_KERNEL
export PAHOLE_FLAGS

export RCS_TAR_IGNORE := --exclude SCCS --exclude BitKeeper --exclude .svn \
			 --exclude CVS --exclude .pc --exclude .hg --exclude .git

# ===========================================================================
# Rules shared between *config targets and build targets

# Basic helpers built in scripts/basic/
PHONY += scripts_basic
scripts_basic:
	$(Q)$(MAKE) $(build)=scripts/basic

PHONY += outputmakefile
ifdef building_out_of_srctree
# Before starting out-of-tree build, make sure the source tree is clean.
# outputmakefile generates a Makefile in the output directory, if using a
# separate output directory. This allows convenient use of make in the
# output directory.
# At the same time when output Makefile generated, generate .gitignore to
# ignore whole output directory

quiet_cmd_makefile = GEN     Makefile
      cmd_makefile = { \
	echo "\# Automatically generated by $(srctree)/Makefile: don't edit"; \
	echo "include $(srctree)/Makefile"; \
	} > Makefile

outputmakefile:
	$(Q)if [ -f $(srctree)/.config -o \
		 -d $(srctree)/include/config -o \
		 -d $(srctree)/arch/$(SRCARCH)/include/generated ]; then \
		echo >&2 "***"; \
		echo >&2 "*** The source tree is not clean, please run 'make$(if $(findstring command line, $(origin ARCH)), ARCH=$(ARCH)) mrproper'"; \
		echo >&2 "*** in $(abs_srctree)";\
		echo >&2 "***"; \
		false; \
	fi
	$(Q)ln -fsn $(srctree) source
	$(call cmd,makefile)
	$(Q)test -e .gitignore || \
	{ echo "# this is build directory, ignore it"; echo "*"; } > .gitignore
endif

# The expansion should be delayed until arch/$(SRCARCH)/Makefile is included.
# Some architectures define CROSS_COMPILE in arch/$(SRCARCH)/Makefile.
# CC_VERSION_TEXT is referenced from Kconfig (so it needs export),
# and from include/config/auto.conf.cmd to detect the compiler upgrade.
CC_VERSION_TEXT = $(subst $(pound),,$(shell LC_ALL=C $(CC) --version 2>/dev/null | head -n 1))

ifneq ($(findstring clang,$(CC_VERSION_TEXT)),)
include $(srctree)/scripts/Makefile.clang
endif

# Include this also for config targets because some architectures need
# cc-cross-prefix to determine CROSS_COMPILE.
ifdef need-compiler
include $(srctree)/scripts/Makefile.compiler
endif

ifdef config-build
# ===========================================================================
# *config targets only - make sure prerequisites are updated, and descend
# in scripts/kconfig to make the *config target

# Read arch specific Makefile to set KBUILD_DEFCONFIG as needed.
# KBUILD_DEFCONFIG may point out an alternative default configuration
# used for 'make defconfig'
include $(srctree)/arch/$(SRCARCH)/Makefile
export KBUILD_DEFCONFIG KBUILD_KCONFIG CC_VERSION_TEXT

config: outputmakefile scripts_basic FORCE
	$(Q)$(MAKE) $(build)=scripts/kconfig $@

%config: outputmakefile scripts_basic FORCE
	$(Q)$(MAKE) $(build)=scripts/kconfig $@

else #!config-build
# ===========================================================================
# Build targets only - this includes vmlinux, arch specific targets, clean
# targets and others. In general all targets except *config targets.

# If building an external module we do not care about the all: rule
# but instead __all depend on modules
PHONY += all
ifeq ($(KBUILD_EXTMOD),)
__all: all
else
__all: modules
endif

# Decide whether to build built-in, modular, or both.
# Normally, just do built-in.

KBUILD_MODULES :=
KBUILD_BUILTIN := 1

# If we have only "make modules", don't compile built-in objects.
ifeq ($(MAKECMDGOALS),modules)
  KBUILD_BUILTIN :=
endif

# If we have "make <whatever> modules", compile modules
# in addition to whatever we do anyway.
# Just "make" or "make all" shall build modules as well

ifneq ($(filter all modules nsdeps %compile_commands.json clang-%,$(MAKECMDGOALS)),)
  KBUILD_MODULES := 1
endif

ifeq ($(MAKECMDGOALS),)
  KBUILD_MODULES := 1
endif

export KBUILD_MODULES KBUILD_BUILTIN

ifdef need-config
include include/config/auto.conf
endif

ifeq ($(KBUILD_EXTMOD),)
# Objects we will link into vmlinux / subdirs we need to visit
core-y		:= init/ arch/$(SRCARCH)/
drivers-y	:= drivers/
drivers-y += net/
libs-y		:= lib/
endif # KBUILD_EXTMOD

# The all: target is the default when no target is given on the
# command line.
# This allow a user to issue only 'make' to build a kernel including modules
# Defaults to vmlinux, but the arch makefile usually adds further targets
all: vmlinux

CFLAGS_GCOV	:= -fprofile-arcs -ftest-coverage
ifdef CONFIG_CC_IS_GCC
CFLAGS_GCOV	+= -fno-tree-loop-im
endif
export CFLAGS_GCOV

# The arch Makefiles can override CC_FLAGS_FTRACE. We may also append it later.
ifdef CONFIG_FUNCTION_TRACER
  CC_FLAGS_FTRACE := -pg
endif

include $(srctree)/arch/$(SRCARCH)/Makefile

ifdef need-config
ifdef may-sync-config
# Read in dependencies to all Kconfig* files, make sure to run syncconfig if
# changes are detected. This should be included after arch/$(SRCARCH)/Makefile
# because some architectures define CROSS_COMPILE there.
include include/config/auto.conf.cmd

$(KCONFIG_CONFIG):
	@echo >&2 '***'
	@echo >&2 '*** Configuration file "$@" not found!'
	@echo >&2 '***'
	@echo >&2 '*** Please run some configurator (e.g. "make oldconfig" or'
	@echo >&2 '*** "make menuconfig" or "make xconfig").'
	@echo >&2 '***'
	@/bin/false

# The actual configuration files used during the build are stored in
# include/generated/ and include/config/. Update them if .config is newer than
# include/config/auto.conf (which mirrors .config).
#
# This exploits the 'multi-target pattern rule' trick.
# The syncconfig should be executed only once to make all the targets.
# (Note: use the grouped target '&:' when we bump to GNU Make 4.3)
#
# Do not use $(call cmd,...) here. That would suppress prompts from syncconfig,
# so you cannot notice that Kconfig is waiting for the user input.
%/config/auto.conf %/config/auto.conf.cmd %/generated/autoconf.h: $(KCONFIG_CONFIG)
	$(Q)$(kecho) "  SYNC    $@"
	$(Q)$(MAKE) -f $(srctree)/Makefile syncconfig
else # !may-sync-config
# External modules and some install targets need include/generated/autoconf.h
# and include/config/auto.conf but do not care if they are up-to-date.
# Use auto.conf to trigger the test
PHONY += include/config/auto.conf

include/config/auto.conf:
	$(Q)test -e include/generated/autoconf.h -a -e $@ || (		\
	echo >&2;							\
	echo >&2 "  ERROR: Kernel configuration is invalid.";		\
	echo >&2 "         include/generated/autoconf.h or $@ are missing.";\
	echo >&2 "         Run 'make oldconfig && make prepare' on kernel src to fix it.";	\
	echo >&2 ;							\
	/bin/false)

endif # may-sync-config
endif # need-config

KBUILD_CFLAGS	+= -fno-delete-null-pointer-checks
KBUILD_CFLAGS	+= $(call cc-disable-warning,frame-address,)
KBUILD_CFLAGS	+= $(call cc-disable-warning, format-truncation)
KBUILD_CFLAGS	+= $(call cc-disable-warning, format-overflow)
KBUILD_CFLAGS	+= $(call cc-disable-warning, address-of-packed-member)

ifdef CONFIG_CC_OPTIMIZE_FOR_PERFORMANCE
KBUILD_CFLAGS += -O2
else ifdef CONFIG_CC_OPTIMIZE_FOR_PERFORMANCE_O3
KBUILD_CFLAGS += -O3
else ifdef CONFIG_CC_OPTIMIZE_FOR_SIZE
KBUILD_CFLAGS += -Os
endif

# Tell gcc to never replace conditional load with a non-conditional one
ifdef CONFIG_CC_IS_GCC
# gcc-10 renamed --param=allow-store-data-races=0 to
# -fno-allow-store-data-races.
KBUILD_CFLAGS	+= $(call cc-option,--param=allow-store-data-races=0)
KBUILD_CFLAGS	+= $(call cc-option,-fno-allow-store-data-races)
endif

ifdef CONFIG_READABLE_ASM
# Disable optimizations that make assembler listings hard to read.
# reorder blocks reorders the control in the function
# ipa clone creates specialized cloned functions
# partial inlining inlines only parts of functions
KBUILD_CFLAGS += -fno-reorder-blocks -fno-ipa-cp-clone -fno-partial-inlining
endif

ifneq ($(CONFIG_FRAME_WARN),0)
KBUILD_CFLAGS += -Wframe-larger-than=$(CONFIG_FRAME_WARN)
endif

stackp-flags-y                                    := -fno-stack-protector
stackp-flags-$(CONFIG_STACKPROTECTOR)             := -fstack-protector
stackp-flags-$(CONFIG_STACKPROTECTOR_STRONG)      := -fstack-protector-strong

KBUILD_CFLAGS += $(stackp-flags-y)

KBUILD_CFLAGS-$(CONFIG_WERROR) += -Werror
KBUILD_CFLAGS += $(KBUILD_CFLAGS-y) $(CONFIG_CC_IMPLICIT_FALLTHROUGH)

ifdef CONFIG_CC_IS_CLANG
KBUILD_CPPFLAGS += -Qunused-arguments
# The kernel builds with '-std=gnu11' so use of GNU extensions is acceptable.
KBUILD_CFLAGS += -Wno-gnu
else

# gcc inanely warns about local variables called 'main'
KBUILD_CFLAGS += -Wno-main
endif

# These warnings generated too much noise in a regular build.
# Use make W=1 to enable them (see scripts/Makefile.extrawarn)
KBUILD_CFLAGS += $(call cc-disable-warning, unused-but-set-variable)
KBUILD_CFLAGS += $(call cc-disable-warning, unused-const-variable)

ifdef CONFIG_FRAME_POINTER
KBUILD_CFLAGS	+= -fno-omit-frame-pointer -fno-optimize-sibling-calls
else
# Some targets (ARM with Thumb2, for example), can't be built with frame
# pointers.  For those, we don't have FUNCTION_TRACER automatically
# select FRAME_POINTER.  However, FUNCTION_TRACER adds -pg, and this is
# incompatible with -fomit-frame-pointer with current GCC, so we don't use
# -fomit-frame-pointer with FUNCTION_TRACER.
ifndef CONFIG_FUNCTION_TRACER
KBUILD_CFLAGS	+= -fomit-frame-pointer
endif
endif

# Initialize all stack variables with a 0xAA pattern.
ifdef CONFIG_INIT_STACK_ALL_PATTERN
KBUILD_CFLAGS	+= -ftrivial-auto-var-init=pattern
endif

# Initialize all stack variables with a zero value.
ifdef CONFIG_INIT_STACK_ALL_ZERO
KBUILD_CFLAGS	+= -ftrivial-auto-var-init=zero
ifdef CONFIG_CC_IS_CLANG
# https://bugs.llvm.org/show_bug.cgi?id=45497
KBUILD_CFLAGS	+= -enable-trivial-auto-var-init-zero-knowing-it-will-be-removed-from-clang
endif
endif

# While VLAs have been removed, GCC produces unreachable stack probes
# for the randomize_kstack_offset feature. Disable it for all compilers.
KBUILD_CFLAGS	+= $(call cc-option, -fno-stack-clash-protection)

# Clear used registers at func exit (to reduce data lifetime and ROP gadgets).
ifdef CONFIG_ZERO_CALL_USED_REGS
KBUILD_CFLAGS	+= -fzero-call-used-regs=used-gpr
endif

ifdef CONFIG_FUNCTION_TRACER
ifdef CONFIG_FTRACE_MCOUNT_USE_CC
  CC_FLAGS_FTRACE	+= -mrecord-mcount
  ifdef CONFIG_HAVE_NOP_MCOUNT
    ifeq ($(call cc-option-yn, -mnop-mcount),y)
      CC_FLAGS_FTRACE	+= -mnop-mcount
      CC_FLAGS_USING	+= -DCC_USING_NOP_MCOUNT
    endif
  endif
endif
ifdef CONFIG_FTRACE_MCOUNT_USE_OBJTOOL
  CC_FLAGS_USING	+= -DCC_USING_NOP_MCOUNT
endif
ifdef CONFIG_FTRACE_MCOUNT_USE_RECORDMCOUNT
  ifdef CONFIG_HAVE_C_RECORDMCOUNT
    BUILD_C_RECORDMCOUNT := y
    export BUILD_C_RECORDMCOUNT
  endif
endif
ifdef CONFIG_HAVE_FENTRY
  # s390-linux-gnu-gcc did not support -mfentry until gcc-9.
  ifeq ($(call cc-option-yn, -mfentry),y)
    CC_FLAGS_FTRACE	+= -mfentry
    CC_FLAGS_USING	+= -DCC_USING_FENTRY
  endif
endif
export CC_FLAGS_FTRACE
KBUILD_CFLAGS	+= $(CC_FLAGS_FTRACE) $(CC_FLAGS_USING)
KBUILD_AFLAGS	+= $(CC_FLAGS_USING)
endif

# We trigger additional mismatches with less inlining
ifdef CONFIG_DEBUG_SECTION_MISMATCH
KBUILD_CFLAGS += -fno-inline-functions-called-once
endif

ifdef CONFIG_LD_DEAD_CODE_DATA_ELIMINATION
KBUILD_CFLAGS_KERNEL += -ffunction-sections -fdata-sections
LDFLAGS_vmlinux += --gc-sections
endif

ifdef CONFIG_SHADOW_CALL_STACK
CC_FLAGS_SCS	:= -fsanitize=shadow-call-stack
KBUILD_CFLAGS	+= $(CC_FLAGS_SCS)
export CC_FLAGS_SCS
endif

ifdef CONFIG_LTO_CLANG
ifdef CONFIG_LTO_CLANG_THIN
CC_FLAGS_LTO	:= -flto=thin -fsplit-lto-unit
KBUILD_LDFLAGS	+= --thinlto-cache-dir=$(extmod_prefix).thinlto-cache
else
CC_FLAGS_LTO	:= -flto
endif
CC_FLAGS_LTO	+= -fvisibility=hidden

# Limit inlining across translation units to reduce binary size
KBUILD_LDFLAGS += -mllvm -import-instr-limit=5

# Check for frame size exceeding threshold during prolog/epilog insertion
# when using lld < 13.0.0.
ifneq ($(CONFIG_FRAME_WARN),0)
ifeq ($(shell test $(CONFIG_LLD_VERSION) -lt 130000; echo $$?),0)
KBUILD_LDFLAGS	+= -plugin-opt=-warn-stack-size=$(CONFIG_FRAME_WARN)
endif
endif
endif

ifdef CONFIG_LTO
KBUILD_CFLAGS	+= -fno-lto $(CC_FLAGS_LTO)
KBUILD_AFLAGS	+= -fno-lto
export CC_FLAGS_LTO
endif

ifdef CONFIG_CFI_CLANG
CC_FLAGS_CFI	:= -fsanitize=cfi \
		   -fsanitize-cfi-cross-dso \
		   -fno-sanitize-cfi-canonical-jump-tables \
		   -fno-sanitize-trap=cfi \
		   -fno-sanitize-blacklist

ifdef CONFIG_CFI_PERMISSIVE
CC_FLAGS_CFI	+= -fsanitize-recover=cfi
endif

# If LTO flags are filtered out, we must also filter out CFI.
CC_FLAGS_LTO	+= $(CC_FLAGS_CFI)
KBUILD_CFLAGS	+= $(CC_FLAGS_CFI)
export CC_FLAGS_CFI
endif

ifdef CONFIG_DEBUG_FORCE_FUNCTION_ALIGN_64B
KBUILD_CFLAGS += -falign-functions=64
endif

# arch Makefile may override CC so keep this after arch Makefile is included
NOSTDINC_FLAGS += -nostdinc

# warn about C99 declaration after statement
KBUILD_CFLAGS += -Wdeclaration-after-statement

# Variable Length Arrays (VLAs) should not be used anywhere in the kernel
KBUILD_CFLAGS += -Wvla

# disable pointer signed / unsigned warnings in gcc 4.0
KBUILD_CFLAGS += -Wno-pointer-sign

# In order to make sure new function cast mismatches are not introduced
# in the kernel (to avoid tripping CFI checking), the kernel should be
# globally built with -Wcast-function-type.
KBUILD_CFLAGS += $(call cc-option, -Wcast-function-type)

# disable stringop warnings in gcc 8+
KBUILD_CFLAGS += $(call cc-disable-warning, stringop-truncation)

# We'll want to enable this eventually, but it's not going away for 5.7 at least
KBUILD_CFLAGS += $(call cc-disable-warning, stringop-overflow)

# Another good warning that we'll want to enable eventually
KBUILD_CFLAGS += $(call cc-disable-warning, restrict)

# Enabled with W=2, disabled by default as noisy
ifdef CONFIG_CC_IS_GCC
KBUILD_CFLAGS += -Wno-maybe-uninitialized
endif

ifdef CONFIG_CC_IS_GCC
# The allocators already balk at large sizes, so silence the compiler
# warnings for bounds checks involving those possible values. While
# -Wno-alloc-size-larger-than would normally be used here, earlier versions
# of gcc (<9.1) weirdly don't handle the option correctly when _other_
# warnings are produced (?!). Using -Walloc-size-larger-than=SIZE_MAX
# doesn't work (as it is documented to), silently resolving to "0" prior to
# version 9.1 (and producing an error more recently). Numeric values larger
# than PTRDIFF_MAX also don't work prior to version 9.1, which are silently
# ignored, continuing to default to PTRDIFF_MAX. So, left with no other
# choice, we must perform a versioned check to disable this warning.
# https://lore.kernel.org/lkml/20210824115859.187f272f@canb.auug.org.au
KBUILD_CFLAGS += $(call cc-ifversion, -ge, 0901, -Wno-alloc-size-larger-than)
endif

# disable invalid "can't wrap" optimizations for signed / pointers
KBUILD_CFLAGS	+= -fno-strict-overflow

# Make sure -fstack-check isn't enabled (like gentoo apparently did)
KBUILD_CFLAGS  += -fno-stack-check

# conserve stack if available
ifdef CONFIG_CC_IS_GCC
KBUILD_CFLAGS   += -fconserve-stack
endif

# Prohibit date/time macros, which would make the build non-deterministic
KBUILD_CFLAGS   += -Werror=date-time

# enforce correct pointer usage
KBUILD_CFLAGS   += $(call cc-option,-Werror=incompatible-pointer-types)

# Require designated initializers for all marked structures
KBUILD_CFLAGS   += $(call cc-option,-Werror=designated-init)

# change __FILE__ to the relative path from the srctree
KBUILD_CPPFLAGS += $(call cc-option,-fmacro-prefix-map=$(srctree)/=)

# include additional Makefiles when needed
include-y			:= scripts/Makefile.extrawarn
include-$(CONFIG_DEBUG_INFO)	+= scripts/Makefile.debug
include-$(CONFIG_KASAN)		+= scripts/Makefile.kasan
include-$(CONFIG_KCSAN)		+= scripts/Makefile.kcsan
include-$(CONFIG_UBSAN)		+= scripts/Makefile.ubsan
include-$(CONFIG_KCOV)		+= scripts/Makefile.kcov
include-$(CONFIG_RANDSTRUCT)	+= scripts/Makefile.randstruct
include-$(CONFIG_GCC_PLUGINS)	+= scripts/Makefile.gcc-plugins

include $(addprefix $(srctree)/, $(include-y))

# scripts/Makefile.gcc-plugins is intentionally included last.
# Do not add $(call cc-option,...) below this line. When you build the kernel
# from the clean source tree, the GCC plugins do not exist at this point.

# Add user supplied CPPFLAGS, AFLAGS and CFLAGS as the last assignments
KBUILD_CPPFLAGS += $(KCPPFLAGS)
KBUILD_AFLAGS   += $(KAFLAGS)
KBUILD_CFLAGS   += $(KCFLAGS)

KBUILD_LDFLAGS_MODULE += --build-id=sha1
LDFLAGS_vmlinux += --build-id=sha1

ifeq ($(CONFIG_STRIP_ASM_SYMS),y)
LDFLAGS_vmlinux	+= $(call ld-option, -X,)
endif

ifeq ($(CONFIG_RELR),y)
LDFLAGS_vmlinux	+= --pack-dyn-relocs=relr --use-android-relr-tags
endif

# We never want expected sections to be placed heuristically by the
# linker. All sections should be explicitly named in the linker script.
ifdef CONFIG_LD_ORPHAN_WARN
LDFLAGS_vmlinux += --orphan-handling=warn
endif

# Align the bit size of userspace programs with the kernel
KBUILD_USERCFLAGS  += $(filter -m32 -m64 --target=%, $(KBUILD_CFLAGS))
KBUILD_USERLDFLAGS += $(filter -m32 -m64 --target=%, $(KBUILD_CFLAGS))

# make the checker run with the right architecture
CHECKFLAGS += --arch=$(ARCH)

# insure the checker run with the right endianness
CHECKFLAGS += $(if $(CONFIG_CPU_BIG_ENDIAN),-mbig-endian,-mlittle-endian)

# the checker needs the correct machine size
CHECKFLAGS += $(if $(CONFIG_64BIT),-m64,-m32)

# Default kernel image to build when no specific target is given.
# KBUILD_IMAGE may be overruled on the command line or
# set in the environment
# Also any assignments in arch/$(ARCH)/Makefile take precedence over
# this default value
export KBUILD_IMAGE ?= vmlinux

#
# INSTALL_PATH specifies where to place the updated kernel and system map
# images. Default is /boot, but you can set it to other values
export	INSTALL_PATH ?= /boot

#
# INSTALL_DTBS_PATH specifies a prefix for relocations required by build roots.
# Like INSTALL_MOD_PATH, it isn't defined in the Makefile, but can be passed as
# an argument if needed. Otherwise it defaults to the kernel install path
#
export INSTALL_DTBS_PATH ?= $(INSTALL_PATH)/dtbs/$(KERNELRELEASE)

#
# INSTALL_MOD_PATH specifies a prefix to MODLIB for module directory
# relocations required by build roots.  This is not defined in the
# makefile but the argument can be passed to make if needed.
#

MODLIB	= $(INSTALL_MOD_PATH)/lib/modules/$(KERNELRELEASE)
export MODLIB

PHONY += prepare0

export extmod_prefix = $(if $(KBUILD_EXTMOD),$(KBUILD_EXTMOD)/)
export MODORDER := $(extmod_prefix)modules.order
export MODULES_NSDEPS := $(extmod_prefix)modules.nsdeps

ifeq ($(KBUILD_EXTMOD),)
core-y			+= kernel/ mm/ fs/ security/ crypto/ block/

vmlinux-dirs	:= $(patsubst %/,%,$(filter %/, \
		     $(core-y) $(core-m) $(drivers-y) $(drivers-m) \
		     $(libs-y) $(libs-m)))

vmlinux-alldirs	:= $(sort $(vmlinux-dirs) Documentation \
		     $(patsubst %/,%,$(filter %/, $(core-) \
			$(drivers-) $(libs-))))

subdir-modorder := $(addsuffix modules.order,$(filter %/, \
			$(core-y) $(core-m) $(libs-y) $(libs-m) \
			$(drivers-y) $(drivers-m)))

build-dirs	:= $(vmlinux-dirs)
clean-dirs	:= $(vmlinux-alldirs)

# Externally visible symbols (used by link-vmlinux.sh)
KBUILD_VMLINUX_OBJS := $(head-y) $(patsubst %/,%/built-in.a, $(core-y))
KBUILD_VMLINUX_OBJS += $(addsuffix built-in.a, $(filter %/, $(libs-y)))
ifdef CONFIG_MODULES
KBUILD_VMLINUX_OBJS += $(patsubst %/, %/lib.a, $(filter %/, $(libs-y)))
KBUILD_VMLINUX_LIBS := $(filter-out %/, $(libs-y))
else
KBUILD_VMLINUX_LIBS := $(patsubst %/,%/lib.a, $(libs-y))
endif
KBUILD_VMLINUX_OBJS += $(patsubst %/,%/built-in.a, $(drivers-y))

export KBUILD_VMLINUX_OBJS KBUILD_VMLINUX_LIBS
export KBUILD_LDS          := arch/$(SRCARCH)/kernel/vmlinux.lds
# used by scripts/Makefile.package
export KBUILD_ALLDIRS := $(sort $(filter-out arch/%,$(vmlinux-alldirs)) LICENSES arch include scripts tools)

vmlinux-deps := $(KBUILD_LDS) $(KBUILD_VMLINUX_OBJS) $(KBUILD_VMLINUX_LIBS)

# Recurse until adjust_autoksyms.sh is satisfied
PHONY += autoksyms_recursive
ifdef CONFIG_TRIM_UNUSED_KSYMS
# For the kernel to actually contain only the needed exported symbols,
# we have to build modules as well to determine what those symbols are.
# (this can be evaluated only once include/config/auto.conf has been included)
KBUILD_MODULES := 1

autoksyms_recursive: descend modules.order
	$(Q)$(CONFIG_SHELL) $(srctree)/scripts/adjust_autoksyms.sh \
	  "$(MAKE) -f $(srctree)/Makefile vmlinux"
endif

autoksyms_h := $(if $(CONFIG_TRIM_UNUSED_KSYMS), include/generated/autoksyms.h)

quiet_cmd_autoksyms_h = GEN     $@
      cmd_autoksyms_h = mkdir -p $(dir $@); \
			$(CONFIG_SHELL) $(srctree)/scripts/gen_autoksyms.sh $@

$(autoksyms_h):
	$(call cmd,autoksyms_h)

ARCH_POSTLINK := $(wildcard $(srctree)/arch/$(SRCARCH)/Makefile.postlink)

# Final link of vmlinux with optional arch pass after final link
cmd_link-vmlinux =                                                 \
	$(CONFIG_SHELL) $< "$(LD)" "$(KBUILD_LDFLAGS)" "$(LDFLAGS_vmlinux)";    \
	$(if $(ARCH_POSTLINK), $(MAKE) -f $(ARCH_POSTLINK) $@, true)

vmlinux: scripts/link-vmlinux.sh autoksyms_recursive $(vmlinux-deps) FORCE
	+$(call if_changed_dep,link-vmlinux)

targets := vmlinux

# The actual objects are generated when descending,
# make sure no implicit rule kicks in
$(sort $(vmlinux-deps) $(subdir-modorder)): descend ;

filechk_kernel.release = \
	echo "$(KERNELVERSION)$$($(CONFIG_SHELL) $(srctree)/scripts/setlocalversion $(srctree))"

# Store (new) KERNELRELEASE string in include/config/kernel.release
include/config/kernel.release: FORCE
	$(call filechk,kernel.release)

# Additional helpers built in scripts/
# Carefully list dependencies so we do not try to build scripts twice
# in parallel
PHONY += scripts
scripts: scripts_basic scripts_dtc
	$(Q)$(MAKE) $(build)=$(@)

# Things we need to do before we recursively start building the kernel
# or the modules are listed in "prepare".
# A multi level approach is used. prepareN is processed before prepareN-1.
# archprepare is used in arch Makefiles and when processed asm symlink,
# version.h and scripts_basic is processed / created.

PHONY += prepare archprepare

archprepare: outputmakefile archheaders archscripts scripts include/config/kernel.release \
	asm-generic $(version_h) $(autoksyms_h) include/generated/utsrelease.h \
	include/generated/autoconf.h remove-stale-files

prepare0: archprepare
	$(Q)$(MAKE) $(build)=scripts/mod
	$(Q)$(MAKE) $(build)=.

# All the preparing..
prepare: prepare0

PHONY += remove-stale-files
remove-stale-files:
	$(Q)$(srctree)/scripts/remove-stale-files

# Support for using generic headers in asm-generic
asm-generic := -f $(srctree)/scripts/Makefile.asm-generic obj

PHONY += asm-generic uapi-asm-generic
asm-generic: uapi-asm-generic
	$(Q)$(MAKE) $(asm-generic)=arch/$(SRCARCH)/include/generated/asm \
	generic=include/asm-generic
uapi-asm-generic:
	$(Q)$(MAKE) $(asm-generic)=arch/$(SRCARCH)/include/generated/uapi/asm \
	generic=include/uapi/asm-generic

# Generate some files
# ---------------------------------------------------------------------------

# KERNELRELEASE can change from a few different places, meaning version.h
# needs to be updated, so this check is forced on all builds

uts_len := 64
define filechk_utsrelease.h
	if [ `echo -n "$(KERNELRELEASE)" | wc -c ` -gt $(uts_len) ]; then \
	  echo '"$(KERNELRELEASE)" exceeds $(uts_len) characters' >&2;    \
	  exit 1;                                                         \
	fi;                                                               \
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

$(version_h): PATCHLEVEL := $(or $(PATCHLEVEL), 0)
$(version_h): SUBLEVEL := $(or $(SUBLEVEL), 0)
$(version_h): FORCE
	$(call filechk,version.h)

include/generated/utsrelease.h: include/config/kernel.release FORCE
	$(call filechk,utsrelease.h)

PHONY += headerdep
headerdep:
	$(Q)find $(srctree)/include/ -name '*.h' | xargs --max-args 1 \
	$(srctree)/scripts/headerdep.pl -I$(srctree)/include

# ---------------------------------------------------------------------------
# Kernel headers

#Default location for installed headers
export INSTALL_HDR_PATH = $(objtree)/usr

quiet_cmd_headers_install = INSTALL $(INSTALL_HDR_PATH)/include
      cmd_headers_install = \
	mkdir -p $(INSTALL_HDR_PATH); \
	rsync -mrl --include='*/' --include='*\.h' --exclude='*' \
	usr/include $(INSTALL_HDR_PATH)

PHONY += headers_install
headers_install: headers
	$(call cmd,headers_install)

PHONY += archheaders archscripts

hdr-inst := -f $(srctree)/scripts/Makefile.headersinst obj

PHONY += headers
headers: $(version_h) scripts_unifdef uapi-asm-generic archheaders archscripts
	$(if $(wildcard $(srctree)/arch/$(SRCARCH)/include/uapi/asm/Kbuild),, \
	  $(error Headers not exportable for the $(SRCARCH) architecture))
	$(Q)$(MAKE) $(hdr-inst)=include/uapi
	$(Q)$(MAKE) $(hdr-inst)=arch/$(SRCARCH)/include/uapi

ifdef CONFIG_HEADERS_INSTALL
prepare: headers
endif

PHONY += scripts_unifdef
scripts_unifdef: scripts_basic
	$(Q)$(MAKE) $(build)=scripts scripts/unifdef

# ---------------------------------------------------------------------------
# Install

# Many distributions have the custom install script, /sbin/installkernel.
# If DKMS is installed, 'make install' will eventually recurse back
# to this Makefile to build and install external modules.
# Cancel sub_make_done so that options such as M=, V=, etc. are parsed.

quiet_cmd_install = INSTALL $(INSTALL_PATH)
      cmd_install = unset sub_make_done; $(srctree)/scripts/install.sh

# ---------------------------------------------------------------------------
# Tools

ifdef CONFIG_OBJTOOL
prepare: tools/objtool
endif

ifdef CONFIG_BPF
ifdef CONFIG_DEBUG_INFO_BTF
prepare: tools/bpf/resolve_btfids
endif
endif

PHONY += resolve_btfids_clean

resolve_btfids_O = $(abspath $(objtree))/tools/bpf/resolve_btfids

# tools/bpf/resolve_btfids directory might not exist
# in output directory, skip its clean in that case
resolve_btfids_clean:
ifneq ($(wildcard $(resolve_btfids_O)),)
	$(Q)$(MAKE) -sC $(srctree)/tools/bpf/resolve_btfids O=$(resolve_btfids_O) clean
endif

# Clear a bunch of variables before executing the submake
ifeq ($(quiet),silent_)
tools_silent=s
endif

tools/: FORCE
	$(Q)mkdir -p $(objtree)/tools
	$(Q)$(MAKE) LDFLAGS= MAKEFLAGS="$(tools_silent) $(filter --j% -j,$(MAKEFLAGS))" O=$(abspath $(objtree)) subdir=tools -C $(srctree)/tools/

tools/%: FORCE
	$(Q)mkdir -p $(objtree)/tools
	$(Q)$(MAKE) LDFLAGS= MAKEFLAGS="$(tools_silent) $(filter --j% -j,$(MAKEFLAGS))" O=$(abspath $(objtree)) subdir=tools -C $(srctree)/tools/ $*

# ---------------------------------------------------------------------------
# Kernel selftest

PHONY += kselftest
kselftest:
	$(Q)$(MAKE) -C $(srctree)/tools/testing/selftests run_tests

kselftest-%: FORCE
	$(Q)$(MAKE) -C $(srctree)/tools/testing/selftests $*

PHONY += kselftest-merge
kselftest-merge:
	$(if $(wildcard $(objtree)/.config),, $(error No .config exists, config your kernel first!))
	$(Q)find $(srctree)/tools/testing/selftests -name config | \
		xargs $(srctree)/scripts/kconfig/merge_config.sh -m $(objtree)/.config
	$(Q)$(MAKE) -f $(srctree)/Makefile olddefconfig

# ---------------------------------------------------------------------------
# Devicetree files

ifneq ($(wildcard $(srctree)/arch/$(SRCARCH)/boot/dts/),)
dtstree := arch/$(SRCARCH)/boot/dts
endif

ifneq ($(dtstree),)

%.dtb: include/config/kernel.release scripts_dtc
	$(Q)$(MAKE) $(build)=$(dtstree) $(dtstree)/$@

%.dtbo: include/config/kernel.release scripts_dtc
	$(Q)$(MAKE) $(build)=$(dtstree) $(dtstree)/$@

PHONY += dtbs dtbs_install dtbs_check
dtbs: include/config/kernel.release scripts_dtc
	$(Q)$(MAKE) $(build)=$(dtstree)

ifneq ($(filter dtbs_check, $(MAKECMDGOALS)),)
export CHECK_DTBS=y
dtbs: dt_binding_check
endif

dtbs_check: dtbs

dtbs_install:
	$(Q)$(MAKE) $(dtbinst)=$(dtstree) dst=$(INSTALL_DTBS_PATH)

ifdef CONFIG_OF_EARLY_FLATTREE
all: dtbs
endif

endif

PHONY += scripts_dtc
scripts_dtc: scripts_basic
	$(Q)$(MAKE) $(build)=scripts/dtc

ifneq ($(filter dt_binding_check, $(MAKECMDGOALS)),)
export CHECK_DT_BINDING=y
endif

PHONY += dt_binding_check
dt_binding_check: scripts_dtc
	$(Q)$(MAKE) $(build)=Documentation/devicetree/bindings

# ---------------------------------------------------------------------------
# Modules

ifdef CONFIG_MODULES

# By default, build modules as well

all: modules

# When we're building modules with modversions, we need to consider
# the built-in objects during the descend as well, in order to
# make sure the checksums are up to date before we record them.
ifdef CONFIG_MODVERSIONS
  KBUILD_BUILTIN := 1
endif

# Build modules
#
# A module can be listed more than once in obj-m resulting in
# duplicate lines in modules.order files.  Those are removed
# using awk while concatenating to the final file.

PHONY += modules
modules: $(if $(KBUILD_BUILTIN),vmlinux) modules_check modules_prepare

cmd_modules_order = $(AWK) '!x[$$0]++' $(real-prereqs) > $@

modules.order: $(subdir-modorder) FORCE
	$(call if_changed,modules_order)

targets += modules.order

# Target to prepare building external modules
PHONY += modules_prepare
modules_prepare: prepare
	$(Q)$(MAKE) $(build)=scripts scripts/module.lds

export modules_sign_only :=

ifeq ($(CONFIG_MODULE_SIG),y)
PHONY += modules_sign
modules_sign: modules_install
	@:

# modules_sign is a subset of modules_install.
# 'make modules_install modules_sign' is equivalent to 'make modules_install'.
ifeq ($(filter modules_install,$(MAKECMDGOALS)),)
modules_sign_only := y
endif
endif

modinst_pre :=
ifneq ($(filter modules_install,$(MAKECMDGOALS)),)
modinst_pre := __modinst_pre
endif

modules_install: $(modinst_pre)
PHONY += __modinst_pre
__modinst_pre:
	@rm -rf $(MODLIB)/kernel
	@rm -f $(MODLIB)/source
	@mkdir -p $(MODLIB)/kernel
	@ln -s $(abspath $(srctree)) $(MODLIB)/source
	@if [ ! $(objtree) -ef  $(MODLIB)/build ]; then \
		rm -f $(MODLIB)/build ; \
		ln -s $(CURDIR) $(MODLIB)/build ; \
	fi
	@sed 's:^:kernel/:' modules.order > $(MODLIB)/modules.order
	@cp -f modules.builtin $(MODLIB)/
	@cp -f $(objtree)/modules.builtin.modinfo $(MODLIB)/

endif # CONFIG_MODULES

###
# Cleaning is done on three levels.
# make clean     Delete most generated files
#                Leave enough to build external modules
# make mrproper  Delete the current configuration, and all generated files
# make distclean Remove editor backup files, patch leftover files and the like

# Directories & files removed with 'make clean'
CLEAN_FILES += include/ksym vmlinux.symvers modules-only.symvers \
	       modules.builtin modules.builtin.modinfo modules.nsdeps \
	       compile_commands.json .thinlto-cache

# Directories & files removed with 'make mrproper'
MRPROPER_FILES += include/config include/generated          \
		  arch/$(SRCARCH)/include/generated .objdiff \
		  debian snap tar-install \
		  .config .config.old .version \
		  Module.symvers \
		  certs/signing_key.pem \
		  certs/x509.genkey \
		  vmlinux-gdb.py \
		  *.spec

# clean - Delete most, but leave enough to build external modules
#
clean: rm-files := $(CLEAN_FILES)

PHONY += archclean vmlinuxclean

vmlinuxclean:
	$(Q)$(CONFIG_SHELL) $(srctree)/scripts/link-vmlinux.sh clean
	$(Q)$(if $(ARCH_POSTLINK), $(MAKE) -f $(ARCH_POSTLINK) clean)

clean: archclean vmlinuxclean resolve_btfids_clean

# mrproper - Delete all generated files, including .config
#
mrproper: rm-files := $(wildcard $(MRPROPER_FILES))
mrproper-dirs      := $(addprefix _mrproper_,scripts)

PHONY += $(mrproper-dirs) mrproper
$(mrproper-dirs):
	$(Q)$(MAKE) $(clean)=$(patsubst _mrproper_%,%,$@)

mrproper: clean $(mrproper-dirs)
	$(call cmd,rmfiles)

# distclean
#
PHONY += distclean


# Packaging of the kernel to various formats
# ---------------------------------------------------------------------------

%src-pkg: FORCE
	$(Q)$(MAKE) -f $(srctree)/scripts/Makefile.package $@
%pkg: include/config/kernel.release FORCE
	$(Q)$(MAKE) -f $(srctree)/scripts/Makefile.package $@

# Brief documentation of the typical targets used
# ---------------------------------------------------------------------------

boards := $(wildcard $(srctree)/arch/$(SRCARCH)/configs/*_defconfig)
boards := $(sort $(notdir $(boards)))
board-dirs := $(dir $(wildcard $(srctree)/arch/$(SRCARCH)/configs/*/*_defconfig))
board-dirs := $(sort $(notdir $(board-dirs:/=)))

else # KBUILD_EXTMOD

###
# External module support.
# When building external modules the kernel used as basis is considered
# read-only, and no consistency checks are made and the make
# system is not used on the basis kernel. If updates are required
# in the basis kernel ordinary make commands (without M=...) must be used.

# We are always building only modules.
KBUILD_BUILTIN :=
KBUILD_MODULES := 1

build-dirs := $(KBUILD_EXTMOD)
$(MODORDER): descend
	@:

compile_commands.json: $(extmod_prefix)compile_commands.json
PHONY += compile_commands.json

clean-dirs := $(KBUILD_EXTMOD)
clean: rm-files := $(KBUILD_EXTMOD)/Module.symvers $(KBUILD_EXTMOD)/modules.nsdeps \
	$(KBUILD_EXTMOD)/compile_commands.json $(KBUILD_EXTMOD)/.thinlto-cache

PHONY += prepare
# now expand this into a simple variable to reduce the cost of shell evaluations
prepare: CC_VERSION_TEXT := $(CC_VERSION_TEXT)
prepare:
	@if [ "$(CC_VERSION_TEXT)" != "$(CONFIG_CC_VERSION_TEXT)" ]; then \
		echo >&2 "warning: the compiler differs from the one used to build the kernel"; \
		echo >&2 "  The kernel was built by: $(CONFIG_CC_VERSION_TEXT)"; \
		echo >&2 "  You are using:           $(CC_VERSION_TEXT)"; \
	fi
endif # KBUILD_EXTMOD

ifdef single-build

# .ko is special because modpost is needed
single-ko := $(sort $(filter %.ko, $(MAKECMDGOALS)))
single-no-ko := $(filter-out $(single-ko), $(MAKECMDGOALS)) \
		$(foreach x, o mod, $(patsubst %.ko, %.$x, $(single-ko)))

$(single-ko): single_modpost
	@:
$(single-no-ko): descend
	@:

ifeq ($(KBUILD_EXTMOD),)
# For the single build of in-tree modules, use a temporary file to avoid
# the situation of modules_install installing an invalid modules.order.
MODORDER := .modules.tmp
endif

PHONY += single_modpost
single_modpost: $(single-no-ko) modules_prepare
	$(Q){ $(foreach m, $(single-ko), echo $(extmod_prefix)$m;) } > $(MODORDER)
	$(Q)$(MAKE) -f $(srctree)/scripts/Makefile.modpost

KBUILD_MODULES := 1

export KBUILD_SINGLE_TARGETS := $(addprefix $(extmod_prefix), $(single-no-ko))

# trim unrelated directories
build-dirs := $(foreach d, $(build-dirs), \
			$(if $(filter $(d)/%, $(KBUILD_SINGLE_TARGETS)), $(d)))

endif

# Handle descending into subdirectories listed in $(build-dirs)
# Preset locale variables to speed up the build process. Limit locale
# tweaks to this spot to avoid wrong language settings when running
# make menuconfig etc.
# Error messages still appears in the original language
PHONY += descend $(build-dirs)
descend: $(build-dirs)
$(build-dirs): prepare
	$(Q)$(MAKE) $(build)=$@ \
	single-build=$(if $(filter-out $@/, $(filter $@/%, $(KBUILD_SINGLE_TARGETS))),1) \
	need-builtin=1 need-modorder=1

clean-dirs := $(addprefix _clean_, $(clean-dirs))
PHONY += $(clean-dirs) clean
$(clean-dirs):
	$(Q)$(MAKE) $(clean)=$(patsubst _clean_%,%,$@)


quiet_cmd_gen_compile_commands = GEN     $@
      cmd_gen_compile_commands = $(PYTHON3) $< -a $(AR) -o $@ $(filter-out $<, $(real-prereqs))

$(extmod_prefix)compile_commands.json: scripts/clang-tools/gen_compile_commands.py \
	$(if $(KBUILD_EXTMOD),,$(KBUILD_VMLINUX_OBJS) $(KBUILD_VMLINUX_LIBS)) \
	$(if $(CONFIG_MODULES), $(MODORDER)) FORCE
	$(call if_changed,gen_compile_commands)

targets += $(extmod_prefix)compile_commands.json

ifdef CONFIG_CC_IS_CLANG
quiet_cmd_clang_tools = CHECK   $<
      cmd_clang_tools = $(PYTHON3) $(srctree)/scripts/clang-tools/run-clang-tools.py $@ $<

clang-tidy clang-analyzer: $(extmod_prefix)compile_commands.json
	$(call cmd,clang_tools)
else
clang-tidy clang-analyzer:
	@echo "$@ requires CC=clang" >&2
	@false
endif

ifeq ($(ARCH), um)
CHECKSTACK_ARCH := $(SUBARCH)
else
CHECKSTACK_ARCH := $(ARCH)
endif
checkstack:
	$(OBJDUMP) -d vmlinux $$(find . -name '*.ko') | \
	$(PERL) $(srctree)/scripts/checkstack.pl $(CHECKSTACK_ARCH)

kernelrelease:
	@echo "$(KERNELVERSION)$$($(CONFIG_SHELL) $(srctree)/scripts/setlocalversion $(srctree))"

kernelversion:
	@echo $(KERNELVERSION)

image_name:
	@echo $(KBUILD_IMAGE)

quiet_cmd_rmfiles = $(if $(wildcard $(rm-files)),CLEAN   $(wildcard $(rm-files)))
      cmd_rmfiles = rm -rf $(rm-files)

# read saved command lines for existing targets
existing-targets := $(wildcard $(sort $(targets)))

-include $(foreach f,$(existing-targets),$(dir $(f)).$(notdir $(f)).cmd)

endif # config-build
endif # mixed-build
endif # need-sub-make

PHONY += FORCE
FORCE:

# Declare the contents of the PHONY variable as phony.  We keep that
# information in a variable so we can use it in if_changed and friends.
.PHONY: $(PHONY)
