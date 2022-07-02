targets		:= vmlinux.bin setup.bin setup.elf bzImage
targets		+= fdimage fdimage144 fdimage288 image.iso hdimage
subdir-		:= compressed

setup-y		+= a20.o bioscall.o cmdline.o copy.o cpu.o cpuflags.o cpucheck.o early_serial_console.o edd.o header.o main.o memory.o pm.o pmjump.o printf.o regs.o string.o tty.o video.o video-mode.o version.o video-vga.o video-vesa.o video-bios.o

targets		+= $(setup-y)
hostprogs	:= tools/build
hostprogs	+= mkcpustr

HOST_EXTRACFLAGS += -I$(srctree)/tools/include -D__EXPORTED_HEADERS__

$(obj)/cpu.o: $(obj)/cpustr.h

quiet_cmd_cpustr = CPUSTR  $@
      cmd_cpustr = $(obj)/mkcpustr > $@
$(obj)/cpustr.h: $(obj)/mkcpustr FORCE
	$(call if_changed,cpustr)
targets += cpustr.h

KBUILD_CFLAGS	:= $(REALMODE_CFLAGS) -D_SETUP
KBUILD_AFLAGS	:= $(KBUILD_CFLAGS) -D__ASSEMBLY__
KBUILD_CFLAGS	+= $(call cc-option,-fmacro-prefix-map=$(srctree)/=)
KBUILD_CFLAGS	+= -fno-asynchronous-unwind-tables
KBUILD_CFLAGS	+= -include /a/sources/linux/config.h

$(obj)/bzImage: $(obj)/setup.bin $(obj)/vmlinux.bin $(obj)/tools/build
	$(Q) $(obj)/tools/build $(obj)/setup.bin $(obj)/vmlinux.bin $(obj)/zoffset.h $@

$(obj)/vmlinux.bin: $(obj)/compressed/vmlinux FORCE
	$(OBJCOPY) $(OBJCOPYFLAGS) -O binary -R .note -R .comment -S $< $@

SETUP_OBJS = $(addprefix $(obj)/,$(setup-y))

sed-zoffset := -e 's/^\([0-9a-fA-F]*\) [a-zA-Z] \(startup_32\|startup_64\|efi32_stub_entry\|efi64_stub_entry\|efi_pe_entry\|efi32_pe_entry\|input_data\|kernel_info\|_end\|_ehead\|_text\|z_.*\)$$/\#define ZO_\2 0x\1/p'

quiet_cmd_zoffset = ZOFFSET $@
      cmd_zoffset = $(NM) $< | sed -n $(sed-zoffset) > $@

targets += zoffset.h
$(obj)/zoffset.h: $(obj)/compressed/vmlinux FORCE
	$(call if_changed,zoffset)


AFLAGS_header.o += -I$(objtree)/$(obj)
$(obj)/header.o: $(obj)/zoffset.h

quiet_cmd_ld = LD      $@
	cmd_ld = $(LD) $(ld_flags) $(real-prereqs) -o $@

LDFLAGS_setup.elf	:= -m elf_i386 -T
$(obj)/setup.elf: $(src)/setup.ld $(SETUP_OBJS) FORCE
	$(call if_changed,ld)

$(obj)/setup.bin: $(obj)/setup.elf FORCE
	$(OBJCOPY) $(OBJCOPYFLAGS) -O binary $< $@

$(obj)/compressed/vmlinux: FORCE
	$(Q)$(MAKE) $(build)=$(obj)/compressed $@

FDARGS =
FDINITRD =

imgdeps = $(obj)/bzImage $(obj)/mtools.conf $(src)/genimage.sh

$(obj)/mtools.conf: $(src)/mtools.conf.in
	sed -e 's|@OBJ@|$(obj)|g' < $< > $@

targets += mtools.conf

quiet_cmd_genimage = GENIMAGE $3
cmd_genimage = $(BASH) $(srctree)/$(src)/genimage.sh $2 $3 $(obj)/bzImage \
		$(obj)/mtools.conf '$(FDARGS)' $(FDINITRD)

