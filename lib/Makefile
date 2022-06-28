KCOV_INSTRUMENT_string.o := n
KCOV_INSTRUMENT_rbtree.o := n
KCOV_INSTRUMENT_list_debug.o := n
KCOV_INSTRUMENT_debugobjects.o := n
KCOV_INSTRUMENT_dynamic_debug.o := n
KCOV_INSTRUMENT_fault-inject.o := n

# string.o implements standard library functions like memset/memcpy etc.
# Use -ffreestanding to ensure that the compiler does not try to "optimize"
# them into calls to themselves.
CFLAGS_string.o := -ffreestanding


lib-y := ctype.o string.o vsprintf.o cmdline.o \
	 rbtree.o radix-tree.o timerqueue.o xarray.o \
	 idr.o extable.o sha1.o irq_regs.o argv_split.o \
	 flex_proportions.o ratelimit.o show_mem.o \
	 is_single_threaded.o plist.o decompress.o kobject_uevent.o \
	 earlycpio.o seq_buf.o siphash.o dec_and_lock.o \
	 nmi_backtrace.o nodemask.o win_minmax.o memcat_p.o \
	 buildid.o

lib-y += dump_stack.o
lib-y += cpumask.o

lib-y	+= kobject.o klist.o
obj-y	+= lockref.o

obj-y += bcd.o sort.o parser.o debug_locks.o random32.o \
	 bust_spinlocks.o kasprintf.o bitmap.o scatterlist.o \
	 list_sort.o uuid.o iov_iter.o clz_ctz.o \
	 bsearch.o find_bit.o llist.o memweight.o kfifo.o \
	 percpu-refcount.o rhashtable.o \
	 once.o refcount.o usercopy.o errseq.o bucket_locks.o \
	 generic-radix-tree.o
obj-y += string_helpers.o
obj-y += hexdump.o
obj-y += kstrtox.o
CFLAGS_test_bitops.o += -Werror
CFLAGS_test_kasan.o += -fno-builtin
CFLAGS_test_kasan.o += $(call cc-disable-warning, vla)
CFLAGS_test_kasan_module.o += -fno-builtin
CFLAGS_test_ubsan.o += $(call cc-disable-warning, vla)
UBSAN_SANITIZE_test_ubsan.o := y
CFLAGS_test_fprobe.o += $(CC_FLAGS_FTRACE)
#
# CFLAGS for compiling floating point code inside the kernel. x86/Makefile turns
# off the generation of FPU/SSE* instructions for kernel proper but FPU_FLAGS
# get appended last to CFLAGS and thus override those previous compiler options.
#
FPU_CFLAGS := -msse -msse2
# Stack alignment mismatch, proceed with caution.
# GCC < 7.1 cannot compile code using `double` and -mpreferred-stack-boundary=3
# (8B stack alignment).
# See https://gcc.gnu.org/bugzilla/show_bug.cgi?id=53383
#
# The "-msse" in the first argument is there so that the
# -mpreferred-stack-boundary=3 build error:
#
#  -mpreferred-stack-boundary=3 is not between 4 and 12
#
# can be triggered. Otherwise gcc doesn't complain.
FPU_CFLAGS += -mhard-float
FPU_CFLAGS += $(call cc-option,-msse -mpreferred-stack-boundary=3,-mpreferred-stack-boundary=4)

CFLAGS_test_fpu.o += $(FPU_CFLAGS)




CFLAGS_debug_info.o += $(call cc-option, -femit-struct-debug-detailed=any)

obj-y += math/ crypto/

obj-y += iomap.o
obj-y += pci_iomap.o
obj-y += iomap_copy.o devres.o

lib-y += logic_pio.o

obj-y += bitrev.o
obj-y	+= crc16.o
obj-y	+= crc32.o
obj-y += percpu_counter.o

lib-y += bug.o

obj-y += syscall.o

obj-y += nlattr.o

obj-y += cpu_rmap.o

obj-y += dynamic_queue_limits.o

obj-y += strncpy_from_user.o
obj-y += strnlen_user.o

obj-y += net_utils.o

