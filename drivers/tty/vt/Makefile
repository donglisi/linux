obj-y += vt_ioctl.o vc_screen.o selection.o keyboard.o consolemap.o consolemap_deftbl.o vt.o defkeymap.o

hostprogs += conmakehash
$(obj)/consolemap_deftbl.c: $(src)/cp437.uni $(obj)/conmakehash
	$(Q) $(obj)/conmakehash $< > $@
