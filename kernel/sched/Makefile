ccflags-y += $(call cc-disable-warning, unused-but-set-variable)
KCOV_INSTRUMENT := n
KCSAN_SANITIZE := n
KCSAN_INSTRUMENT_BARRIERS := y

CFLAGS_core.o := $(PROFILING) -fno-omit-frame-pointer

obj-y += core.o
obj-y += fair.o
obj-y += build_policy.o
obj-y += build_utility.o
