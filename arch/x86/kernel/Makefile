# SPDX-License-Identifier: GPL-2.0
#
# Makefile for the linux kernel.
#

extra-y	:= head_64.o
extra-y	+= head64.o
extra-y	+= ebda.o
extra-y	+= platform-quirks.o
extra-y	+= vmlinux.lds

CPPFLAGS_vmlinux.lds += -U$(UTS_MACHINE)

ifdef CONFIG_FUNCTION_TRACER
# Do not profile debug and lowlevel utilities
CFLAGS_REMOVE_tsc.o = -pg
CFLAGS_REMOVE_paravirt-spinlocks.o = -pg
CFLAGS_REMOVE_pvclock.o = -pg
CFLAGS_REMOVE_kvmclock.o = -pg
CFLAGS_REMOVE_ftrace.o = -pg
CFLAGS_REMOVE_early_printk.o = -pg
CFLAGS_REMOVE_head64.o = -pg
CFLAGS_REMOVE_sev.o = -pg
endif

KASAN_SANITIZE_head$(BITS).o				:= n
KASAN_SANITIZE_dumpstack.o				:= n
KASAN_SANITIZE_dumpstack_$(BITS).o			:= n
KASAN_SANITIZE_stacktrace.o				:= n
KASAN_SANITIZE_paravirt.o				:= n
KASAN_SANITIZE_sev.o					:= n

# With some compiler versions the generated code results in boot hangs, caused
# by several compilation units. To be safe, disable all instrumentation.
KCSAN_SANITIZE := n

OBJECT_FILES_NON_STANDARD_test_nx.o			:= y

ifdef CONFIG_FRAME_POINTER
OBJECT_FILES_NON_STANDARD_ftrace_$(BITS).o		:= y
endif

# If instrumentation of this dir is enabled, boot hangs during first second.
# Probably could be more selective here, but note that files related to irqs,
# boot, dumpstack/stacktrace, etc are either non-interesting or can lead to
# non-deterministic coverage.
KCOV_INSTRUMENT		:= n

CFLAGS_irq.o := -I $(srctree)/$(src)/../include/asm/trace

obj-y			:= process_$(BITS).o signal.o
obj-$(CONFIG_COMPAT)	+= signal_compat.o
obj-y			+= traps.o idt.o irq.o irq_$(BITS).o dumpstack_$(BITS).o
obj-y			+= time.o ioport.o dumpstack.o nmi.o
obj-y	+= ldt.o
obj-y			+= setup.o x86_init.o i8259.o irqinit.o
obj-$(CONFIG_JUMP_LABEL)	+= jump_label.o
obj-$(CONFIG_IRQ_WORK)  += irq_work.o
obj-y			+= probe_roms.o
obj-$(CONFIG_X86_32)	+= sys_ia32.o
obj-$(CONFIG_IA32_EMULATION)	+= sys_ia32.o
obj-y	+= sys_x86_64.o
obj-y	+= espfix_64.o
obj-y	+= ksysfs.o
obj-y			+= bootflag.o e820.o
obj-y			+= pci-dma.o quirks.o topology.o kdebugfs.o
obj-y			+= alternative.o i8253.o hw_breakpoint.o
obj-y			+= tsc.o tsc_msr.o io_delay.o rtc.o
obj-y			+= resource.o
obj-y			+= irqflags.o
obj-y			+= static_call.o

obj-y				+= process.o
obj-y				+= fpu/
obj-y				+= ptrace.o
obj-$(CONFIG_X86_32)		+= tls.o
obj-$(CONFIG_IA32_EMULATION)	+= tls.o
obj-y				+= step.o
obj-$(CONFIG_INTEL_TXT)		+= tboot.o
obj-y	+= i8237.o
obj-y				+= stacktrace.o
obj-y				+= cpu/
obj-y				+= reboot.o
obj-$(CONFIG_X86_MSR)		+= msr.o
obj-$(CONFIG_X86_CPUID)		+= cpuid.o
obj-y		+= early-quirks.o
apm-y				:= apm_32.o
obj-$(CONFIG_APM)		+= apm.o
obj-y		+= smp.o
obj-y		+= smpboot.o
obj-y		+= tsc_sync.o
obj-y		+= setup_percpu.o
obj-y	+= mpparse.o
obj-y				+= apic/
obj-$(CONFIG_X86_REBOOTFIXUPS)	+= reboot_fixups_32.o
obj-$(CONFIG_DYNAMIC_FTRACE)	+= ftrace.o
obj-$(CONFIG_FUNCTION_TRACER)	+= ftrace_$(BITS).o
obj-$(CONFIG_FUNCTION_GRAPH_TRACER) += ftrace.o
obj-$(CONFIG_FTRACE_SYSCALLS)	+= ftrace.o
obj-y		+= trace_clock.o
obj-$(CONFIG_TRACING)		+= trace.o
obj-$(CONFIG_RETHOOK)		+= rethook.o
obj-$(CONFIG_CRASH_CORE)	+= crash_core_$(BITS).o
obj-$(CONFIG_KEXEC_CORE)	+= machine_kexec_$(BITS).o
obj-$(CONFIG_KEXEC_CORE)	+= relocate_kernel_$(BITS).o crash.o
obj-$(CONFIG_KEXEC_FILE)	+= kexec-bzimage64.o
obj-$(CONFIG_CRASH_DUMP)	+= crash_dump_$(BITS).o
obj-$(CONFIG_MODULES)		+= module.o
obj-$(CONFIG_X86_32)		+= doublefault_32.o
obj-$(CONFIG_KGDB)		+= kgdb.o
obj-$(CONFIG_VM86)		+= vm86_32.o
obj-y	+= early_printk.o

obj-y 	+= hpet.o

obj-$(CONFIG_AMD_NB)		+= amd_nb.o
obj-$(CONFIG_DEBUG_NMI_SELFTEST) += nmi_selftest.o

obj-y		+= kvm.o kvmclock.o
obj-y		+= paravirt.o
obj-$(CONFIG_PARAVIRT_SPINLOCKS)+= paravirt-spinlocks.o
obj-y	+= pvclock.o
obj-$(CONFIG_X86_PMEM_LEGACY_DEVICE) += pmem.o

obj-$(CONFIG_JAILHOUSE_GUEST)	+= jailhouse.o

obj-$(CONFIG_EISA)		+= eisa.o
obj-$(CONFIG_PCSPKR_PLATFORM)	+= pcspeaker.o

obj-$(CONFIG_X86_CHECK_BIOS_CORRUPTION) += check.o

obj-$(CONFIG_OF)			+= devicetree.o
obj-$(CONFIG_UPROBES)			+= uprobes.o

obj-y		+= perf_regs.o
obj-$(CONFIG_TRACING)			+= tracepoint.o
obj-$(CONFIG_SCHED_MC_PRIO)		+= itmt.o
obj-y			+= umip.o

obj-y		+= unwind_orc.o
obj-$(CONFIG_UNWINDER_FRAME_POINTER)	+= unwind_frame.o
obj-$(CONFIG_UNWINDER_GUESS)		+= unwind_guess.o

obj-$(CONFIG_AMD_MEM_ENCRYPT)		+= sev.o

###
# 64 bit specific files
	obj-$(CONFIG_AUDIT)		+= audit_64.o

	obj-$(CONFIG_GART_IOMMU)	+= amd_gart_64.o aperture_64.o

	obj-$(CONFIG_MMCONF_FAM10H)	+= mmconf-fam10h_64.o
	obj-y				+= vsmp_64.o
