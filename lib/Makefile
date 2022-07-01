lib-y := ctype.o string.o vsprintf.o cmdline.o rbtree.o radix-tree.o timerqueue.o xarray.o idr.o extable.o sha1.o irq_regs.o argv_split.o flex_proportions.o ratelimit.o show_mem.o is_single_threaded.o plist.o decompress.o kobject_uevent.o earlycpio.o seq_buf.o siphash.o dec_and_lock.o nmi_backtrace.o nodemask.o win_minmax.o memcat_p.o buildid.o dump_stack.o cpumask.o kobject.o klist.o logic_pio.o bug.o

obj-y := bcd.o sort.o parser.o debug_locks.o random32.o bust_spinlocks.o kasprintf.o bitmap.o scatterlist.o list_sort.o uuid.o iov_iter.o clz_ctz.o bsearch.o find_bit.o llist.o memweight.o kfifo.o percpu-refcount.o rhashtable.o once.o refcount.o usercopy.o errseq.o bucket_locks.o generic-radix-tree.o lockref.o sbitmap.o string_helpers.o hexdump.o kstrtox.o math/ crypto/ iomap.o pci_iomap.o iomap_copy.o devres.o bitrev.o crc16.o crc32.o percpu_counter.o syscall.o nlattr.o cpu_rmap.o dynamic_queue_limits.o strncpy_from_user.o strnlen_user.o net_utils.o sg_pool.o

hostprogs := gen_crc32table gen_crc64table

$(obj)/crc32.o: $(obj)/crc32table.h
$(obj)/crc32table.h: $(obj)/gen_crc32table
	$< > $@

$(obj)/crc64.o: $(obj)/crc64table.h

$(obj)/crc64table.h: $(obj)/gen_crc64table
	$< > $@
