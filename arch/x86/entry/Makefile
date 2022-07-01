CFLAGS_REMOVE_common.o		= $(CC_FLAGS_FTRACE)

CFLAGS_common.o			+= -fno-stack-protector

obj-y				:= entry_64.o thunk_64.o syscall_64.o
obj-y				+= common.o

obj-y				+= vdso/
obj-y				+= vsyscall/

