bounds-file := include/generated/bounds.h

always-y := $(bounds-file)
targets := kernel/bounds.s

$(bounds-file): kernel/bounds.s
	$(call filechk,offsets,__LINUX_BOUNDS_H__)

timeconst-file := include/generated/timeconst.h

filechk_gentimeconst = echo 1000 | bc -q $<

$(timeconst-file): kernel/time/timeconst.bc
	$(call filechk,gentimeconst)

offsets-file := include/generated/asm-offsets.h

always-y += $(offsets-file)
targets += arch/x86/kernel/asm-offsets.s

arch/x86/kernel/asm-offsets.s: $(timeconst-file) $(bounds-file)

$(offsets-file): arch/x86/kernel/asm-offsets.s
	$(call filechk,offsets,__ASM_OFFSETS_H__)
