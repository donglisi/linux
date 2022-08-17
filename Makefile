MAKEFLAGS := -rR --no-print-directory
export Q = @

abs_objtree := build
abs_srctree := /home/d/linux

srctree := $(abs_srctree)
objtree	:= $(abs_objtree)
export srctree objtree

export CONFIG_SHELL := sh

all: build/arch/x86/boot/bzImage

export KBUILD_CFLAGS := -D__KERNEL__ -Wall -Wundef -fshort-wchar -std=gnu11 -O2 -Wimplicit-fallthrough=5
KBUILD_CFLAGS += -mno-sse -mno-mmx -mno-sse2 -mno-3dnow -mno-avx -mno-80387 -mno-fp-ret-in-387 -mno-red-zone -mno-red-zone
KBUILD_CFLAGS += -falign-jumps=1 -falign-loops=1 -fshort-wchar -fconserve-stack
KBUILD_CFLAGS += -mskip-rax-setup -mcmodel=kernel
KBUILD_CFLAGS += -fno-asynchronous-unwind-tables -fno-delete-null-pointer-checks -fno-stack-protector -fno-PIE \
		-fno-allow-store-data-races -fno-strict-overflow -fno-stack-check -fno-stack-check -fno-strict-aliasing -fno-common 
KBUILD_CFLAGS += -Wno-frame-address -Wno-format-truncation -Wno-format-overflow -Wno-address-of-packed-member -Wno-format-security \
		-Wno-main -Wno-declaration-after-statement -Wno-vla -Wno-pointer-sign -Wno-cast-function-type \
		-Wno-unused-const-variable -Wno-unused-but-set-variable -Wno-stringop-truncation -Wno-stringop-overflow \
		-Wno-restrict -Wno-maybe-uninitialized -Wno-error=date-time -Wno-maybe-uninitialized -Wno-sign-compare -Wno-maybe-uninitialized -Wno-trigraphs
KBUILD_CFLAGS += -Werror=incompatible-pointer-types -Werror=designated-init -Werror=return-type -Werror=implicit-function-declaration -Werror=implicit-int -Werror=strict-prototypes

export CPP	= $(CC) -E
export CC	= gcc
export LD	= ld
export AR	= ar
export NM	= nm
OBJCOPY	= objcopy
REALMODE_CFLAGS := -m16 -g -Os -DDISABLE_BRANCH_PROFILING -D__DISABLE_EXPORTS -Wall -Wstrict-prototypes -march=i386 -mregparm=3 -fno-strict-aliasing -fomit-frame-pointer -fno-pic -mno-mmx -mno-sse -fcf-protection=none -ffreestanding -fno-stack-protector -Wno-address-of-packed-member  -D_SETUP

export LINUXINCLUDE = \
		-nostdinc \
		-I $(srctree)/include \
		-I $(srctree)/include/uapi \
		-I $(srctree)/arch/x86/include \
		-I $(srctree)/arch/x86/include/uapi \
		-I $(srctree)/$(subst $(objtree)/,,$(dir $@)) \
		-I $(objtree)/include \
		-I $(objtree)/arch/x86/include/generated \
		-I $(objtree)/arch/x86/include/generated/uapi \
		-I $(objtree)/include/generated/uapi \
		-I $(dir $@) \
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

$(abs_objtree)/%.o: %.c
	@echo "  CC     " $@
	$(Q) $(CC) $(c_flags) -c -o $@ $<

$(abs_objtree)/%.o: %.S
	@echo "  AS     " $@
	$(Q) $(CC) $(LINUXINCLUDE) $(KBUILD_CFLAGS) -D__ASSEMBLY__ -c -o $@ $<

$(abs_objtree)/%.lds: %.lds.S
	@echo "  LDS    " $@
	$(Q) $(CPP) $(LINUXINCLUDE) -P -Ux86 -D__ASSEMBLY__ -DLINKER_SCRIPT -o $@ $<

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

