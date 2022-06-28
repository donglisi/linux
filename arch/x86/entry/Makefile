KASAN_SANITIZE := n
UBSAN_SANITIZE := n
KCOV_INSTRUMENT := n

CFLAGS_REMOVE_common.o		= $(CC_FLAGS_FTRACE)

CFLAGS_common.o			+= -fno-stack-protector

obj-y				:= entry_$(BITS).o thunk_$(BITS).o syscall_$(BITS).o
obj-y				+= common.o

obj-y				+= vdso/
obj-y				+= vsyscall/

