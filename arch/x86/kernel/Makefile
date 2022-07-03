extra-y	:= head_64.o head64.o ebda.o platform-quirks.o vmlinux.lds

CPPFLAGS_vmlinux.lds += -U$(UTS_MACHINE)

CFLAGS_irq.o := -I $(srctree)/$(src)/../include/asm/trace

obj-y := process_64.o signal.o traps.o idt.o ldt.o irq.o irq_64.o dumpstack_64.o time.o ioport.o dumpstack.o nmi.o setup.o x86_init.o i8259.o irqinit.o irq_work.o probe_roms.o sys_x86_64.o espfix_64.o ksysfs.o bootflag.o e820.o pci-dma.o quirks.o topology.o kdebugfs.o alternative.o i8253.o hw_breakpoint.o tsc.o tsc_msr.o io_delay.o rtc.o resource.o irqflags.o static_call.o process.o fpu/ ptrace.o step.o i8237.o stacktrace.o cpu/ reboot.o early-quirks.o smp.o smpboot.o tsc_sync.o setup_percpu.o mpparse.o apic/ trace_clock.o early_printk.o hpet.o kvm.o kvmclock.o paravirt.o pvclock.o pcspeaker.o perf_regs.o umip.o unwind_orc.o vsmp_64.o
