$(obj)/inat-tables.c:
	$(Q) $(AWK) -f $(srctree)/arch/x86/tools/gen-insn-attr-x86.awk $(srctree)/arch/x86/lib/x86-opcode-map.txt > $@

$(obj)/inat.o: $(obj)/inat-tables.c

obj-y := msr-smp.o cache-smp.o msr.o msr-reg.o msr-reg-export.o hweight.o iomem.o iomap_copy_64.o

lib-y := delay.o misc.o cmdline.o cpu.o usercopy_64.o usercopy.o getuser.o putuser.o memcpy_64.o pc-conf-reg.o copy_mc.o copy_mc_64.o insn.o inat.o insn-eval.o csum-partial_64.o csum-copy_64.o csum-wrappers_64.o clear_page_64.o copy_page_64.o memmove_64.o memset_64.o copy_user_64.o cmpxchg16b_emu.o
