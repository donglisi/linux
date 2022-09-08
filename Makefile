MAKEFLAGS := -rR --no-print-directory
CC := gcc

ifeq ("$(origin V)", "command line")
        Q :=
        E = @\#
else
        Q := @
        E := @echo
endif

$(shell bash -c "mkdir -p \
	      build/{include,mm,block/partitions,init,security,lib/{math,crypto},fs/{proc,ext2,ramfs}} \
	      build/arch/x86/{include,entry/vdso,kernel/{cpu,fpu,apic},mm/pat,events,pci,kvm,lib,boot/compressed} \
	      build/drivers/{base/power,pci/{pcie,msi},clocksource,virtio,char,net,rtc,block,tty/hvc,platform/x86} \
	      build/net/{ipv6,ethernet,ethtool,sched,unix,netlink,core} \
	      build/kernel/{events,sched,entry,bpf,locking,futex,printk,dma,irq,rcu,time}")

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

x86	:= $(addprefix arch/x86/, events/core.o \
		$(addprefix entry/, entry_64.o) \
		$(addprefix lib/, hweight.o iomem.o iomap_copy_64.o delay.o misc.o cmdline.o cpu.o usercopy_64.o usercopy.o getuser.o putuser.o memcpy_64.o \
			copy_mc.o copy_mc_64.o insn.o inat.o insn-eval.o csum-partial_64.o csum-copy_64.o csum-wrappers_64.o clear_page_64.o copy_page_64.o \
			memmove_64.o memset_64.o copy_user_64.o cmpxchg16b_emu.o) \
		$(addprefix mm/, init.o init_64.o fault.o tlb.o) \
		$(addprefix kernel/, process_64.o signal.o traps.o idt.o irq.o irq_64.o dumpstack_64.o time.o ioport.o dumpstack.o nmi.o setup.o x86_init.o \
			i8259.o irqinit.o irq_work.o probe_roms.o sys_x86_64.o e820.o quirks.o topology.o kdebugfs.o alternative.o i8253.o hw_breakpoint.o \
			tsc.o tsc_msr.o io_delay.o rtc.o resource.o irqflags.o static_call.o process.o ptrace.o step.o stacktrace.o reboot.o early-quirks.o \
			tsc_sync.o hpet.o perf_regs.o unwind_orc.o head_64.o head64.o platform-quirks.o early_printk.o \
			$(addprefix cpu/, common.o)))

init	:= $(addprefix init/, main.o version.o noinitramfs.o calibrate.o init_task.o do_mounts.o)

kernel	:= $(addprefix kernel/, fork.o exec_domain.o panic.o cpu.o exit.o softirq.o resource.o sysctl.o capability.o \
		ptrace.o user.o signal.o sys.o workqueue.o pid.o task_work.o extable.o params.o kthread.o \
		sys_ni.o nsproxy.o notifier.o cred.o reboot.o async.o range.o ucount.o regset.o \
		irq_work.o static_call.o static_call_inline.o up.o \
		$(addprefix sched/, core.o build_policy.o build_utility.o) \
		$(addprefix locking/, mutex.o semaphore.o rwsem.o percpu-rwsem.o rtmutex_api.o) \
		$(addprefix printk/, printk.o printk_safe.o printk_ringbuffer.o) \
		$(addprefix entry/, common.o))

lib	:= $(addprefix lib/, bcd.o sort.o parser.o debug_locks.o random32.o bitmap.o \
		uuid.o iov_iter.o find_bit.o string_helpers.o hexdump.o kstrtox.o \
		ctype.o string.o vsprintf.o cmdline.o rbtree.o radix-tree.o sym.o \
		$(addprefix math/, div64.o gcd.o lcm.o int_pow.o int_sqrt.o reciprocal_div.o))

mm	:= $(addprefix mm/, memory.o mmu_gather.o mremap.o page_vma_mapped.o pgtable-generic.o \
		vmalloc.o filemap.o mempool.o oom_kill.o maccess.o folio-compat.o readahead.o swap.o truncate.o vmscan.o \
		util.o mmzone.o vmstat.o mm_init.o percpu.o slab_common.o vmacache.o interval_tree.o list_lru.o workingset.o \
		debug.o gup.o page_alloc.o init-mm.o memblock.o sparse.o slub.o early_ioremap.o secretmem.o)

objs = $(addprefix build/, $(x86) $(init) $(kernel) $(lib) $(mm) drivers/tty/tty_io.o)
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
