ARCH_REL_TYPE_ABS := R_X86_64_JUMP_SLOT|R_X86_64_GLOB_DAT|R_X86_64_RELATIVE|
ARCH_REL_TYPE_ABS += R_386_GLOB_DAT|R_386_JMP_SLOT|R_386_RELATIVE
include $(srctree)/lib/vdso/Makefile

# files to link into the vdso
vobjs-y := vdso-note.o vclock_gettime.o vgetcpu.o

obj-y				+= vma.o extable.o

vdso_img-y		+= 64

vobjs := $(foreach F,$(vobjs-y),$(obj)/$F)

$(obj)/vdso.o: $(obj)/vdso.so

targets += vdso.lds $(vobjs-y)

vdso_img_objs := $(vdso_img-y:%=vdso-image-%.o)
vdso_img_cfiles := $(vdso_img-y:%=vdso-image-%.c)
vdso_img_sodbg := $(vdso_img-y:%=vdso%.so.dbg)
obj-y += $(vdso_img_objs)
targets += $(vdso_img_cfiles)
targets += $(vdso_img_sodbg) $(vdso_img-y:%=vdso%.so)

CPPFLAGS_vdso.lds += -P -C

VDSO_LDFLAGS_vdso.lds = -m elf_x86_64 -soname linux-vdso.so.1 --no-undefined -z max-page-size=4096

$(obj)/vdso64.so.dbg: $(obj)/vdso.lds $(vobjs) FORCE
	$(call if_changed,vdso_and_check)

HOST_EXTRACFLAGS += -I$(srctree)/tools/include -I$(srctree)/include/uapi -I$(srctree)/arch/$(SUBARCH)/include/uapi
hostprogs += vdso2c

quiet_cmd_vdso2c = VDSO2C  $@
      cmd_vdso2c = $(obj)/vdso2c $< $(<:%.dbg=%) $@

$(obj)/vdso-image-%.c: $(obj)/vdso%.so.dbg $(obj)/vdso%.so $(obj)/vdso2c FORCE
	$(call if_changed,vdso2c)

CFL := $(PROFILING) -mcmodel=small -fPIC -O2 -fasynchronous-unwind-tables -m64 \
       $(filter -g%,$(KBUILD_CFLAGS)) -fno-stack-protector \
       -fno-omit-frame-pointer -foptimize-sibling-calls \
       -DDISABLE_BRANCH_PROFILING -DBUILD_VDSO

$(vobjs): KBUILD_CFLAGS := $(filter-out $(CC_FLAGS_LTO) $(RANDSTRUCT_CFLAGS) $(GCC_PLUGINS_CFLAGS), $(KBUILD_CFLAGS)) $(CFL)

CFLAGS_REMOVE_vclock_gettime.o = -pg
CFLAGS_REMOVE_vgetcpu.o = -pg
CFLAGS_REMOVE_vsgx.o = -pg

$(obj)/%.so: OBJCOPYFLAGS := -S --remove-section __ex_table
$(obj)/%.so: $(obj)/%.so.dbg FORCE
	$(call if_changed,objcopy)

quiet_cmd_vdso = VDSO    $@
      cmd_vdso = $(LD) -o $@ \
		       $(VDSO_LDFLAGS) $(VDSO_LDFLAGS_$(filter %.lds,$(^F))) \
		       -T $(filter %.lds,$^) $(filter %.o,$^) && \
		 sh $(srctree)/$(src)/checkundef.sh '$(NM)' '$@'

VDSO_LDFLAGS = -shared --hash-style=both --build-id=sha1 \
	$(call ld-option, --eh-frame-hdr) -Bsymbolic
GCOV_PROFILE := n

quiet_cmd_vdso_and_check = VDSO    $@
      cmd_vdso_and_check = $(cmd_vdso); $(cmd_vdso_check)

vdso_img_insttargets := $(vdso_img_sodbg:%.dbg=install_%)

$(MODLIB)/vdso: FORCE
	@mkdir -p $(MODLIB)/vdso

$(vdso_img_insttargets): install_%: $(obj)/%.dbg $(MODLIB)/vdso
	$(call cmd,vdso_install)
