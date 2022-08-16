obj-y += $(addprefix entry/, entry_64.o thunk_64.o syscall_64.o common.o vdso/) \
	$(addprefix events/, core.o probe.o msr.o) \
	$(addprefix realmode/, init.o rmpiggy.o) \
	$(addprefix mm/, init.o init_64.o fault.o ioremap.o extable.o mmap.o pgtable.o physaddr.o tlb.o cpu_entry_area.o maccess.o pgprot.o $(addprefix pat/, set_memory.o memtype.o)) \
	$(addprefix pci/, i386.o init.o direct.o fixup.o legacy.o irq.o common.o early.o bus_numa.o) \
	$(addprefix kernel/, process_64.o signal.o traps.o idt.o irq.o irq_64.o dumpstack_64.o time.o ioport.o dumpstack.o nmi.o setup.o x86_init.o i8259.o irqinit.o irq_work.o probe_roms.o sys_x86_64.o bootflag.o e820.o pci-dma.o quirks.o topology.o kdebugfs.o alternative.o i8253.o hw_breakpoint.o tsc.o tsc_msr.o io_delay.o rtc.o resource.o irqflags.o static_call.o process.o $(addprefix fpu/, init.o bugs.o core.o regset.o signal.o xstate.o) ptrace.o step.o stacktrace.o $(addprefix cpu/, cacheinfo.o scattered.o topology.o common.o rdrand.o match.o bugs.o aperfmperf.o cpuid-deps.o umwait.o proc.o capflags.o powerflags.o feat_ctl.o perfctr-watchdog.o vmware.o hypervisor.o mshyperv.o) reboot.o early-quirks.o tsc_sync.o mpparse.o apic/ trace_clock.o early_printk.o hpet.o kvm.o kvmclock.o paravirt.o pvclock.o pcspeaker.o perf_regs.o unwind_orc.o vsmp_64.o head_64.o head64.o ebda.o platform-quirks.o)

$(obj)/realmode/rmpiggy.o: $(obj)/realmode/rm/realmode.bin

$(obj)/realmode/rm/realmode.bin:
	$(Q) $(MAKE) -f $(srctree)/scripts/Makefile.build obj=$(obj)/realmode/rm $@

extra-y	:= kernel/vmlinux.lds

CFLAGS_$(obj)/kernel/irq.o := -I $(srctree)/$(obj)/kernel/../include/asm/trace
CFLAGS_$(obj)/mm/fault.o := -I $(srctree)/$(obj)/kernel/../include/asm/trace

cpufeature = $(obj)/kernel/cpu/../../include/asm/cpufeatures.h
vmxfeature = $(obj)/kernel/cpu/../../include/asm/vmxfeatures.h

$(obj)/kernel/cpu/capflags.c: $(cpufeature) $(vmxfeature) $(obj)/kernel/cpu/mkcapflags.sh
	$(Q) $(CONFIG_SHELL) $(srctree)/$(obj)/kernel/cpu/mkcapflags.sh $@ $^