fs := $(addprefix fs/, open.o read_write.o file_table.o super.o char_dev.o stat.o exec.o pipe.o namei.o fcntl.o ioctl.o readdir.o select.o dcache.o inode.o attr.o bad_inode.o file.o filesystems.o namespace.o seq_file.o xattr.o libfs.o fs-writeback.o pnode.o splice.o sync.o utimes.o d_path.o stack.o fs_struct.o statfs.o fs_pin.o nsfs.o fs_types.o fs_context.o fs_parser.o fsopen.o init.o kernel_read_file.o remap_range.o buffer.o direct-io.o mpage.o proc_namespace.o anon_inodes.o locks.o binfmt_script.o binfmt_elf.o mbcache.o fhandle.o exportfs/expfs.o devpts/inode.o \
	$(addprefix ramfs/, inode.o file-mmu.o) \
	$(addprefix iomap/, trace.o iter.o buffered-io.o direct-io.o fiemap.o seek.o) \
	$(addprefix ext2/, balloc.o dir.o file.o ialloc.o inode.o ioctl.o namei.o super.o symlink.o) \
	$(addprefix proc/, task_mmu.o inode.o root.o base.o generic.o array.o fd.o proc_tty.o cmdline.o consoles.o cpuinfo.o devices.o interrupts.o loadavg.o meminfo.o stat.o uptime.o util.o version.o softirqs.o namespaces.o self.o thread_self.o proc_net.o))

mm := $(addprefix mm/, highmem.o memory.o mincore.o mlock.o mmap.o mmu_gather.o mprotect.o mremap.o msync.o page_vma_mapped.o pagewalk.o pgtable-generic.o rmap.o vmalloc.o filemap.o mempool.o oom_kill.o fadvise.o maccess.o page-writeback.o folio-compat.o readahead.o swap.o truncate.o vmscan.o shmem.o util.o mmzone.o vmstat.o backing-dev.o mm_init.o percpu.o slab_common.o compaction.o vmacache.o interval_tree.o list_lru.o workingset.o debug.o gup.o mmap_lock.o page_alloc.o init-mm.o memblock.o madvise.o dmapool.o sparse.o slub.o early_ioremap.o secretmem.o)

init := $(addprefix init/, main.o version.o noinitramfs.o calibrate.o init_task.o do_mounts.o)

security := $(addprefix security/, commoncap.o min_addr.o)

kernel := $(addprefix kernel/, fork.o exec_domain.o panic.o cpu.o exit.o softirq.o resource.o sysctl.o capability.o ptrace.o user.o signal.o sys.o umh.o workqueue.o pid.o task_work.o extable.o params.o kthread.o sys_ni.o nsproxy.o notifier.o ksysfs.o cred.o reboot.o async.o range.o smpboot.o ucount.o regset.o groups.o irq_work.o power/qos.o bpf/core.o static_call.o static_call_inline.o context_tracking.o iomem.o up.o platform-feature.o \
	$(addprefix sched/, core.o fair.o build_policy.o build_utility.o) \
	$(addprefix locking/, mutex.o semaphore.o rwsem.o percpu-rwsem.o rtmutex_api.o) \
	$(addprefix printk/, printk.o printk_safe.o printk_ringbuffer.o) \
	$(addprefix irq/, irqdesc.o handle.o manage.o spurious.o resend.o chip.o dummychip.o devres.o autoprobe.o irqdomain.o proc.o matrix.o msi.o) \
	$(addprefix rcu/, update.o sync.o srcutiny.o tiny.o) \
	$(addprefix dma/, mapping.o direct.o swiotlb.o remap.o) \
	$(addprefix entry/, common.o syscall_user_dispatch.o) \
	$(addprefix time/, time.o timer.o hrtimer.o timekeeping.o ntp.o clocksource.o jiffies.o timer_list.o timeconv.o timecounter.o alarmtimer.o posix-timers.o posix-cpu-timers.o posix-clock.o itimer.o clockevents.o tick-common.o tick-broadcast.o tick-oneshot.o tick-sched.o vsyscall.o) \
	$(addprefix futex/, core.o syscalls.o pi.o requeue.o waitwake.o) \
	$(addprefix events/, core.o ring_buffer.o callchain.o hw_breakpoint.o))

