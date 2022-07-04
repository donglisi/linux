obj-y += init.o rmpiggy.o

$(obj)/rmpiggy.o: $(obj)/rm/realmode.bin

$(obj)/rm/realmode.bin:
	$(Q) $(MAKE) -f $(srctree)/scripts/Makefile.build obj=$(obj)/rm $@
