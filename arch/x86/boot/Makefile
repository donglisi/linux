setup-y += a20.o bioscall.o cmdline.o copy.o cpu.o cpuflags.o cpucheck.o early_serial_console.o edd.o header.o main.o memory.o pm.o pmjump.o printf.o regs.o string.o tty.o video.o video-mode.o version.o video-vga.o video-vesa.o video-bios.o
SETUP_OBJS = $(addprefix $(obj)/,$(setup-y))

hostprogs	:= tools/build mkcpustr

$(obj)/cpu.o: $(obj)/cpustr.h

$(obj)/cpustr.h: $(obj)/mkcpustr
	$(Q) $(obj)/mkcpustr > $@

KBUILD_CFLAGS	:= $(REALMODE_CFLAGS) -D_SETUP
KBUILD_CFLAGS	+= -fmacro-prefix-map=$(srctree)/=
KBUILD_CFLAGS	+= -fno-asynchronous-unwind-tables
KBUILD_CFLAGS	+= -include $(srctree)/config.h

$(obj)/bzImage: $(obj)/setup.bin $(obj)/vmlinux.bin $(obj)/tools/build
	$(Q) $(obj)/tools/build $(obj)/setup.bin $(obj)/vmlinux.bin $(obj)/zoffset.h $@

$(obj)/vmlinux.bin: $(obj)/compressed/vmlinux
	$(Q) $(OBJCOPY) -O binary -R .note -R .comment -S $< $@

$(obj)/zoffset.h: $(obj)/compressed/vmlinux
	$(Q) $(NM) $< | sed -n -e 's/^\([0-9a-fA-F]*\) [a-zA-Z] \(startup_32\|startup_64\|efi32_stub_entry\|efi64_stub_entry\|efi_pe_entry\|efi32_pe_entry\|input_data\|kernel_info\|_end\|_ehead\|_text\|z_.*\)$$/\#define ZO_\2 0x\1/p' > $@

$(obj)/header.o: $(obj)/zoffset.h

$(obj)/setup.elf: $(src)/setup.ld $(SETUP_OBJS)
	$(Q) $(LD) -m elf_i386 -T $^ -o $@

$(obj)/setup.bin: $(obj)/setup.elf
	$(Q) $(OBJCOPY) -O binary $< $@

$(obj)/compressed/vmlinux:
	$(Q) $(MAKE) -f $(srctree)/scripts/Makefile.build obj=$(obj)/compressed $@