lib := $(addprefix lib/, bcd.o sort.o parser.o debug_locks.o random32.o bust_spinlocks.o kasprintf.o bitmap.o scatterlist.o list_sort.o uuid.o iov_iter.o clz_ctz.o bsearch.o find_bit.o llist.o memweight.o kfifo.o percpu-refcount.o rhashtable.o once.o refcount.o usercopy.o errseq.o bucket_locks.o generic-radix-tree.o lockref.o sbitmap.o string_helpers.o hexdump.o kstrtox.o iomap.o pci_iomap.o iomap_copy.o devres.o bitrev.o crc32.o syscall.o nlattr.o strncpy_from_user.o strnlen_user.o net_utils.o sg_pool.o \
	$(addprefix math/, div64.o gcd.o lcm.o int_pow.o int_sqrt.o reciprocal_div.o) \
	$(addprefix crypto/, chacha.o blake2s.o blake2s-generic.o blake2s-selftest.o))

libs := $(addprefix lib/, ctype.o string.o vsprintf.o cmdline.o rbtree.o radix-tree.o timerqueue.o xarray.o idr.o extable.o sha1.o irq_regs.o argv_split.o flex_proportions.o ratelimit.o show_mem.o is_single_threaded.o plist.o decompress.o kobject_uevent.o earlycpio.o seq_buf.o siphash.o dec_and_lock.o nmi_backtrace.o nodemask.o win_minmax.o memcat_p.o buildid.o dump_stack.o kobject.o klist.o logic_pio.o bug.o)
libs += $(addprefix arch/x86/lib/, delay.o misc.o cmdline.o cpu.o usercopy_64.o usercopy.o getuser.o putuser.o memcpy_64.o pc-conf-reg.o copy_mc.o copy_mc_64.o insn.o inat.o insn-eval.o csum-partial_64.o csum-copy_64.o csum-wrappers_64.o clear_page_64.o copy_page_64.o memmove_64.o memset_64.o copy_user_64.o cmpxchg16b_emu.o)
libs := $(addprefix build/, $(libs))

arch/x86/lib/inat-tables.c:
	$(Q) awk -f $(srctree)/arch/x86/tools/gen-insn-attr-x86.awk $(srctree)/arch/x86/lib/x86-opcode-map.txt > $@

build/arch/x86/lib/inat.o: arch/x86/lib/inat-tables.c

build/lib/crc32.o: build/lib/crc32table.h
build/lib/crc32table.h: build/lib/gen_crc32table
	$(Q) $< > $@

x86 := $(addprefix arch/x86/, $(addprefix entry/, entry_64.o thunk_64.o syscall_64.o common.o $(addprefix vdso/, vma.o extable.o vdso-image-64.o)) \
	$(addprefix lib/, msr.o msr-reg.o msr-reg-export.o hweight.o iomem.o iomap_copy_64.o) \
	$(addprefix events/, core.o probe.o msr.o) \
	$(addprefix realmode/, init.o rmpiggy.o) \
	$(addprefix mm/, init.o init_64.o fault.o ioremap.o extable.o mmap.o pgtable.o physaddr.o tlb.o cpu_entry_area.o maccess.o pgprot.o $(addprefix pat/, set_memory.o memtype.o)) \
	$(addprefix pci/, i386.o init.o direct.o fixup.o legacy.o irq.o common.o early.o bus_numa.o) \
	$(addprefix kernel/, process_64.o signal.o traps.o idt.o irq.o irq_64.o dumpstack_64.o time.o ioport.o dumpstack.o nmi.o setup.o x86_init.o i8259.o irqinit.o irq_work.o probe_roms.o sys_x86_64.o bootflag.o e820.o pci-dma.o quirks.o topology.o kdebugfs.o alternative.o i8253.o hw_breakpoint.o tsc.o tsc_msr.o io_delay.o rtc.o resource.o irqflags.o static_call.o process.o $(addprefix fpu/, init.o bugs.o core.o regset.o signal.o xstate.o) ptrace.o step.o stacktrace.o $(addprefix cpu/, cacheinfo.o scattered.o topology.o common.o rdrand.o match.o bugs.o aperfmperf.o cpuid-deps.o umwait.o proc.o capflags.o powerflags.o feat_ctl.o perfctr-watchdog.o vmware.o hypervisor.o mshyperv.o) reboot.o early-quirks.o tsc_sync.o mpparse.o $(addprefix apic/, apic.o apic_common.o apic_noop.o ipi.o vector.o hw_nmi.o io_apic.o apic_flat_64.o probe_64.o msi.o) trace_clock.o early_printk.o hpet.o kvm.o kvmclock.o paravirt.o pvclock.o pcspeaker.o perf_regs.o unwind_orc.o vsmp_64.o head_64.o head64.o ebda.o platform-quirks.o))