obj-y += sg_pool.o
CFLAGS_stackdepot.o += -fno-builtin
KASAN_SANITIZE_stackdepot.o := n
KCOV_INSTRUMENT_stackdepot.o := n

libfdt_files = fdt.o fdt_ro.o fdt_wip.o fdt_rw.o fdt_sw.o fdt_strerror.o \
	       fdt_empty_tree.o fdt_addresses.o
$(foreach file, $(libfdt_files), \
	$(eval CFLAGS_$(file) = -I $(srctree)/scripts/dtc/libfdt))

$(obj)/bootconfig-data.o: $(obj)/default.bconf

targets += default.bconf
filechk_defbconf = cat $(or $(real-prereqs), /dev/null)
$(obj)/default.bconf: $(CONFIG_BOOT_CONFIG_EMBED_FILE) FORCE
	$(call filechk,defbconf)

hostprogs	:= gen_crc32table
hostprogs	+= gen_crc64table
clean-files	:= crc32table.h
clean-files	+= crc64table.h

$(obj)/crc32.o: $(obj)/crc32table.h

quiet_cmd_crc32 = GEN     $@
      cmd_crc32 = $< > $@

$(obj)/crc32table.h: $(obj)/gen_crc32table
	$(call cmd,crc32)

$(obj)/crc64.o: $(obj)/crc64table.h

quiet_cmd_crc64 = GEN     $@
      cmd_crc64 = $< > $@

$(obj)/crc64table.h: $(obj)/gen_crc64table
	$(call cmd,crc64)

$(obj)/oid_registry.o: $(obj)/oid_registry_data.c

$(obj)/oid_registry_data.c: $(srctree)/include/linux/oid_registry.h \
			    $(src)/build_OID_registry
	$(call cmd,build_OID_registry)

quiet_cmd_build_OID_registry = GEN     $@
      cmd_build_OID_registry = perl $(srctree)/$(src)/build_OID_registry $< $@

clean-files	+= oid_registry_data.c

UBSAN_SANITIZE_ubsan.o := n
KASAN_SANITIZE_ubsan.o := n
KCSAN_SANITIZE_ubsan.o := n
CFLAGS_ubsan.o := -fno-stack-protector $(DISABLE_STACKLEAK_PLUGIN)

obj-y += sbitmap.o

CFLAGS_bitfield_kunit.o := $(DISABLE_STRUCTLEAK_PLUGIN)
CFLAGS_stackinit_kunit.o += $(call cc-disable-warning, switch-unreachable)
TEST_FORTIFY_SRCS = $(wildcard $(srctree)/$(src)/test_fortify/*-*.c)
TEST_FORTIFY_LOGS = $(patsubst $(srctree)/$(src)/%.c, %.log, $(TEST_FORTIFY_SRCS))
TEST_FORTIFY_LOG = test_fortify.log

quiet_cmd_test_fortify = TEST    $@
      cmd_test_fortify = $(CONFIG_SHELL) $(srctree)/scripts/test_fortify.sh \
			$< $@ "$(NM)" $(CC) $(c_flags) \
			$(call cc-disable-warning,fortify-source) \
			-DKBUILD_EXTRA_WARN1

targets += $(TEST_FORTIFY_LOGS)
clean-files += $(TEST_FORTIFY_LOGS)
clean-files += $(addsuffix .o, $(TEST_FORTIFY_LOGS))
$(obj)/test_fortify/%.log: $(src)/test_fortify/%.c \
			   $(src)/test_fortify/test_fortify.h \
			   $(srctree)/include/linux/fortify-string.h \
			   $(srctree)/scripts/test_fortify.sh \
			   FORCE
	$(call if_changed,test_fortify)

quiet_cmd_gen_fortify_log = GEN     $@
      cmd_gen_fortify_log = cat </dev/null $(filter-out FORCE,$^) 2>/dev/null > $@ || true

targets += $(TEST_FORTIFY_LOG)
clean-files += $(TEST_FORTIFY_LOG)
$(obj)/$(TEST_FORTIFY_LOG): $(addprefix $(obj)/, $(TEST_FORTIFY_LOGS)) FORCE
	$(call if_changed,gen_fortify_log)
