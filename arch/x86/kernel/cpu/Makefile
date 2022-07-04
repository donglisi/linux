obj-y := cacheinfo.o scattered.o topology.o common.o rdrand.o match.o bugs.o aperfmperf.o cpuid-deps.o umwait.o proc.o capflags.o powerflags.o feat_ctl.o amd.o perfctr-watchdog.o mtrr/ vmware.o hypervisor.o mshyperv.o

cpufeature = $(src)/../../include/asm/cpufeatures.h
vmxfeature = $(src)/../../include/asm/vmxfeatures.h

$(obj)/capflags.c: $(cpufeature) $(vmxfeature) $(src)/mkcapflags.sh
	$(Q) $(CONFIG_SHELL) $(srctree)/$(src)/mkcapflags.sh $@ $^
