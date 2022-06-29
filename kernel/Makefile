obj-y     = fork.o exec_domain.o panic.o 	    cpu.o exit.o softirq.o resource.o 	    sysctl.o capability.o ptrace.o user.o 	    signal.o sys.o umh.o workqueue.o pid.o task_work.o 	    extable.o params.o 	    kthread.o sys_ni.o nsproxy.o 	    notifier.o ksysfs.o cred.o reboot.o 	    async.o range.o smpboot.o ucount.o regset.o groups.o

KCOV_INSTRUMENT_softirq.o := n
KCSAN_SANITIZE_softirq.o = n
KCOV_INSTRUMENT_extable.o := n
KCOV_INSTRUMENT_stacktrace.o := n
KCOV_INSTRUMENT_kcov.o := n
KASAN_SANITIZE_kcov.o := n
KCSAN_SANITIZE_kcov.o := n
UBSAN_SANITIZE_kcov.o := n
CFLAGS_kcov.o := $(call cc-option, -fno-conserve-stack) -fno-stack-protector

CFLAGS_REMOVE_cfi.o := $(CC_FLAGS_CFI)

obj-y += sched/
obj-y += locking/
obj-y += power/
obj-y += printk/
obj-y += irq/
obj-y += rcu/
obj-y += dma/
obj-y += entry/
obj-y += stacktrace.o
obj-y += time/
obj-y += futex/
obj-y += dma.o
obj-y += smp.o
obj-y += kallsyms.o
obj-y += stop_machine.o
obj-y += utsname_sysctl.o
obj-y += irq_work.o
obj-y += bpf/
obj-y += static_call.o
obj-y += static_call_inline.o
obj-y += events/
obj-y += context_tracking.o

obj-y += iomem.o
obj-y += rseq.o


CFLAGS_stackleak.o += $(DISABLE_STACKLEAK_PLUGIN)
KASAN_SANITIZE_stackleak.o := n
KCSAN_SANITIZE_stackleak.o := n
KCOV_INSTRUMENT_stackleak.o := n

$(obj)/configs.o: $(obj)/config_data.gz

targets += config_data config_data.gz
$(obj)/config_data.gz: $(obj)/config_data FORCE
	$(call if_changed,gzip)

filechk_cat = cat $<

$(obj)/config_data: $(KCONFIG_CONFIG) FORCE
	$(call filechk,cat)

$(obj)/kheaders.o: $(obj)/kheaders_data.tar.xz

quiet_cmd_genikh = CHK     $(obj)/kheaders_data.tar.xz
      cmd_genikh = $(CONFIG_SHELL) $(srctree)/kernel/gen_kheaders.sh $@
$(obj)/kheaders_data.tar.xz: FORCE
	$(call cmd,genikh)

clean-files := kheaders_data.tar.xz kheaders.md5
