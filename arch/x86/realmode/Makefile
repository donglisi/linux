subdir- := rm

obj-y += init.o
obj-y += rmpiggy.o

$(obj)/rmpiggy.o: $(obj)/rm/realmode.bin

$(obj)/rm/realmode.bin:
	$(Q) $(MAKE) $(build)=$(obj)/rm $@
