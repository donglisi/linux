CFLAGS_common.o		:= -fno-stack-protector

obj-y			:= cacheinfo.o scattered.o topology.o
obj-y			+= common.o
obj-y			+= rdrand.o
obj-y			+= match.o
obj-y			+= bugs.o
obj-y			+= aperfmperf.o
obj-y			+= cpuid-deps.o
obj-y			+= umwait.o

obj-y	+= proc.o
obj-y += capflags.o powerflags.o

obj-y += feat_ctl.o
obj-y		+= amd.o

obj-y		+= perfctr-watchdog.o
obj-y		+= mtrr/

obj-y		+= vmware.o hypervisor.o mshyperv.o

cpufeature = $(src)/../../include/asm/cpufeatures.h
vmxfeature = $(src)/../../include/asm/vmxfeatures.h

$(obj)/capflags.c: $(cpufeature) $(vmxfeature) $(src)/mkcapflags.sh
	$(CONFIG_SHELL) $(srctree)/$(src)/mkcapflags.sh $@ $^

targets += capflags.c
