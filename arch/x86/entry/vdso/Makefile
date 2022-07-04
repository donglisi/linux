ARCH_REL_TYPE_ABS := R_X86_64_JUMP_SLOT|R_X86_64_GLOB_DAT|R_X86_64_RELATIVE|
ARCH_REL_TYPE_ABS += R_386_GLOB_DAT|R_386_JMP_SLOT|R_386_RELATIVE

vobjs-y := vdso-note.o vclock_gettime.o vgetcpu.o

obj-y += vma.o extable.o vdso-image-64.o

vobjs := $(foreach F,$(vobjs-y),$(obj)/$F)

CPPFLAGS_vdso.lds += -P -C

VDSO_LDFLAGS_vdso.lds = -m elf_x86_64 -soname linux-vdso.so.1 --no-undefined -z max-page-size=4096

$(obj)/vdso64.so.dbg: $(obj)/vdso.lds $(vobjs)
	$(Q) $(LD) -o $@ -shared --hash-style=both --build-id=sha1 -Bsymbolic $(VDSO_LDFLAGS_$(filter %.lds,$(^F))) -T $(filter %.lds,$^) \
		$(filter %.o,$^) && sh $(srctree)/$(src)/checkundef.sh '$(NM)' '$@'

HOST_EXTRACFLAGS += -I$(srctree)/tools/include 
hostprogs += vdso2c

$(obj)/vdso-image-64.c: $(obj)/vdso64.so.dbg $(obj)/vdso64.so $(obj)/vdso2c
	$(Q) $(obj)/vdso2c $< $(<:64.dbg=64) $@

CFL := $(PROFILING) -mcmodel=small -fPIC -O2 -fasynchronous-unwind-tables -m64 \
       $(filter -g%,$(KBUILD_CFLAGS)) -fno-stack-protector \
       -fno-omit-frame-pointer -foptimize-sibling-calls \
       -DDISABLE_BRANCH_PROFILING -DBUILD_VDSO

$(vobjs): KBUILD_CFLAGS := $(KBUILD_CFLAGS) $(CFL)

$(obj)/%.so: $(obj)/%.so.dbg
	$(Q) $(OBJCOPY) -S --remove-section __ex_table $< $@
