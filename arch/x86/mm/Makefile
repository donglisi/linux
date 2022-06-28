KCOV_INSTRUMENT_tlb.o			:= n
KCOV_INSTRUMENT_mem_encrypt.o		:= n
KCOV_INSTRUMENT_mem_encrypt_amd.o	:= n
KCOV_INSTRUMENT_mem_encrypt_identity.o	:= n

KASAN_SANITIZE_mem_encrypt.o		:= n
KASAN_SANITIZE_mem_encrypt_amd.o	:= n
KASAN_SANITIZE_mem_encrypt_identity.o	:= n

KCSAN_SANITIZE := n

obj-y				:=  init.o init_$(BITS).o fault.o ioremap.o extable.o mmap.o \
				    pgtable.o physaddr.o tlb.o cpu_entry_area.o maccess.o pgprot.o

obj-y				+= pat/

CFLAGS_physaddr.o		:= -fno-stack-protector
CFLAGS_mem_encrypt_identity.o	:= -fno-stack-protector

CFLAGS_fault.o := -I $(srctree)/$(src)/../include/asm/trace

KASAN_SANITIZE_kasan_init_$(BITS).o := n
mmiotrace-y			:= kmmio.o pf_in.o mmio-mod.o
