# SPDX-License-Identifier: GPL-2.0
#
# Makefile for the linux networking.
#
# 2 Sep 2000, Christoph Hellwig <hch@infradead.org>
# Rewritten to use lists instead of if-statements.
#

obj-y				:= devres.o socket.o core/

obj-$(CONFIG_COMPAT)		+= compat.o

# LLC has to be linked before the files in net/802/
obj-y				+= ethernet/ sched/ netlink/ ethtool/
obj-$(CONFIG_INET)		+= ipv4/
obj-$(CONFIG_UNIX_SCM)		+= unix/
obj-y				+= ipv6/
obj-$(CONFIG_SYSCTL)		+= sysctl_net.o
