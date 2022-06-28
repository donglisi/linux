obj-y := core.o
CFLAGS_core.o += $(call cc-disable-warning, override-init) $(cflags-nogcse-yy)
$(obj)/relo_core.o: $(srctree)/tools/lib/bpf/relo_core.c FORCE
	$(call if_changed_rule,cc_o_c)
