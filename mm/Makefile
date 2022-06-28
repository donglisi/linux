KASAN_SANITIZE_slab_common.o := n
KASAN_SANITIZE_slab.o := n
KASAN_SANITIZE_slub.o := n
KCSAN_SANITIZE_kmemleak.o := n

KCSAN_SANITIZE_slab_common.o := n
KCSAN_SANITIZE_slab.o := n
KCSAN_SANITIZE_slub.o := n
KCSAN_SANITIZE_page_alloc.o := n
KCSAN_INSTRUMENT_BARRIERS := y

KCOV_INSTRUMENT_slab_common.o := n
KCOV_INSTRUMENT_slob.o := n
KCOV_INSTRUMENT_slab.o := n
KCOV_INSTRUMENT_slub.o := n
KCOV_INSTRUMENT_page_alloc.o := n
KCOV_INSTRUMENT_debug-pagealloc.o := n
KCOV_INSTRUMENT_kmemleak.o := n
KCOV_INSTRUMENT_memcontrol.o := n
KCOV_INSTRUMENT_mmzone.o := n
KCOV_INSTRUMENT_vmstat.o := n
KCOV_INSTRUMENT_failslab.o := n

CFLAGS_init-mm.o += $(call cc-disable-warning, override-init)
CFLAGS_init-mm.o += $(call cc-disable-warning, initializer-overrides)

mmu-y	:= highmem.o memory.o mincore.o \
			   mlock.o mmap.o mmu_gather.o mprotect.o mremap.o \
			   msync.o page_vma_mapped.o pagewalk.o \
			   pgtable-generic.o rmap.o vmalloc.o
obj-y			:= filemap.o mempool.o oom_kill.o fadvise.o \
			   maccess.o page-writeback.o folio-compat.o \
			   readahead.o swap.o truncate.o vmscan.o shmem.o \
			   util.o mmzone.o vmstat.o backing-dev.o \
			   mm_init.o percpu.o slab_common.o \
			   compaction.o vmacache.o \
			   interval_tree.o list_lru.o workingset.o \
			   debug.o gup.o mmap_lock.o $(mmu-y)

page-alloc-y := page_alloc.o
obj-y += page-alloc.o
obj-y += init-mm.o
obj-y += memblock.o
	obj-y	+= madvise.o
obj-y	+= dmapool.o
obj-y	+= sparse.o
obj-y += slub.o
obj-y += early_ioremap.o
obj-y += secretmem.o
