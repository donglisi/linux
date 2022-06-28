# SPDX-License-Identifier: GPL-2.0-only
obj-y	= printk.o
obj-y	+= printk_safe.o
obj-$(CONFIG_A11Y_BRAILLE_CONSOLE)	+= braille.o
obj-$(CONFIG_PRINTK_INDEX)	+= index.o

obj-y                 += printk_support.o
printk_support-y	             := printk_ringbuffer.o
printk_support-y	     += sysctl.o
