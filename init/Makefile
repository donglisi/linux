CONFIG_CC_VERSION_TEXT="gcc_12"

ccflags-y := -fno-function-sections -fno-data-sections

obj-y                          := main.o version.o mounts.o
obj-y                          += noinitramfs.o
obj-y += calibrate.o

obj-y                          += init_task.o

mounts-y			:= do_mounts.o

# dependencies on generated files need to be listed explicitly
$(obj)/version.o: include/generated/compile.h

# compile.h changes depending on hostname, generation number, etc,
# so we regenerate it always.
# mkcompile_h will make sure to only update the
# actual file if its content has changed.

quiet_cmd_compile.h = CHK     $@
      cmd_compile.h = \
	$(CONFIG_SHELL) $(srctree)/scripts/mkcompile_h $@ \
	"$(UTS_MACHINE)" "1" "$(CONFIG_PREEMPT_BUILD)"	\
	"$(CONFIG_PREEMPT_DYNAMIC)" "$(CONFIG_PREEMPT_RT)" \
	"$(CONFIG_CC_VERSION_TEXT)" "$(LD)"

include/generated/compile.h: FORCE
	$(call cmd,compile.h)
