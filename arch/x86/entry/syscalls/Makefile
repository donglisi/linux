if_changed = @ $(if $(if $(strip $(cmd_$@)),,1), $(cmd_$(1)),@:)

out := arch/x86/include/generated/asm
uapi := arch/x86/include/generated/uapi/asm

$(shell mkdir -p $(out) $(uapi))

syscall32 := $(src)/syscall_32.tbl
syscall64 := $(src)/syscall_64.tbl

syshdr := $(srctree)/scripts/syscallhdr.sh
systbl := $(srctree)/scripts/syscalltbl.sh
offset :=
prefix :=

cmd_syshdr = $(CONFIG_SHELL) $(syshdr) --abis $(abis) --emit-nr \
		$(if $(offset),--offset $(offset)) \
		$(if $(prefix),--prefix $(prefix)) \
		$< $@

cmd_systbl = $(CONFIG_SHELL) $(systbl) --abis $(abis) $< $@

$(uapi)/unistd_32.h: abis := i386
$(uapi)/unistd_32.h: $(syscall32) $(syshdr)
	$(call if_changed,syshdr)

$(out)/unistd_32_ia32.h: abis := i386
$(out)/unistd_32_ia32.h: prefix := ia32_
$(out)/unistd_32_ia32.h: $(syscall32) $(syshdr)
	$(call if_changed,syshdr)

$(uapi)/unistd_x32.h: abis := common,x32
$(uapi)/unistd_x32.h: offset := __X32_SYSCALL_BIT
$(uapi)/unistd_x32.h: $(syscall64) $(syshdr)
	$(call if_changed,syshdr)

$(uapi)/unistd_64.h: abis := common,64
$(uapi)/unistd_64.h: $(syscall64) $(syshdr)
	$(call if_changed,syshdr)

$(out)/unistd_64_x32.h: abis := x32
$(out)/unistd_64_x32.h: prefix := x32_
$(out)/unistd_64_x32.h: $(syscall64) $(syshdr)
	$(call if_changed,syshdr)

$(out)/syscalls_32.h: abis := i386
$(out)/syscalls_32.h: $(syscall32) $(systbl)
	$(call if_changed,systbl)

$(out)/syscalls_64.h: abis := common,64
$(out)/syscalls_64.h: $(syscall64) $(systbl)
	$(call if_changed,systbl)

uapisyshdr-y	+= unistd_32.h unistd_64.h unistd_x32.h
syshdr-y	+= syscalls_32.h unistd_32_ia32.h unistd_64_x32.h syscalls_64.h
uapisyshdr-y	:= $(addprefix $(uapi)/, $(uapisyshdr-y))
syshdr-y	:= $(addprefix $(out)/, $(syshdr-y))

all: $(uapisyshdr-y) $(syshdr-y)
