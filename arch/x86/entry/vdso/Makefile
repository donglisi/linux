ARCH_REL_TYPE_ABS := R_X86_64_JUMP_SLOT|R_X86_64_GLOB_DAT|R_X86_64_RELATIVE|
ARCH_REL_TYPE_ABS += R_386_GLOB_DAT|R_386_JMP_SLOT|R_386_RELATIVE
include $(srctree)/lib/vdso/Makefile

vobjs-y := vdso-note.o vclock_gettime.o vgetcpu.o

obj-y				+= vma.o extable.o

vdso_img-y		+= 64

vobjs := $(foreach F,$(vobjs-y),$(obj)/$F)

$(obj)/vdso.o: $(obj)/vdso.so

vdso_img_objs := $(vdso_img-y:%=vdso-image-%.o)
vdso_img_cfiles := $(vdso_img-y:%=vdso-image-%.c)
obj-y += $(vdso_img_objs)

CPPFLAGS_vdso.lds += -P -C

VDSO_LDFLAGS_vdso.lds = -m elf_x86_64 -soname linux-vdso.so.1 --no-undefined -z max-page-size=4096

$(obj)/vdso64.so.dbg: $(obj)/vdso.lds $(vobjs)
	$(Q) $(LD) -o $@ $(VDSO_LDFLAGS) $(VDSO_LDFLAGS_$(filter %.lds,$(^F))) -T $(filter %.lds,$^) \
		$(filter %.o,$^) && sh $(srctree)/$(src)/checkundef.sh '$(NM)' '$@'

HOST_EXTRACFLAGS += -I$(srctree)/tools/include -I$(srctree)/include/uapi -I$(srctree)/arch/$(SUBARCH)/include/uapi
hostprogs += vdso2c

$(obj)/vdso-image-%.c: $(obj)/vdso%.so.dbg $(obj)/vdso%.so $(obj)/vdso2c
	$(Q) $(obj)/vdso2c $< $(<:%.dbg=%) $@

CFL := $(PROFILING) -mcmodel=small -fPIC -O2 -fasynchronous-unwind-tables -m64 \
       $(filter -g%,$(KBUILD_CFLAGS)) -fno-stack-protector \
       -fno-omit-frame-pointer -foptimize-sibling-calls \
       -DDISABLE_BRANCH_PROFILING -DBUILD_VDSO

$(vobjs): KBUILD_CFLAGS := $(filter-out $(CC_FLAGS_LTO) $(RANDSTRUCT_CFLAGS) $(GCC_PLUGINS_CFLAGS), $(KBUILD_CFLAGS)) $(CFL)

CFLAGS_REMOVE_vclock_gettime.o = -pg
CFLAGS_REMOVE_vgetcpu.o = -pg
CFLAGS_REMOVE_vsgx.o = -pg

$(obj)/%.so: $(obj)/%.so.dbg
	$(Q) $(OBJCOPY) -S --remove-section __ex_table $(OBJCOPYFLAGS_$(@F)) $< $@

VDSO_LDFLAGS = -shared --hash-style=both --build-id=sha1 $(call ld-option, --eh-frame-hdr) -Bsymbolic

$(MODLIB)/vdso:
	$(Q) @mkdir -p $(MODLIB)/vdso
