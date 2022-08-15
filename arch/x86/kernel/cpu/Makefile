obj-y := cacheinfo.o scattered.o topology.o common.o rdrand.o match.o bugs.o aperfmperf.o cpuid-deps.o umwait.o proc.o capflags.o powerflags.o feat_ctl.o perfctr-watchdog.o vmware.o hypervisor.o mshyperv.o

cpufeature = $(obj)/../../include/asm/cpufeatures.h
vmxfeature = $(obj)/../../include/asm/vmxfeatures.h

$(obj)/capflags.c: $(cpufeature) $(vmxfeature) $(obj)/mkcapflags.sh
	$(Q) $(CONFIG_SHELL) $(srctree)/$(obj)/mkcapflags.sh $@ $^
