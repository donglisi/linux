newer-prereqs = $(filter-out $(PHONY),$?)

check-FORCE = $(if $(filter FORCE, $^),,$(warning FORCE prerequisite is missing))

if-changed-cond = $(newer-prereqs)$(cmd-check)$(check-FORCE)

if_changed = $(if $(if-changed-cond),$(cmd_and_savecmd),@:)

out := arch/x86/include/generated/asm
uapi := arch/x86/include/generated/uapi/asm

echo-cmd = $(if $($(quiet)cmd_$(1)),\
	echo '  $(call escsq,$($(quiet)cmd_$(1)))$(echo-why)';)

cmd = @set -e; $(echo-cmd) $($(quiet)redirect) $(cmd_$(1))

cmd-check = $(if $(strip $(cmd_$@)),,1)

make-cmd = $(call escsq,$(subst $(pound),$$(pound),$(subst $$,$$$$,$(cmd_$(1)))))

cmd_and_savecmd =                                                            \
	$(cmd);                                                              \
	printf '%s\n' 'cmd_$@ := $(make-cmd)' > $(dot-target).cmd

# Create output directory if not already present
$(shell mkdir -p $(out) $(uapi))

syscall32 := $(src)/syscall_32.tbl
syscall64 := $(src)/syscall_64.tbl

syshdr := $(srctree)/scripts/syscallhdr.sh
systbl := $(srctree)/scripts/syscalltbl.sh
offset :=
prefix :=

quiet_cmd_syshdr = SYSHDR  $@
      cmd_syshdr = $(CONFIG_SHELL) $(syshdr) --abis $(abis) --emit-nr \
		$(if $(offset),--offset $(offset)) \
		$(if $(prefix),--prefix $(prefix)) \
		$< $@
quiet_cmd_systbl = SYSTBL  $@
      cmd_systbl = $(CONFIG_SHELL) $(systbl) --abis $(abis) $< $@

quiet_cmd_hypercalls = HYPERCALLS $@
      cmd_hypercalls = $(CONFIG_SHELL) '$<' $@ $(filter-out $<, $(real-prereqs))

$(uapi)/unistd_32.h: abis := i386
$(uapi)/unistd_32.h: $(syscall32) $(syshdr) FORCE
	$(call if_changed,syshdr)

$(out)/unistd_32_ia32.h: abis := i386
$(out)/unistd_32_ia32.h: prefix := ia32_
$(out)/unistd_32_ia32.h: $(syscall32) $(syshdr) FORCE
	$(call if_changed,syshdr)

$(uapi)/unistd_x32.h: abis := common,x32
$(uapi)/unistd_x32.h: offset := __X32_SYSCALL_BIT
$(uapi)/unistd_x32.h: $(syscall64) $(syshdr) FORCE
	$(call if_changed,syshdr)

$(uapi)/unistd_64.h: abis := common,64
$(uapi)/unistd_64.h: $(syscall64) $(syshdr) FORCE
	$(call if_changed,syshdr)

$(out)/unistd_64_x32.h: abis := x32
$(out)/unistd_64_x32.h: prefix := x32_
$(out)/unistd_64_x32.h: $(syscall64) $(syshdr) FORCE
	$(call if_changed,syshdr)

$(out)/syscalls_32.h: abis := i386
$(out)/syscalls_32.h: $(syscall32) $(systbl) FORCE
	$(call if_changed,systbl)
$(out)/syscalls_64.h: abis := common,64
$(out)/syscalls_64.h: $(syscall64) $(systbl) FORCE
	$(call if_changed,systbl)
$(out)/syscalls_x32.h: abis := common,x32
$(out)/syscalls_x32.h: $(syscall64) $(systbl) FORCE
	$(call if_changed,systbl)

$(out)/xen-hypercalls.h: $(srctree)/scripts/xen-hypercalls.sh FORCE
	$(call if_changed,hypercalls)

$(out)/xen-hypercalls.h: $(srctree)/include/xen/interface/xen*.h

uapisyshdr-y			+= unistd_32.h unistd_64.h unistd_x32.h
syshdr-y			+= syscalls_32.h
syshdr-y		+= unistd_32_ia32.h unistd_64_x32.h
syshdr-y	+= syscalls_64.h

uapisyshdr-y	:= $(addprefix $(uapi)/, $(uapisyshdr-y))
syshdr-y	:= $(addprefix $(out)/, $(syshdr-y))
targets		+= $(addprefix ../../../../, $(uapisyshdr-y) $(syshdr-y))

PHONY += all
all: $(uapisyshdr-y) $(syshdr-y)
	$(Q)
