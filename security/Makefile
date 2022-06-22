# SPDX-License-Identifier: GPL-2.0
#
# Makefile for the kernel security code
#
# always enable default capabilities
obj-y					+= commoncap.o
obj-$(CONFIG_MMU)			+= min_addr.o

# Object file lists
obj-$(CONFIG_SECURITY)			+= security.o
obj-$(CONFIG_SECURITYFS)		+= inode.o
obj-$(CONFIG_SECURITY)			+= lsm_audit.o
obj-$(CONFIG_CGROUPS)			+= device_cgroup.o
