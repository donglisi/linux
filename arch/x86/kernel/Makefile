extra-y	:= vmlinux.lds

CFLAGS_irq.o := -I $(srctree)/$(obj)/../include/asm/trace

obj-y := process_64.o signal.o traps.o idt.o irq.o irq_64.o dumpstack_64.o time.o ioport.o dumpstack.o nmi.o setup.o x86_init.o i8259.o irqinit.o irq_work.o probe_roms.o sys_x86_64.o bootflag.o e820.o pci-dma.o quirks.o topology.o kdebugfs.o alternative.o i8253.o hw_breakpoint.o tsc.o tsc_msr.o io_delay.o rtc.o resource.o irqflags.o static_call.o process.o fpu/ ptrace.o step.o stacktrace.o cpu/ reboot.o early-quirks.o tsc_sync.o mpparse.o apic/ trace_clock.o early_printk.o hpet.o kvm.o kvmclock.o paravirt.o pvclock.o pcspeaker.o perf_regs.o unwind_orc.o vsmp_64.o head_64.o head64.o ebda.o platform-quirks.o
