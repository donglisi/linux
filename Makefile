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





LINUXINCLUDE = \
		-nostdinc \
		-I $(srctree)/include \
		-I $(srctree)/include/uapi \
		-I $(srctree)/arch/x86/include \
		-I $(srctree)/arch/x86/include/uapi \
		-I $(srctree)/$(dir $@) \
		-I $(objtree)/include \
		-I $(objtree)/arch/x86/include/generated \
		-I $(objtree)/arch/x86/include/generated/uapi \
		-I $(objtree)/include/generated/uapi \
		-I $(objtree)/$(dir $@) \
		-include $(srctree)/scripts/config.h \
		-include $(srctree)/include/linux/kconfig.h \
		-include $(srctree)/include/linux/compiler_types.h \
		-include $(srctree)/include/linux/compiler-version.h \

basetarget = $(basename $(notdir $@))
basetarget_fix_name = $(subst -,_,$(basetarget))
c_flags        = $(LINUXINCLUDE) $(KBUILD_CFLAGS) $(CFLAGS_$(basename $@).o) \
		-DKBUILD_MODFILE='"$(basename $@)"' \
		-DKBUILD_BASENAME='"$(basetarget_fix_name)"' \
		-DKBUILD_MODNAME='"$(basetarget_fix_name)"' \
		-D__KBUILD_MODNAME=kmod_$(basetarget_fix_name)

%.o: %.c
	@echo "  CC     " $@
	$(Q) $(CC) $(c_flags) -c -o $@ $<

block := $(addprefix block/, bdev.o fops.o bio.o elevator.o blk-core.o blk-sysfs.o blk-flush.o blk-settings.o blk-ioc.o blk-map.o blk-merge.o blk-timeout.o blk-lib.o blk-mq.o blk-mq-tag.o blk-stat.o blk-mq-sysfs.o blk-mq-cpumap.o blk-mq-sched.o ioctl.o genhd.o ioprio.o badblocks.o partitions/core.o blk-rq-qos.o disk-events.o blk-ia-ranges.o blk-mq-pci.o blk-mq-virtio.o)

drivers := block/virtio_blk.o net/loopback.o clocksource/i8253.o
drivers += $(addprefix virtio/, virtio.o virtio_ring.o virtio_pci_modern_dev.o virtio_pci_modern.o virtio_pci_common.o)
drivers += $(addprefix tty/, tty_io.o n_tty.o tty_ioctl.o tty_ldisc.o tty_buffer.o tty_port.o tty_mutex.o  tty_ldsem.o tty_baudrate.o tty_jobctrl.o n_null.o pty.o hvc/hvc_console.o)
drivers += $(addprefix rtc/, lib.o rtc-mc146818-lib.o)
drivers += $(addprefix char/, mem.o random.o misc.o virtio_console.o)
drivers += $(addprefix pci/, access.o bus.o probe.o host-bridge.o remove.o pci.o pci-driver.o search.o pci-sysfs.o \
          rom.o setup-res.o irq.o vpd.o setup-bus.o vc.o mmap.o setup-irq.o proc.o $(addprefix msi/, pcidev_msi.o msi.o irqdomain.o))
drivers += $(addprefix base/, component.o core.o bus.o dd.o syscore.o driver.o class.o platform.o cpu.o firmware.o \
		init.o map.o devres.o attribute_container.o transport_class.o topology.o container.o property.o \
		cacheinfo.o swnode.o devtmpfs.o $(addprefix firmware_loader/, main.o builtin/main.o))
drivers := $(addprefix drivers/, $(drivers))

net := $(addprefix net/, devres.o socket.o ipv6/addrconf_core.o ethernet/eth.o \
	$(addprefix ethtool/, ioctl.o common.o) \
	$(addprefix sched/, sch_generic.o sch_mq.o) \
	$(addprefix unix/, af_unix.o garbage.o scm.o) \
	$(addprefix netlink/, af_netlink.o genetlink.o policy.o) \
	$(addprefix core/, sock.o request_sock.o skbuff.o datagram.o stream.o scm.o gen_stats.o gen_estimator.o net_namespace.o secure_seq.o flow_dissector.o dev.o dev_addr_lists.o dst.o netevent.o neighbour.o rtnetlink.o utils.o link_watch.o filter.o sock_diag.o dev_ioctl.o tso.o sock_reuseport.o fib_notifier.o xdp.o flow_offload.o gro.o net-sysfs.o net-procfs.o))

core-y := init/ arch/x86/ kernel/ mm/ fs/ security/
libs-y := arch/x86/lib/ lib/

bzImage: vmlinux FORCE
	$(Q) $(MAKE) -f $(srctree)/scripts/Makefile.build obj=arch/x86/boot arch/x86/boot/bzImage

vmlinux-dirs	:= $(patsubst %/, %, $(filter %/, $(core-y) $(libs-y)))

KBUILD_VMLINUX_OBJS := $(patsubst %/, %/built-in.a, $(core-y)) $(block) $(net) $(drivers)
KBUILD_VMLINUX_OBJS += $(addsuffix built-in.a, $(filter %/, $(libs-y)))
export KBUILD_VMLINUX_OBJS

export KBUILD_VMLINUX_LIBS := $(patsubst %/, %/lib.a, $(libs-y))

export KBUILD_LDS := arch/x86/kernel/vmlinux.lds

vmlinux-deps := $(KBUILD_LDS) $(KBUILD_VMLINUX_OBJS) $(KBUILD_VMLINUX_LIBS)
$(vmlinux-deps): $(vmlinux-dirs)

vmlinux: scripts/link-vmlinux.sh $(vmlinux-deps) FORCE
	$(Q) $(CONFIG_SHELL) $< "$(LD)"

prepare0:
	@ mkdir -p $(abs_objtree)/include/generated/uapi/linux/ \
		$(abs_objtree)/scripts \
		$(abs_objtree)/lib \
		$(abs_objtree)/arch/x86/boot/compressed \
		$(abs_objtree)/arch/x86/entry/vdso \
		$(abs_objtree)/arch/x86/tools \
		$(abs_objtree)/arch/x86/boot/tools \
		$(abs_objtree)/block/partitions \
		$(abs_objtree)/drivers/base/firmware_loader/builtin \
		$(abs_objtree)/drivers/base/power \
		$(abs_objtree)/drivers/pci/pcie \
		$(abs_objtree)/drivers/pci/msi \
		$(abs_objtree)/drivers/clocksource \
		$(abs_objtree)/drivers/virtio \
		$(abs_objtree)/drivers/char \
		$(abs_objtree)/drivers/net \
		$(abs_objtree)/drivers/rtc \
		$(abs_objtree)/drivers/block \
		$(abs_objtree)/drivers/tty/hvc \
		$(abs_objtree)/drivers/platform/x86 \
		$(abs_objtree)/net/ipv6 \
		$(abs_objtree)/net/ethernet \
		$(abs_objtree)/net/ethtool \
		$(abs_objtree)/net/sched \
		$(abs_objtree)/net/unix \
		$(abs_objtree)/net/netlink \
		$(abs_objtree)/net/core
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