build/arch/x86/realmode/rmpiggy.o: build/arch/x86/realmode/rm/realmode.bin

REALMODE_OBJS = $(addprefix build/arch/x86/realmode/rm/, header.o trampoline_64.o stack.o reboot.o)
$(REALMODE_OBJS): KBUILD_CFLAGS := $(REALMODE_CFLAGS) -D_WAKEUP -I$(srctree)/arch/x86/boot -D__KERNEL__

build/arch/x86/realmode/rm/pasyms.h: $(REALMODE_OBJS)
	$(Q) $(NM) $^ | sed -n -r -e 's/^([0-9a-fA-F]+) [ABCDGRSTVW] (.+)$$/pa_\2 = \2;/p' | sort | uniq > $@

build/arch/x86/realmode/rm/realmode.lds: build/arch/x86/realmode/rm/pasyms.h

build/arch/x86/realmode/rm/realmode.elf: build/arch/x86/realmode/rm/realmode.lds $(REALMODE_OBJS)
	$(Q) $(LD) -m elf_i386 --emit-relocs -T $^ -o $@

build/arch/x86/realmode/rm/realmode.bin: build/arch/x86/realmode/rm/realmode.elf build/arch/x86/realmode/rm/realmode.relocs
	$(Q) $(OBJCOPY) -O binary $< $@

build/arch/x86/realmode/rm/realmode.relocs: build/arch/x86/realmode/rm/realmode.elf
	$(Q) arch/x86/tools/relocs --realmode $< > $@

extra-y	:= kernel/vmlinux.lds

CFLAGS_build/arch/x86/kernel/irq.o := -I $(srctree)/arch/x86/kernel/../include/asm/trace
CFLAGS_build/arch/x86/mm/fault.o := -I $(srctree)/arch/x86/kernel/../include/asm/trace

cpufeature = arch/x86/kernel/cpu/../../include/asm/cpufeatures.h
vmxfeature = arch/x86/kernel/cpu/../../include/asm/vmxfeatures.h

arch/x86/kernel/cpu/capflags.c: $(cpufeature) $(vmxfeature) arch/x86/kernel/cpu/mkcapflags.sh
	$(Q) $(CONFIG_SHELL) $(srctree)/arch/x86/kernel/cpu/mkcapflags.sh $@ $^

vobjs-y := vdso-note.o vclock_gettime.o vgetcpu.o

vobjs := $(foreach F,$(vobjs-y),build/arch/x86/entry/vdso/$F)

build/arch/x86/entry/vdso/vdso64.so.dbg: build/arch/x86/entry/vdso/vdso.lds $(vobjs)
	$(Q) $(LD) -o $@ -shared --hash-style=both -Bsymbolic -m elf_x86_64 \
		-soname linux-vdso.so.1 --no-undefined -z max-page-size=4096 -T $^

arch/x86/entry/vdso/vdso-image-64.c: build/arch/x86/entry/vdso/vdso64.so.dbg build/arch/x86/entry/vdso/vdso64.so build/arch/x86/entry/vdso/vdso2c
	$(Q) build/arch/x86/entry/vdso/vdso2c $< $(<:64.dbg=64) $@

$(vobjs): KBUILD_CFLAGS := $(KBUILD_CFLAGS) -mcmodel=small -fPIC -O2 -fasynchronous-unwind-tables -m64 -fno-stack-protector -fno-omit-frame-pointer -foptimize-sibling-calls -DDISABLE_BRANCH_PROFILING -DBUILD_VDSO -D__KERNEL__

build/arch/x86/entry/vdso/%.so: build/arch/x86/entry/vdso/%.so.dbg
	$(Q) $(OBJCOPY) -S --remove-section __ex_table $< $@

