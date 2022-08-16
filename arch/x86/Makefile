obj-y += $(addprefix entry/, entry_64.o thunk_64.o syscall_64.o common.o vdso/) \
	$(addprefix events/, core.o probe.o msr.o) \
	$(addprefix realmode/, init.o rmpiggy.o) kernel/ mm/ pci/


$(obj)/realmode/rmpiggy.o: $(obj)/realmode/rm/realmode.bin

$(obj)/realmode/rm/realmode.bin:
	$(Q) $(MAKE) -f $(srctree)/scripts/Makefile.build obj=$(obj)/realmode/rm $@

