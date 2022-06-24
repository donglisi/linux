KCOV_INSTRUMENT := n

ifeq ($(CONFIG_KCSAN),y)
KBUILD_CFLAGS += -g -fno-omit-frame-pointer
endif

obj-y += update.o sync.o
obj-y += srcutree.o
obj-$(CONFIG_TINY_SRCU) += srcutiny.o
obj-$(CONFIG_RCU_TORTURE_TEST) += rcutorture.o
obj-$(CONFIG_RCU_SCALE_TEST) += rcuscale.o
obj-$(CONFIG_RCU_REF_SCALE_TEST) += refscale.o
obj-y += tree.o
obj-$(CONFIG_TINY_RCU) += tiny.o
obj-y += rcu_segcblist.o
