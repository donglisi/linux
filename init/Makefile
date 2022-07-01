obj-y := main.o version.o noinitramfs.o calibrate.o init_task.o do_mounts.o

$(obj)/version.o: include/generated/compile.h
include/generated/compile.h:
	$(CONFIG_SHELL) $(srctree)/scripts/mkcompile_h $@ \
	"$(UTS_MACHINE)" "1" "$(CONFIG_PREEMPT_BUILD)" \
	"$(CONFIG_PREEMPT_DYNAMIC)" "$(CONFIG_PREEMPT_RT)" \
	"$(CONFIG_CC_VERSION_TEXT)" "$(LD)"
