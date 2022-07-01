$(obj)/inat-tables.c:
	$(AWK) -f $(srctree)/arch/x86/tools/gen-insn-attr-x86.awk $(srctree)/arch/x86/lib/x86-opcode-map.txt > $@

$(obj)/inat.o: $(obj)/inat-tables.c

clean-files := inat-tables.c

obj-y += msr-smp.o cache-smp.o

lib-y := delay.o misc.o cmdline.o cpu.o
lib-y += usercopy_$(BITS).o usercopy.o getuser.o putuser.o
lib-y += memcpy_$(BITS).o
lib-y += pc-conf-reg.o
lib-y += copy_mc.o copy_mc_64.o
lib-y += insn.o inat.o insn-eval.o

obj-y += msr.o msr-reg.o msr-reg-export.o hweight.o
obj-y += iomem.o

obj-y += iomap_copy_64.o
lib-y += csum-partial_64.o csum-copy_64.o csum-wrappers_64.o
lib-y += clear_page_64.o copy_page_64.o
lib-y += memmove_64.o memset_64.o
lib-y += copy_user_64.o
lib-y += cmpxchg16b_emu.o