SETUP_OBJS = $(addprefix build/arch/x86/boot/, a20.o bioscall.o cmdline.o copy.o cpu.o cpuflags.o cpucheck.o early_serial_console.o edd.o header.o main.o memory.o pm.o pmjump.o printf.o regs.o string.o tty.o video.o video-mode.o version.o video-vga.o video-vesa.o video-bios.o)
$(SETUP_OBJS): KBUILD_CFLAGS := $(REALMODE_CFLAGS) -fmacro-prefix-map=$(srctree)/= -fno-asynchronous-unwind-tables -include $(srctree)/scripts/config.h -D__KERNEL__

build/arch/x86/boot/cpu.o: build/arch/x86/boot/cpustr.h

build/arch/x86/boot/cpustr.h: build/arch/x86/boot/mkcpustr
	@echo "  CPUSTR " $@
	$(Q) build/arch/x86/boot/mkcpustr > $@

build/arch/x86/boot/bzImage: build/arch/x86/boot/setup.bin build/arch/x86/boot/vmlinux.bin build/arch/x86/boot/tools/build build/vmlinux $(SETUP_OBJS) $(REALMODE_OBJS)
	@echo "  BUILD  " $@
	$(Q) build/arch/x86/boot/tools/build build/arch/x86/boot/setup.bin build/arch/x86/boot/vmlinux.bin build/arch/x86/boot/zoffset.h $@

build/arch/x86/boot/vmlinux.bin: build/arch/x86/boot/compressed/vmlinux
	@echo "  OBJCOPY" $@
	$(Q) $(OBJCOPY) -O binary -R .note -R .comment -S $< $@

build/arch/x86/boot/zoffset.h: build/arch/x86/boot/compressed/vmlinux
	$(Q) $(NM) $< | sed -n -e 's/^\([0-9a-fA-F]*\) [a-zA-Z] \(startup_32\|startup_64\|efi32_stub_entry\|efi64_stub_entry\|efi_pe_entry\|efi32_pe_entry\|input_data\|kernel_info\|_end\|_ehead\|_text\|z_.*\)$$/\#define ZO_\2 0x\1/p' > $@

build/arch/x86/boot/header.o: build/arch/x86/boot/zoffset.h

build/arch/x86/boot/setup.elf: arch/x86/boot/setup.ld $(SETUP_OBJS)
	@echo "  LD     " $@
	$(Q) $(LD) -m elf_i386 -T $^ -o $@

build/arch/x86/boot/setup.bin: build/arch/x86/boot/setup.elf
	@echo "  OBJCOPY" $@
	$(Q) $(OBJCOPY) -O binary $< $@

build/arch/x86/boot/compressed/../voffset.h: build/vmlinux
	@echo "  VOFFSET" $@
	$(Q) $(NM) $< | sed -n -e 's/^\([0-9a-fA-F]*\) [ABCDGRSTVW] \(_text\|__bss_start\|_end\)$$/\#define VO_\2 _AC(0x\1,UL)/p' > $@

build/arch/x86/boot/compressed/misc.o: build/arch/x86/boot/compressed/../voffset.h

VMLINUX_OBJS = $(addprefix build/arch/x86/boot/compressed/, vmlinux.lds kernel_info.o head_64.o misc.o string.o cmdline.o error.o piggy.o cpuflags.o early_serial_console.o ident_map_64.o idt_64.o pgtable_64.o mem_encrypt.o idt_handlers_64.o)
$(VMLINUX_OBJS): KBUILD_CFLAGS := -m64 -O2 -fno-strict-aliasing -fPIE -Wundef -mno-mmx -mno-sse -ffreestanding -fshort-wchar -fno-stack-protector -Wno-address-of-packed-member -Wno-gnu -Wno-pointer-sign -fmacro-prefix-map=$(srctree)/= -fno-asynchronous-unwind-tables -D__DISABLE_EXPORTS -include $(srctree)/include/linux/hidden.h -D__KERNEL__

build/arch/x86/boot/compressed/vmlinux: $(VMLINUX_OBJS)
	$(Q) $(LD) -m elf_x86_64 --no-ld-generated-unwind-info --no-dynamic-linker -T $(VMLINUX_OBJS) -o $@

