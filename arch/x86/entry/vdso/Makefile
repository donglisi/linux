vobjs-y := vdso-note.o vclock_gettime.o vgetcpu.o

obj-y += vma.o extable.o vdso-image-64.o

vobjs := $(foreach F,$(vobjs-y),$(obj)/$F)

$(obj)/vdso64.so.dbg: $(obj)/vdso.lds $(vobjs)
	$(Q) $(LD) -o $@ -shared --hash-style=both -Bsymbolic -m elf_x86_64 \
		-soname linux-vdso.so.1 --no-undefined -z max-page-size=4096 -T $^

hostprogs := vdso2c

$(obj)/vdso-image-64.c: $(obj)/vdso64.so.dbg $(obj)/vdso64.so $(obj)/vdso2c
	$(Q) $(obj)/vdso2c $< $(<:64.dbg=64) $@

$(vobjs): KBUILD_CFLAGS := $(KBUILD_CFLAGS) -mcmodel=small -fPIC -O2 -fasynchronous-unwind-tables -m64 $(filter -g%,$(KBUILD_CFLAGS)) \
	-fno-stack-protector -fno-omit-frame-pointer -foptimize-sibling-calls -DDISABLE_BRANCH_PROFILING -DBUILD_VDSO

$(obj)/%.so: $(obj)/%.so.dbg
	$(Q) $(OBJCOPY) -S --remove-section __ex_table $< $@