build/arch/x86/boot/compressed/vmlinux.bin: build/vmlinux
	@echo "  OBJCOPY" $@
	$(Q) $(OBJCOPY) -R .comment -S $< $@

build/arch/x86/boot/compressed/vmlinux.bin.gz: build/arch/x86/boot/compressed/vmlinux.bin
	@echo "  GZIP   " $@
	$(Q) cat $< | gzip -n -f -9 > $@

arch/x86/boot/compressed/piggy.S: build/arch/x86/boot/compressed/vmlinux.bin.gz build/arch/x86/boot/compressed/mkpiggy
	@echo "  MKPIGGY" $@
	$(Q) build/arch/x86/boot/compressed/mkpiggy $< > $@

objs = $(addprefix $(abs_objtree)/, $(init) $(block) $(net) $(drivers) $(fs) $(mm) $(security) $(lib) $(kernel) $(x86))
build/vmlinux: build/arch/x86/kernel/vmlinux.lds $(objs) $(libs)
	@echo "  LD     " $@
	$(Q) ld -m elf_x86_64 -z max-page-size=0x200000 --script=$< -o $@ --whole-archive $(objs) --no-whole-archive -start-group $(libs) --end-group
	@echo "  SYSMAP " System.map
	$(Q) nm -n build/vmlinux | grep -v '\( [aNUw] \)\|\(__crc_\)\|\( \$[adt]\)\|\( \.L\)' > build/System.map

prepare:
	@ mkdir -p $(abs_objtree)/include/generated/uapi/linux/ \
		$(abs_objtree)/{mm,block/partitions,init,scripts,security} \
		$(abs_objtree)/arch/x86/{boot/compressed,entry/vdso,tools,boot/tools} \
		$(abs_objtree)/drivers/{base/firmware_loader/builtin,base/power,pci/pcie,pci/msi,clocksource,virtio,char,net,rtc,block,tty/hvc,platform/x86} \
		$(abs_objtree)/net/{ipv6,ethernet,ethtool,sched,unix,netlink,core} \
		$(abs_objtree)/fs/{iomap,nls,proc,devpts,ext2,ramfs,exportfs} \
		$(abs_objtree)/arch/x86/{entry/vdso,realmode/rm,kernel/{cpu,fpu,apic},mm/pat,events,boot,pci,tools,kvm,lib} \
		$(abs_objtree)/lib/{math,crypto} \
		$(abs_objtree)/kernel/{events,sched,entry,bpf,locking,futex,power,printk,dma,irq,rcu,time}
	@ echo '#define UTS_RELEASE "5.19.0"' > $(abs_objtree)/include/generated/utsrelease.h
	@ cp $(srctree)/scripts/compile.h $(abs_objtree)/include/generated/
	@ cp $(srctree)/scripts/version.h $(abs_objtree)/include/generated/uapi/linux/
	@ cp $(srctree)/lib/gen_crc32table $(abs_objtree)/lib/
	@ cp $(srctree)/arch/x86/tools/relocs $(abs_objtree)/arch/x86/tools/
	@ cp $(srctree)/arch/x86/boot/compressed/mkpiggy $(abs_objtree)/arch/x86/boot/compressed/
	@ cp $(srctree)/arch/x86/boot/mkcpustr $(abs_objtree)/arch/x86/boot/
	@ cp $(srctree)/arch/x86/boot/tools/build $(abs_objtree)/arch/x86/boot/tools
	@ cp $(srctree)/arch/x86/entry/vdso/vdso2c $(abs_objtree)/arch/x86/entry/vdso/
	$(Q) $(MAKE) -f $(srctree)/arch/x86/entry/syscalls/Makefile all
	$(Q) $(MAKE) -f $(srctree)/scripts/Makefile.asm-generic obj=arch/x86/include/generated/uapi/asm generic=include/uapi/asm-generic
	$(Q) $(MAKE) -f $(srctree)/scripts/Makefile.asm-generic obj=arch/x86/include/generated/asm generic=include/asm-generic
	$(Q) $(MAKE) -f $(srctree)/scripts/Makefile.build_
