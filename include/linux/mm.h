/* SPDX-License-Identifier: GPL-2.0 */
#ifndef _LINUX_MM_H
#define _LINUX_MM_H

#include <linux/errno.h>
#include <linux/mmdebug.h>
#include <linux/gfp.h>
#include <linux/bug.h>
#include <linux/list.h>
#include <linux/mmzone.h>
#include <linux/rbtree.h>
#include <linux/atomic.h>
#include <linux/debug_locks.h>
#include <linux/mm_types.h>
#include <linux/mmap_lock.h>
#include <linux/range.h>
#include <linux/pfn.h>
#include <linux/percpu-refcount.h>
#include <linux/bit_spinlock.h>
#include <linux/shrinker.h>
#include <linux/resource.h>
#include <linux/page_ext.h>
#include <linux/err.h>
#include <linux/page-flags.h>
#include <linux/page_ref.h>
#include <linux/overflow.h>
#include <linux/sizes.h>
#include <linux/sched.h>
#include <linux/pgtable.h>
#include <linux/kasan.h>

struct mempolicy;
struct anon_vma;
struct user_struct;
struct pt_regs;

extern atomic_long_t _totalram_pages;
static inline unsigned long totalram_pages(void)
{
	return (unsigned long)atomic_long_read(&_totalram_pages);
}

static inline void totalram_pages_inc(void)
{
	atomic_long_inc(&_totalram_pages);
}

static inline void totalram_pages_dec(void)
{
	atomic_long_dec(&_totalram_pages);
}

static inline void totalram_pages_add(long count)
{
	atomic_long_add(count, &_totalram_pages);
}

#include <asm/page.h>
#include <asm/processor.h>

/*
 * Architectures that support memory tagging (assigning tags to memory regions,
 * embedding these tags into addresses that point to these memory regions, and
 * checking that the memory and the pointer tags match on memory accesses)
 * redefine this macro to strip tags from pointers.
 * It's defined as noop for architectures that don't support memory tagging.
 */
#ifndef untagged_addr
#define untagged_addr(addr) (addr)
#endif

#ifndef page_to_virt
#define page_to_virt(x)	__va(PFN_PHYS(page_to_pfn(x)))
#endif

#ifndef lm_alias
#define lm_alias(x)	__va(__pa_symbol(x))
#endif

/*
 * To prevent common memory management code establishing
 * a zero page mapping on a read fault.
 * This macro should be defined within <asm/pgtable.h>.
 * s390 does this to prevent multiplexing of hardware bits
 * related to the physical page in case of virtualization.
 */
#ifndef mm_forbids_zeropage
#define mm_forbids_zeropage(X)	(0)
#endif

/*
 * On some architectures it is expensive to call memset() for small sizes.
 * If an architecture decides to implement their own version of
 * mm_zero_struct_page they should wrap the defines below in a #ifndef and
 * define their own version of this macro in <asm/pgtable.h>
 */
#if BITS_PER_LONG == 64
/* This function must be updated when the size of struct page grows above 80
 * or reduces below 56. The idea that compiler optimizes out switch()
 * statement, and only leaves move/store instructions. Also the compiler can
 * combine write statements if they are both assignments and can be reordered,
 * this can result in several of the writes here being dropped.
 */
#define	mm_zero_struct_page(pp) __mm_zero_struct_page(pp)
static inline void __mm_zero_struct_page(struct page *page)
{
	unsigned long *_pp = (void *)page;

	 /* Check that struct page is either 56, 64, 72, or 80 bytes */
	BUILD_BUG_ON(sizeof(struct page) & 7);
	BUILD_BUG_ON(sizeof(struct page) < 56);
	BUILD_BUG_ON(sizeof(struct page) > 80);

	switch (sizeof(struct page)) {
	case 80:
		_pp[9] = 0;
		fallthrough;
	case 72:
		_pp[8] = 0;
		fallthrough;
	case 64:
		_pp[7] = 0;
		fallthrough;
	case 56:
		_pp[6] = 0;
		_pp[5] = 0;
		_pp[4] = 0;
		_pp[3] = 0;
		_pp[2] = 0;
		_pp[1] = 0;
		_pp[0] = 0;
	}
}
#else
#define mm_zero_struct_page(pp)  ((void)memset((pp), 0, sizeof(struct page)))
#endif

/*
 * Default maximum number of active map areas, this limits the number of vmas
 * per mm struct. Users can overwrite this number by sysctl but there is a
 * problem.
 *
 * When a program's coredump is generated as ELF format, a section is created
 * per a vma. In ELF, the number of sections is represented in unsigned short.
 * This means the number of sections should be smaller than 65535 at coredump.
 * Because the kernel adds some informative sections to a image of program at
 * generating coredump, we need some margin. The number of extra sections is
 * 1-3 now and depends on arch. We use "5" as safe margin, here.
 *
 * ELF extended numbering allows more than 65535 sections, so 16-bit bound is
 * not a hard limit any more. Although some userspace tools can be surprised by
 * that.
 */
#define nth_page(page,n) pfn_to_page(page_to_pfn((page)) + (n))

/* to align the pointer to the (next) page boundary */
#define PAGE_ALIGN(addr) ALIGN(addr, PAGE_SIZE)

static inline struct folio *lru_to_folio(struct list_head *head)
{
	return list_entry((head)->prev, struct folio, lru);
}

/*
 * vm_flags in vm_area_struct, see mm_types.h.
 * When changing, update also include/trace/events/mmflags.h
 */
#define VM_NONE		0x00000000

#define VM_READ		0x00000001	/* currently active flags */
#define VM_WRITE	0x00000002
#define VM_EXEC		0x00000004
#define VM_SHARED	0x00000008

/* mprotect() hardcodes VM_MAYREAD >> 4 == VM_READ, and so for r/w/x bits. */
#define VM_MAYREAD	0x00000010	/* limits for mprotect() etc */
#define VM_MAYWRITE	0x00000020
#define VM_MAYEXEC	0x00000040

#define VM_GROWSDOWN	0x00000100	/* general info on the segment */
#define VM_PFNMAP	0x00000400	/* Page-ranges managed without "struct page", just pure PFN */

#define VM_LOCKED	0x00002000
#define VM_IO           0x00004000	/* Memory mapped I/O or similar */

					/* Used by sys_madvise() */
#define VM_SEQ_READ	0x00008000	/* App will access data sequentially */
#define VM_RAND_READ	0x00010000	/* App will not benefit from clustered reads */

#define VM_DONTEXPAND	0x00040000	/* Cannot expand with mremap() */
#define VM_HUGETLB	0x00400000	/* Huge TLB Page VM */

#define VM_MIXEDMAP	0x10000000	/* Can contain "struct page" and pure PFN pages */
#define VM_HUGEPAGE	0x20000000	/* MADV_HUGEPAGE marked this vma */
#define VM_NOHUGEPAGE	0x40000000	/* MADV_NOHUGEPAGE marked this vma */

#ifndef VM_GROWSUP
# define VM_GROWSUP	VM_NONE
#endif

/* Bits set in the VMA until the stack is in its final location */
#define VM_STACK_INCOMPLETE_SETUP	(VM_RAND_READ | VM_SEQ_READ)

#define TASK_EXEC ((current->personality & READ_IMPLIES_EXEC) ? VM_EXEC : 0)

/* Common data flag combinations */
#define VM_DATA_FLAGS_TSK_EXEC	(VM_READ | VM_WRITE | TASK_EXEC | \
				 VM_MAYREAD | VM_MAYWRITE | VM_MAYEXEC)

#ifndef VM_STACK_DEFAULT_FLAGS		/* arch can override this */
#define VM_STACK_DEFAULT_FLAGS VM_DATA_DEFAULT_FLAGS
#endif

#define VM_STACK	VM_GROWSDOWN

/* VMA basic access permission flags */
#define VM_ACCESS_FLAGS (VM_READ | VM_WRITE | VM_EXEC)


/*
 * Special vmas that are non-mergable, non-mlock()able.
 */
#define VM_SPECIAL (VM_IO | VM_DONTEXPAND | VM_PFNMAP | VM_MIXEDMAP)

/* Arch-specific flags to clear when updating VM flags on protection change */
#ifndef VM_ARCH_CLEAR
# define VM_ARCH_CLEAR	VM_NONE
#endif

/**
 * fault_flag_allow_retry_first - check ALLOW_RETRY the first time
 * @flags: Fault flags.
 *
 * This is mostly used for places where we want to try to avoid taking
 * the mmap_lock for too long a time when waiting for another condition
 * to change, in which case we can try to be polite to release the
 * mmap_lock in the first round to avoid potential starvation of other
 * processes that would also want the mmap_lock.
 *
 * Return: true if the page fault allows retry and this is the first
 * attempt of the fault handling; false otherwise.
 */
static inline bool fault_flag_allow_retry_first(enum fault_flag flags)
{
	return (flags & FAULT_FLAG_ALLOW_RETRY) &&
	    (!(flags & FAULT_FLAG_TRIED));
}

/*
 * vm_fault is filled by the pagefault handler and passed to the vma's
 * ->fault function. The vma's ->fault is responsible for returning a bitmask
 * of VM_FAULT_xxx flags that give details about how the fault was handled.
 *
 * MM layer fills up gfp_mask for page allocations but fault handler might
 * alter it if its implementation requires a different allocation context.
 *
 * pgoff should be used in favour of virtual_address, if possible.
 */
struct vm_fault {
	const struct {
		struct vm_area_struct *vma;	/* Target VMA */
		gfp_t gfp_mask;			/* gfp mask to be used for allocations */
		pgoff_t pgoff;			/* Logical page offset based on vma */
		unsigned long address;		/* Faulting virtual address - masked */
	};
	enum fault_flag flags;		/* FAULT_FLAG_xxx flags
					 * XXX: should really be 'const' */
	pmd_t *pmd;			/* Pointer to pmd entry matching
					 * the 'address' */
	pud_t *pud;			/* Pointer to pud entry matching
					 * the 'address'
					 */

	struct page *page;		/* ->fault handlers should return a
					 * page here, unless VM_FAULT_NOPAGE
					 * is set (which is also implied by
					 * VM_FAULT_ERROR).
					 */
	/* These three entries are valid only while holding ptl lock */
	pte_t *pte;			/* Pointer to pte entry matching
					 * the 'address'. NULL if the page
					 * table hasn't been allocated.
					 */
	spinlock_t *ptl;		/* Page table lock.
					 * Protects pte page table if 'pte'
					 * is not NULL, otherwise pmd.
					 */
};

/*
 * These are the virtual MM functions - opening of an area, closing and
 * unmapping it (needed to keep files on disk up-to-date etc), pointer
 * to the functions called when a no-page or a wp-page exception occurs.
 */
struct vm_operations_struct {
	void (*open)(struct vm_area_struct * area);
	/**
	 * @close: Called when the VMA is being removed from the MM.
	 * Context: User context.  May sleep.  Caller holds mmap_lock.
	 */
	void (*close)(struct vm_area_struct * area);
	vm_fault_t (*fault)(struct vm_fault *vmf);

	/* called by access_process_vm when get_user_pages() fails, typically
	 * for use by special VMAs. See also generic_access_phys() for a generic
	 * implementation useful for any iomem mapping.
	 */
	int (*access)(struct vm_area_struct *vma, unsigned long addr,
		      void *buf, int len, int write);

	/* Called by the /proc/PID/maps code to ask the vma whether it
	 * has a special name.  Returning non-NULL will also cause this
	 * vma to be dumped unconditionally. */
	const char *(*name)(struct vm_area_struct *vma);
};

static inline void vma_init(struct vm_area_struct *vma, struct mm_struct *mm)
{
	static const struct vm_operations_struct dummy_vm_ops = {};

	memset(vma, 0, sizeof(*vma));
	vma->vm_mm = mm;
	vma->vm_ops = &dummy_vm_ops;
	INIT_LIST_HEAD(&vma->anon_vma_chain);
}

static inline void vma_set_anonymous(struct vm_area_struct *vma)
{
	vma->vm_ops = NULL;
}

static inline bool vma_is_anonymous(struct vm_area_struct *vma)
{
	return !vma->vm_ops;
}

static inline bool vma_is_temporary_stack(struct vm_area_struct *vma)
{
	int maybe_stack = vma->vm_flags & (VM_GROWSDOWN | VM_GROWSUP);

	if (!maybe_stack)
		return false;

	if ((vma->vm_flags & VM_STACK_INCOMPLETE_SETUP) ==
						VM_STACK_INCOMPLETE_SETUP)
		return true;

	return false;
}

static inline bool vma_is_foreign(struct vm_area_struct *vma)
{
	if (!current->mm)
		return true;

	if (current->mm != vma->vm_mm)
		return true;

	return false;
}

static inline bool vma_is_accessible(struct vm_area_struct *vma)
{
	return vma->vm_flags & VM_ACCESS_FLAGS;
}

static inline bool vma_is_shmem(struct vm_area_struct *vma) { return false; }

struct mmu_gather;
struct inode;

static inline unsigned int compound_order(struct page *page)
{
	if (!PageHead(page))
		return 0;
	return page[1].compound_order;
}

/**
 * folio_order - The allocation order of a folio.
 * @folio: The folio.
 *
 * A folio is composed of 2^order pages.  See get_order() for the definition
 * of order.
 *
 * Return: The order of the folio.
 */
static inline unsigned int folio_order(struct folio *folio)
{
	return compound_order(&folio->page);
}

#include <linux/huge_mm.h>

/*
 * Methods to modify the page usage count.
 *
 * What counts for a page usage:
 * - cache mapping   (page->mapping)
 * - private data    (page->private)
 * - page mapped in a task's page tables, each mapping
 *   is counted separately
 *
 * Also, many kernel routines increase the page count before a critical
 * routine so they can be sure the page doesn't go away from under them.
 */

/*
 * Drop a ref, return true if the refcount fell to zero (the page has no users)
 */
static inline int put_page_testzero(struct page *page)
{
	VM_BUG_ON_PAGE(page_ref_count(page) == 0, page);
	return page_ref_dec_and_test(page);
}

static inline int folio_put_testzero(struct folio *folio)
{
	return put_page_testzero(&folio->page);
}

/*
 * Try to grab a ref unless the page has a refcount of zero, return false if
 * that is the case.
 * This can be called when MMU is off so it must not access
 * any of the virtual mappings.
 */
static inline bool get_page_unless_zero(struct page *page)
{
	return page_ref_add_unless(page, 1, 0);
}

/*
 * Determine if an address is within the vmalloc range
 *
 * On nommu, vmalloc/vfree wrap through kmalloc/kfree directly, so there
 * is no special casing required.
 */

#ifndef is_ioremap_addr
#define is_ioremap_addr(x) is_vmalloc_addr(x)
#endif

extern bool is_vmalloc_addr(const void *x);

/*
 * How many times the entire folio is mapped as a single unit (eg by a
 * PMD or PUD entry).  This is probably not what you want, except for
 * debugging purposes; look at folio_mapcount() or page_mapcount()
 * instead.
 */
static inline int folio_entire_mapcount(struct folio *folio)
{
	VM_BUG_ON_FOLIO(!folio_test_large(folio), folio);
	return atomic_read(folio_mapcount_ptr(folio)) + 1;
}

/*
 * Mapcount of compound page as a whole, does not include mapped sub-pages.
 *
 * Must be called only for compound pages.
 */
static inline int compound_mapcount(struct page *page)
{
	return folio_entire_mapcount(page_folio(page));
}

/*
 * The atomic page->_mapcount, starts from -1: so that transitions
 * both from it and to it can be tracked, using atomic_inc_and_test
 * and atomic_add_negative(-1).
 */
static inline void page_mapcount_reset(struct page *page)
{
	atomic_set(&(page)->_mapcount, -1);
}

int __page_mapcount(struct page *page);

/*
 * Mapcount of 0-order page; when compound sub-page, includes
 * compound_mapcount().
 *
 * Result is undefined for pages which cannot be mapped into userspace.
 * For example SLAB or special types of pages. See function page_has_type().
 * They use this place in struct page differently.
 */
static inline int page_mapcount(struct page *page)
{
	if (unlikely(PageCompound(page)))
		return __page_mapcount(page);
	return atomic_read(&page->_mapcount) + 1;
}

static inline int total_mapcount(struct page *page)
{
	return page_mapcount(page);
}

static inline struct page *virt_to_head_page(const void *x)
{
	struct page *page = virt_to_page(x);

	return compound_head(page);
}

static inline struct folio *virt_to_folio(const void *x)
{
	struct page *page = virt_to_page(x);

	return page_folio(page);
}

void __put_page(struct page *page);


/*
 * Compound pages have a destructor function.  Provide a
 * prototype for that function and accessor functions.
 * These are _only_ valid on the head of a compound page.
 */
typedef void compound_page_dtor(struct page *);

/* Keep the enum in sync with compound_page_dtors array in mm/page_alloc.c */
enum compound_dtor_id {
	COMPOUND_PAGE_DTOR,
	NR_COMPOUND_DTORS,
};
extern compound_page_dtor * const compound_page_dtors[NR_COMPOUND_DTORS];

static inline void set_compound_page_dtor(struct page *page,
		enum compound_dtor_id compound_dtor)
{
	VM_BUG_ON_PAGE(compound_dtor >= NR_COMPOUND_DTORS, page);
	page[1].compound_dtor = compound_dtor;
}

static inline void destroy_compound_page(struct page *page)
{
	VM_BUG_ON_PAGE(page[1].compound_dtor >= NR_COMPOUND_DTORS, page);
	compound_page_dtors[page[1].compound_dtor](page);
}

static inline int head_compound_pincount(struct page *head)
{
	return atomic_read(compound_pincount_ptr(head));
}

static inline void set_compound_order(struct page *page, unsigned int order)
{
	page[1].compound_order = order;
	page[1].compound_nr = 1U << order;
}

/* Returns the number of pages in this potentially compound page. */
static inline unsigned long compound_nr(struct page *page)
{
	if (!PageHead(page))
		return 1;

	return page[1].compound_nr;
}

/* Returns the number of bytes in this potentially compound page. */
static inline unsigned long page_size(struct page *page)
{
	return PAGE_SIZE << compound_order(page);
}

/* Returns the number of bits needed for the number of bytes in a page */
static inline unsigned int page_shift(struct page *page)
{
	return PAGE_SHIFT + compound_order(page);
}

/**
 * thp_order - Order of a transparent huge page.
 * @page: Head page of a transparent huge page.
 */
static inline unsigned int thp_order(struct page *page)
{
	VM_BUG_ON_PGFLAGS(PageTail(page), page);
	return compound_order(page);
}

/**
 * thp_nr_pages - The number of regular pages in this huge page.
 * @page: The head page of a huge page.
 */
static inline int thp_nr_pages(struct page *page)
{
	VM_BUG_ON_PGFLAGS(PageTail(page), page);
	return compound_nr(page);
}

/**
 * thp_size - Size of a transparent huge page.
 * @page: Head page of a transparent huge page.
 *
 * Return: Number of bytes in this page.
 */
static inline unsigned long thp_size(struct page *page)
{
	return PAGE_SIZE << thp_order(page);
}

/*
 * Do pte_mkwrite, but only if the vma says VM_WRITE.  We do this when
 * servicing faults for write access.  In the normal case, do always want
 * pte_mkwrite.  But get_user_pages can cause write faults for mappings
 * that do not have writing enabled, when used by access_process_vm.
 */
static inline pte_t maybe_mkwrite(pte_t pte, struct vm_area_struct *vma)
{
	if (likely(vma->vm_flags & VM_WRITE))
		pte = pte_mkwrite(pte);
	return pte;
}

/*
 * Multiple processes may "see" the same page. E.g. for untouched
 * mappings of /dev/null, all processes see the same page full of
 * zeroes, and text pages of executables and shared libraries have
 * only one copy in memory, at most, normally.
 *
 * For the non-reserved pages, page_count(page) denotes a reference count.
 *   page_count() == 0 means the page is free. page->lru is then used for
 *   freelist management in the buddy allocator.
 *   page_count() > 0  means the page has been allocated.
 *
 * Pages are allocated by the slab allocator in order to provide memory
 * to kmalloc and kmem_cache_alloc. In this case, the management of the
 * page, and the fields in 'struct page' are the responsibility of mm/slab.c
 * unless a particular usage is carefully commented. (the responsibility of
 * freeing the kmalloc memory is the caller's, of course).
 *
 * A page may be used by anyone else who does a __get_free_page().
 * In this case, page_count still tracks the references, and should only
 * be used through the normal accessor functions. The top bits of page->flags
 * and page->virtual store page management information, but all other fields
 * are unused and could be used privately, carefully. The management of this
 * page is the responsibility of the one who allocated it, and those who have
 * subsequently been given references to it.
 *
 * The other pages (we may call them "pagecache pages") are completely
 * managed by the Linux memory manager: I/O, buffers, swapping etc.
 * The following discussion applies only to them.
 *
 * A pagecache page contains an opaque `private' member, which belongs to the
 * page's address_space. Usually, this is the address of a circular list of
 * the page's disk buffers. PG_private must be set to tell the VM to call
 * into the filesystem to release these pages.
 *
 * A page may belong to an inode's memory mapping. In this case, page->mapping
 * is the pointer to the inode, and page->index is the file offset of the page,
 * in units of PAGE_SIZE.
 *
 * If pagecache pages are not associated with an inode, they are said to be
 * anonymous pages. These may become associated with the swapcache, and in that
 * case PG_swapcache is set, and page->private is an offset into the swapcache.
 *
 * In either case (swapcache or inode backed), the pagecache itself holds one
 * reference to the page. Setting PG_private should also increment the
 * refcount. The each user mapping also has a reference to the page.
 *
 * The pagecache pages are stored in a per-mapping radix tree, which is
 * rooted at mapping->i_pages, and indexed by offset.
 * Where 2.4 and early 2.6 kernels kept dirty/clean pages in per-address_space
 * lists, we instead now tag pages as dirty/writeback in the radix tree.
 *
 * All pagecache pages may be subject to I/O:
 * - inode pages may need to be read from disk,
 * - inode pages which have been modified and are MAP_SHARED may need
 *   to be written back to the inode on disk,
 * - anonymous pages (including MAP_PRIVATE file mappings) which have been
 *   modified may need to be swapped out to swap space and (later) to be read
 *   back into memory.
 */

/*
 * The zone field is never updated after free_area_init_core()
 * sets it, so none of the operations on it need to be atomic.
 */

/* Page flags: | [SECTION] | [NODE] | ZONE | [LAST_CPUPID] | ... | FLAGS | */
#define SECTIONS_PGOFF		((sizeof(unsigned long)*8) - SECTIONS_WIDTH)
#define NODES_PGOFF		(SECTIONS_PGOFF - NODES_WIDTH)
#define ZONES_PGOFF		(NODES_PGOFF - ZONES_WIDTH)
#define LAST_CPUPID_PGOFF	(ZONES_PGOFF - LAST_CPUPID_WIDTH)
#define KASAN_TAG_PGOFF		(LAST_CPUPID_PGOFF - KASAN_TAG_WIDTH)

/*
 * Define the bit shifts to access each section.  For non-existent
 * sections we define the shift as 0; that plus a 0 mask ensures
 * the compiler will optimise away reference to them.
 */
#define SECTIONS_PGSHIFT	(SECTIONS_PGOFF * (SECTIONS_WIDTH != 0))
#define NODES_PGSHIFT		(NODES_PGOFF * (NODES_WIDTH != 0))
#define ZONES_PGSHIFT		(ZONES_PGOFF * (ZONES_WIDTH != 0))
#define LAST_CPUPID_PGSHIFT	(LAST_CPUPID_PGOFF * (LAST_CPUPID_WIDTH != 0))
#define KASAN_TAG_PGSHIFT	(KASAN_TAG_PGOFF * (KASAN_TAG_WIDTH != 0))

/* NODE:ZONE or SECTION:ZONE is used to ID a zone for the buddy allocator */
#ifdef NODE_NOT_IN_PAGE_FLAGS
#else
#define ZONEID_SHIFT		(NODES_SHIFT + ZONES_SHIFT)
#define ZONEID_PGOFF		((NODES_PGOFF < ZONES_PGOFF)? \
						NODES_PGOFF : ZONES_PGOFF)
#endif

#define ZONEID_PGSHIFT		(ZONEID_PGOFF * (ZONEID_SHIFT != 0))

#define ZONES_MASK		((1UL << ZONES_WIDTH) - 1)
#define NODES_MASK		((1UL << NODES_WIDTH) - 1)
#define SECTIONS_MASK		((1UL << SECTIONS_WIDTH) - 1)
#define LAST_CPUPID_MASK	((1UL << LAST_CPUPID_SHIFT) - 1)
#define KASAN_TAG_MASK		((1UL << KASAN_TAG_WIDTH) - 1)
#define ZONEID_MASK		((1UL << ZONEID_SHIFT) - 1)

static inline enum zone_type page_zonenum(const struct page *page)
{
	ASSERT_EXCLUSIVE_BITS(page->flags, ZONES_MASK << ZONES_PGSHIFT);
	return (page->flags >> ZONES_PGSHIFT) & ZONES_MASK;
}

static inline enum zone_type folio_zonenum(const struct folio *folio)
{
	return page_zonenum(&folio->page);
}

static inline bool is_zone_device_page(const struct page *page)
{
	return false;
}

static inline bool folio_is_zone_device(const struct folio *folio)
{
	return is_zone_device_page(&folio->page);
}

static inline bool is_zone_movable_page(const struct page *page)
{
	return page_zonenum(page) == ZONE_MOVABLE;
}

static inline bool put_devmap_managed_page_refs(struct page *page, int refs)
{
	return false;
}

static inline bool put_devmap_managed_page(struct page *page)
{
	return put_devmap_managed_page_refs(page, 1);
}

/* 127: arbitrary random number, small enough to assemble well */
#define folio_ref_zero_or_close_to_overflow(folio) \
	((unsigned int) folio_ref_count(folio) + 127u <= 127u)

/**
 * folio_get - Increment the reference count on a folio.
 * @folio: The folio.
 *
 * Context: May be called in any context, as long as you know that
 * you have a refcount on the folio.  If you do not already have one,
 * folio_try_get() may be the right interface for you to use.
 */
static inline void folio_get(struct folio *folio)
{
	VM_BUG_ON_FOLIO(folio_ref_zero_or_close_to_overflow(folio), folio);
	folio_ref_inc(folio);
}

static inline void get_page(struct page *page)
{
	folio_get(page_folio(page));
}

static inline __must_check bool try_get_page(struct page *page)
{
	page = compound_head(page);
	if (WARN_ON_ONCE(page_ref_count(page) <= 0))
		return false;
	page_ref_inc(page);
	return true;
}

/**
 * folio_put - Decrement the reference count on a folio.
 * @folio: The folio.
 *
 * If the folio's reference count reaches zero, the memory will be
 * released back to the page allocator and may be used by another
 * allocation immediately.  Do not access the memory or the struct folio
 * after calling folio_put() unless you can be sure that it wasn't the
 * last reference.
 *
 * Context: May be called in process or interrupt context, but not in NMI
 * context.  May be called while holding a spinlock.
 */
static inline void folio_put(struct folio *folio)
{
	if (folio_put_testzero(folio))
		__put_page(&folio->page);
}

/**
 * folio_put_refs - Reduce the reference count on a folio.
 * @folio: The folio.
 * @refs: The amount to subtract from the folio's reference count.
 *
 * If the folio's reference count reaches zero, the memory will be
 * released back to the page allocator and may be used by another
 * allocation immediately.  Do not access the memory or the struct folio
 * after calling folio_put_refs() unless you can be sure that these weren't
 * the last references.
 *
 * Context: May be called in process or interrupt context, but not in NMI
 * context.  May be called while holding a spinlock.
 */
static inline void folio_put_refs(struct folio *folio, int refs)
{
	if (folio_ref_sub_and_test(folio, refs))
		__put_page(&folio->page);
}

static inline void put_page(struct page *page)
{
	struct folio *folio = page_folio(page);

	/*
	 * For some devmap managed pages we need to catch refcount transition
	 * from 2 to 1:
	 */
	if (put_devmap_managed_page(&folio->page))
		return;
	folio_put(folio);
}

/*
 * GUP_PIN_COUNTING_BIAS, and the associated functions that use it, overload
 * the page's refcount so that two separate items are tracked: the original page
 * reference count, and also a new count of how many pin_user_pages() calls were
 * made against the page. ("gup-pinned" is another term for the latter).
 *
 * With this scheme, pin_user_pages() becomes special: such pages are marked as
 * distinct from normal pages. As such, the unpin_user_page() call (and its
 * variants) must be used in order to release gup-pinned pages.
 *
 * Choice of value:
 *
 * By making GUP_PIN_COUNTING_BIAS a power of two, debugging of page reference
 * counts with respect to pin_user_pages() and unpin_user_page() becomes
 * simpler, due to the fact that adding an even power of two to the page
 * refcount has the effect of using only the upper N bits, for the code that
 * counts up using the bias value. This means that the lower bits are left for
 * the exclusive use of the original code that increments and decrements by one
 * (or at least, by much smaller values than the bias value).
 *
 * Of course, once the lower bits overflow into the upper bits (and this is
 * OK, because subtraction recovers the original values), then visual inspection
 * no longer suffices to directly view the separate counts. However, for normal
 * applications that don't have huge page reference counts, this won't be an
 * issue.
 *
 * Locking: the lockless algorithm described in folio_try_get_rcu()
 * provides safe operation for get_user_pages(), page_mkclean() and
 * other calls that race to set up page table entries.
 */
#define GUP_PIN_COUNTING_BIAS (1U << 10)

static inline bool is_cow_mapping(vm_flags_t flags)
{
	return (flags & (VM_SHARED | VM_MAYWRITE)) == VM_MAYWRITE;
}

#if defined(CONFIG_SPARSEMEM) && !defined(CONFIG_SPARSEMEM_VMEMMAP)
#define SECTION_IN_PAGE_FLAGS
#endif

/*
 * The identification function is mainly used by the buddy allocator for
 * determining if two pages could be buddies. We are not really identifying
 * the zone since we could be using the section number id if we do not have
 * node id available in page flags.
 * We only guarantee that it will return the same value for two combinable
 * pages in a zone.
 */
static inline int page_zone_id(struct page *page)
{
	return (page->flags >> ZONEID_PGSHIFT) & ZONEID_MASK;
}

static inline int page_to_nid(const struct page *page)
{
	struct page *p = (struct page *)page;

	return (PF_POISONED_CHECK(p)->flags >> NODES_PGSHIFT) & NODES_MASK;
}

static inline int folio_nid(const struct folio *folio)
{
	return page_to_nid(&folio->page);
}

static inline int page_cpupid_xchg_last(struct page *page, int cpupid)
{
	return page_to_nid(page); /* XXX */
}

static inline int page_cpupid_last(struct page *page)
{
	return page_to_nid(page); /* XXX */
}

static inline int cpupid_to_nid(int cpupid)
{
	return -1;
}

static inline int cpupid_to_pid(int cpupid)
{
	return -1;
}

static inline int cpupid_to_cpu(int cpupid)
{
	return -1;
}

static inline int cpu_pid_to_cpupid(int nid, int pid)
{
	return -1;
}

static inline bool cpupid_pid_unset(int cpupid)
{
	return true;
}

static inline void page_cpupid_reset_last(struct page *page)
{
}

static inline bool cpupid_match_pid(struct task_struct *task, int cpupid)
{
	return false;
}

static inline u8 page_kasan_tag(const struct page *page)
{
	return 0xff;
}

static inline void page_kasan_tag_set(struct page *page, u8 tag) { }
static inline void page_kasan_tag_reset(struct page *page) { }

static inline struct zone *page_zone(const struct page *page)
{
	return &NODE_DATA(page_to_nid(page))->node_zones[page_zonenum(page)];
}

static inline pg_data_t *page_pgdat(const struct page *page)
{
	return NODE_DATA(page_to_nid(page));
}

static inline struct zone *folio_zone(const struct folio *folio)
{
	return page_zone(&folio->page);
}

static inline pg_data_t *folio_pgdat(const struct folio *folio)
{
	return page_pgdat(&folio->page);
}

static inline void set_page_section(struct page *page, unsigned long section)
{
	page->flags &= ~(SECTIONS_MASK << SECTIONS_PGSHIFT);
	page->flags |= (section & SECTIONS_MASK) << SECTIONS_PGSHIFT;
}

static inline unsigned long page_to_section(const struct page *page)
{
	return (page->flags >> SECTIONS_PGSHIFT) & SECTIONS_MASK;
}

/**
 * folio_pfn - Return the Page Frame Number of a folio.
 * @folio: The folio.
 *
 * A folio may contain multiple pages.  The pages have consecutive
 * Page Frame Numbers.
 *
 * Return: The Page Frame Number of the first page in the folio.
 */
static inline unsigned long folio_pfn(struct folio *folio)
{
	return page_to_pfn(&folio->page);
}

static inline atomic_t *folio_pincount_ptr(struct folio *folio)
{
	return &folio_page(folio, 1)->compound_pincount;
}

/**
 * folio_maybe_dma_pinned - Report if a folio may be pinned for DMA.
 * @folio: The folio.
 *
 * This function checks if a folio has been pinned via a call to
 * a function in the pin_user_pages() family.
 *
 * For small folios, the return value is partially fuzzy: false is not fuzzy,
 * because it means "definitely not pinned for DMA", but true means "probably
 * pinned for DMA, but possibly a false positive due to having at least
 * GUP_PIN_COUNTING_BIAS worth of normal folio references".
 *
 * False positives are OK, because: a) it's unlikely for a folio to
 * get that many refcounts, and b) all the callers of this routine are
 * expected to be able to deal gracefully with a false positive.
 *
 * For large folios, the result will be exactly correct. That's because
 * we have more tracking data available: the compound_pincount is used
 * instead of the GUP_PIN_COUNTING_BIAS scheme.
 *
 * For more information, please see Documentation/core-api/pin_user_pages.rst.
 *
 * Return: True, if it is likely that the page has been "dma-pinned".
 * False, if the page is definitely not dma-pinned.
 */
static inline bool folio_maybe_dma_pinned(struct folio *folio)
{
	if (folio_test_large(folio))
		return atomic_read(folio_pincount_ptr(folio)) > 0;

	/*
	 * folio_ref_count() is signed. If that refcount overflows, then
	 * folio_ref_count() returns a negative value, and callers will avoid
	 * further incrementing the refcount.
	 *
	 * Here, for that overflow case, use the sign bit to count a little
	 * bit higher via unsigned math, and thus still get an accurate result.
	 */
	return ((unsigned int)folio_ref_count(folio)) >=
		GUP_PIN_COUNTING_BIAS;
}

static inline bool page_maybe_dma_pinned(struct page *page)
{
	return folio_maybe_dma_pinned(page_folio(page));
}

/*
 * This should most likely only be called during fork() to see whether we
 * should break the cow immediately for an anon page on the src mm.
 *
 * The caller has to hold the PT lock and the vma->vm_mm->->write_protect_seq.
 */
static inline bool page_needs_cow_for_dma(struct vm_area_struct *vma,
					  struct page *page)
{
	VM_BUG_ON(!(raw_read_seqcount(&vma->vm_mm->write_protect_seq) & 1));

	if (!test_bit(MMF_HAS_PINNED, &vma->vm_mm->flags))
		return false;

	return page_maybe_dma_pinned(page);
}

static inline bool is_pinnable_page(struct page *page)
{
	return true;
}

static inline void set_page_zone(struct page *page, enum zone_type zone)
{
	page->flags &= ~(ZONES_MASK << ZONES_PGSHIFT);
	page->flags |= (zone & ZONES_MASK) << ZONES_PGSHIFT;
}

static inline void set_page_node(struct page *page, unsigned long node)
{
	page->flags &= ~(NODES_MASK << NODES_PGSHIFT);
	page->flags |= (node & NODES_MASK) << NODES_PGSHIFT;
}

static inline void set_page_links(struct page *page, enum zone_type zone,
	unsigned long node, unsigned long pfn)
{
	set_page_zone(page, zone);
	set_page_node(page, node);
#ifdef SECTION_IN_PAGE_FLAGS
	set_page_section(page, pfn_to_section_nr(pfn));
#endif
}

/**
 * folio_nr_pages - The number of pages in the folio.
 * @folio: The folio.
 *
 * Return: A positive power of two.
 */
static inline long folio_nr_pages(struct folio *folio)
{
	return compound_nr(&folio->page);
}

/**
 * folio_size - The number of bytes in a folio.
 * @folio: The folio.
 *
 * Context: The caller should have a reference on the folio to prevent
 * it from being split.  It is not necessary for the folio to be locked.
 * Return: The number of bytes in this folio.
 */
static inline size_t folio_size(struct folio *folio)
{
	return PAGE_SIZE << folio_order(folio);
}


/*
 * Some inline functions in vmstat.h depend on page_zone()
 */
#include <linux/vmstat.h>

static __always_inline void *lowmem_page_address(const struct page *page)
{
	return page_to_virt(page);
}

#if !defined(HASHED_PAGE_VIRTUAL) && !defined(WANT_PAGE_VIRTUAL)
#define page_address(page) lowmem_page_address(page)
#endif

static inline void *folio_address(const struct folio *folio)
{
	return page_address(&folio->page);
}

extern pgoff_t __page_file_index(struct page *page);

/*
 * Return the pagecache index of the passed page.  Regular pagecache pages
 * use ->index whereas swapcache pages use swp_offset(->private)
 */
static inline pgoff_t page_index(struct page *page)
{
	if (unlikely(PageSwapCache(page)))
		return __page_file_index(page);
	return page->index;
}

/*
 * Return true only if the page has been allocated with
 * ALLOC_NO_WATERMARKS and the low watermark was not
 * met implying that the system is under some pressure.
 */
static inline bool page_is_pfmemalloc(const struct page *page)
{
	/*
	 * lru.next has bit 1 set if the page is allocated from the
	 * pfmemalloc reserves.  Callers may simply overwrite it if
	 * they do not need to preserve that information.
	 */
	return (uintptr_t)page->lru.next & BIT(1);
}

/*
 * Only to be called by the page allocator on a freshly allocated
 * page.
 */
static inline void set_page_pfmemalloc(struct page *page)
{
	page->lru.next = (void *)BIT(1);
}

static inline void clear_page_pfmemalloc(struct page *page)
{
	page->lru.next = NULL;
}

#define offset_in_page(p)	((unsigned long)(p) & ~PAGE_MASK)
#define offset_in_folio(folio, p) ((unsigned long)(p) & (folio_size(folio) - 1))

void unmap_mapping_range(struct address_space *mapping,
		loff_t const holebegin, loff_t const holelen, int even_cows);

static inline void unmap_shared_mapping_range(struct address_space *mapping,
		loff_t const holebegin, loff_t const holelen)
{
	unmap_mapping_range(mapping, holebegin, holelen, 0);
}

struct kvec;

/*
 * doesn't attempt to fault and will return short.
 */
int get_user_pages_fast_only(unsigned long start, int nr_pages,
			     unsigned int gup_flags, struct page **pages);

static inline bool get_user_page_fast_only(unsigned long addr,
			unsigned int gup_flags, struct page **pagep)
{
	return get_user_pages_fast_only(addr, 1, gup_flags, pagep) == 1;
}
/*
 * per-process(per-mm_struct) statistics.
 */
static inline unsigned long get_mm_counter(struct mm_struct *mm, int member)
{
	long val = atomic_long_read(&mm->rss_stat.count[member]);

	return (unsigned long)val;
}

void mm_trace_rss_stat(struct mm_struct *mm, int member, long count);

static inline void add_mm_counter(struct mm_struct *mm, int member, long value)
{
	long count = atomic_long_add_return(value, &mm->rss_stat.count[member]);

	mm_trace_rss_stat(mm, member, count);
}

static inline void inc_mm_counter(struct mm_struct *mm, int member)
{
	long count = atomic_long_inc_return(&mm->rss_stat.count[member]);

	mm_trace_rss_stat(mm, member, count);
}

static inline void dec_mm_counter(struct mm_struct *mm, int member)
{
	long count = atomic_long_dec_return(&mm->rss_stat.count[member]);

	mm_trace_rss_stat(mm, member, count);
}

/* Optimized variant when page is already known not to be PageAnon */
static inline int mm_counter_file(struct page *page)
{
	if (PageSwapBacked(page))
		return MM_SHMEMPAGES;
	return MM_FILEPAGES;
}

static inline int mm_counter(struct page *page)
{
	if (PageAnon(page))
		return MM_ANONPAGES;
	return mm_counter_file(page);
}

static inline unsigned long get_mm_rss(struct mm_struct *mm)
{
	return get_mm_counter(mm, MM_FILEPAGES) +
		get_mm_counter(mm, MM_ANONPAGES) +
		get_mm_counter(mm, MM_SHMEMPAGES);
}

static inline unsigned long get_mm_hiwater_rss(struct mm_struct *mm)
{
	return max(mm->hiwater_rss, get_mm_rss(mm));
}

static inline unsigned long get_mm_hiwater_vm(struct mm_struct *mm)
{
	return max(mm->hiwater_vm, mm->total_vm);
}

static inline void update_hiwater_rss(struct mm_struct *mm)
{
	unsigned long _rss = get_mm_rss(mm);

	if ((mm)->hiwater_rss < _rss)
		(mm)->hiwater_rss = _rss;
}

static inline void update_hiwater_vm(struct mm_struct *mm)
{
	if (mm->hiwater_vm < mm->total_vm)
		mm->hiwater_vm = mm->total_vm;
}

static inline void reset_mm_hiwater_rss(struct mm_struct *mm)
{
	mm->hiwater_rss = get_mm_rss(mm);
}

static inline void setmax_mm_hiwater_rss(unsigned long *maxrss,
					 struct mm_struct *mm)
{
	unsigned long hiwater_rss = get_mm_hiwater_rss(mm);

	if (*maxrss < hiwater_rss)
		*maxrss = hiwater_rss;
}

static inline void sync_mm_rss(struct mm_struct *mm)
{
}

extern pte_t *__get_locked_pte(struct mm_struct *mm, unsigned long addr,
			       spinlock_t **ptl);
static inline pte_t *get_locked_pte(struct mm_struct *mm, unsigned long addr,
				    spinlock_t **ptl)
{
	pte_t *ptep;
	__cond_lock(*ptl, ptep = __get_locked_pte(mm, addr, ptl));
	return ptep;
}

static inline int __p4d_alloc(struct mm_struct *mm, pgd_t *pgd,
						unsigned long address)
{
	return 0;
}

int __pud_alloc(struct mm_struct *mm, p4d_t *p4d, unsigned long address);

static inline void mm_inc_nr_puds(struct mm_struct *mm)
{
	if (mm_pud_folded(mm))
		return;
	atomic_long_add(PTRS_PER_PUD * sizeof(pud_t), &mm->pgtables_bytes);
}

static inline void mm_dec_nr_puds(struct mm_struct *mm)
{
	if (mm_pud_folded(mm))
		return;
	atomic_long_sub(PTRS_PER_PUD * sizeof(pud_t), &mm->pgtables_bytes);
}

int __pmd_alloc(struct mm_struct *mm, pud_t *pud, unsigned long address);

static inline void mm_inc_nr_pmds(struct mm_struct *mm)
{
	if (mm_pmd_folded(mm))
		return;
	atomic_long_add(PTRS_PER_PMD * sizeof(pmd_t), &mm->pgtables_bytes);
}

static inline void mm_dec_nr_pmds(struct mm_struct *mm)
{
	if (mm_pmd_folded(mm))
		return;
	atomic_long_sub(PTRS_PER_PMD * sizeof(pmd_t), &mm->pgtables_bytes);
}

static inline void mm_pgtables_bytes_init(struct mm_struct *mm)
{
	atomic_long_set(&mm->pgtables_bytes, 0);
}

static inline unsigned long mm_pgtables_bytes(const struct mm_struct *mm)
{
	return atomic_long_read(&mm->pgtables_bytes);
}

static inline void mm_inc_nr_ptes(struct mm_struct *mm)
{
	atomic_long_add(PTRS_PER_PTE * sizeof(pte_t), &mm->pgtables_bytes);
}

static inline void mm_dec_nr_ptes(struct mm_struct *mm)
{
	atomic_long_sub(PTRS_PER_PTE * sizeof(pte_t), &mm->pgtables_bytes);
}

static inline p4d_t *p4d_alloc(struct mm_struct *mm, pgd_t *pgd,
		unsigned long address)
{
	return (unlikely(pgd_none(*pgd)) && __p4d_alloc(mm, pgd, address)) ?
		NULL : p4d_offset(pgd, address);
}

static inline pud_t *pud_alloc(struct mm_struct *mm, p4d_t *p4d,
		unsigned long address)
{
	return (unlikely(p4d_none(*p4d)) && __pud_alloc(mm, p4d, address)) ?
		NULL : pud_offset(p4d, address);
}

static inline pmd_t *pmd_alloc(struct mm_struct *mm, pud_t *pud, unsigned long address)
{
	return (unlikely(pud_none(*pud)) && __pmd_alloc(mm, pud, address))?
		NULL: pmd_offset(pud, address);
}

static inline void ptlock_cache_init(void)
{
}

static inline bool ptlock_alloc(struct page *page)
{
	return true;
}

static inline void ptlock_free(struct page *page)
{
}

static inline spinlock_t *ptlock_ptr(struct page *page)
{
	return &page->ptl;
}

static inline spinlock_t *pte_lockptr(struct mm_struct *mm, pmd_t *pmd)
{
	return ptlock_ptr(pmd_page(*pmd));
}

static inline bool ptlock_init(struct page *page)
{
	/*
	 * prep_new_page() initialize page->private (and therefore page->ptl)
	 * with 0. Make sure nobody took it in use in between.
	 *
	 * It can happen if arch try to use slab for page table allocation:
	 * slab code uses page->slab_cache, which share storage with page->ptl.
	 */
	VM_BUG_ON_PAGE(*(unsigned long *)&page->ptl, page);
	if (!ptlock_alloc(page))
		return false;
	spin_lock_init(ptlock_ptr(page));
	return true;
}

static inline bool pgtable_pte_page_ctor(struct page *page)
{
	if (!ptlock_init(page))
		return false;
	__SetPageTable(page);
	inc_lruvec_page_state(page, NR_PAGETABLE);
	return true;
}

static inline void pgtable_pte_page_dtor(struct page *page)
{
	ptlock_free(page);
	__ClearPageTable(page);
	dec_lruvec_page_state(page, NR_PAGETABLE);
}

static inline bool pmd_ptlock_init(struct page *page) { return true; }
static inline void pmd_ptlock_free(struct page *page) {}

#define pmd_huge_pte(mm, pmd) ((mm)->pmd_huge_pte)

static inline bool pgtable_pmd_page_ctor(struct page *page)
{
	if (!pmd_ptlock_init(page))
		return false;
	__SetPageTable(page);
	inc_lruvec_page_state(page, NR_PAGETABLE);
	return true;
}

static inline void pgtable_pmd_page_dtor(struct page *page)
{
	pmd_ptlock_free(page);
	__ClearPageTable(page);
	dec_lruvec_page_state(page, NR_PAGETABLE);
}

extern void mem_init_print_info(void);

extern void reserve_bootmem_region(phys_addr_t start, phys_addr_t end);

static inline unsigned long get_num_physpages(void)
{
	int nid;
	unsigned long phys_pages = 0;

	for_each_online_node(nid)
		phys_pages += node_present_pages(nid);

	return phys_pages;
}

/*
 * Using memblock node mappings, an architecture may initialise its
 * zones, allocate the backing mem_map and account for memory holes in an
 * architecture independent manner.
 *
 * An architecture is expected to register range of page frames backed by
 * physical memory with memblock_add[_node]() before calling
 * free_area_init() passing in the PFN each zone ends at. At a basic
 * usage, an architecture is expected to do something like
 *
 * unsigned long max_zone_pfns[MAX_NR_ZONES] = {max_dma, max_normal_pfn,
 * 							 max_highmem_pfn};
 * for_each_valid_physical_page_range()
 *	memblock_add_node(base, size, nid, MEMBLOCK_NONE)
 * free_area_init(max_zone_pfns);
 */
void free_area_init(unsigned long *max_zone_pfn);
unsigned long __absent_pages_in_range(int nid, unsigned long start_pfn,
						unsigned long end_pfn);
extern void get_pfn_range_for_nid(unsigned int nid,
			unsigned long *start_pfn, unsigned long *end_pfn);
extern unsigned long find_min_pfn_with_active_regions(void);

extern void memmap_init_range(unsigned long, int, unsigned long,
		unsigned long, unsigned long, enum meminit_context,
		struct vmem_altmap *, int migratetype);
extern void mem_init(void);

extern int watermark_boost_factor;

extern int __mm_populate(unsigned long addr, unsigned long len,
			 int ignore_errors);
static inline void mm_populate(unsigned long addr, unsigned long len)
{
	/* Ignore errors */
	(void) __mm_populate(addr, len, 1);
}

static inline vm_fault_t vmf_error(int err)
{
	if (err == -ENOMEM)
		return VM_FAULT_OOM;
	return VM_FAULT_SIGBUS;
}

DECLARE_STATIC_KEY_MAYBE(CONFIG_INIT_ON_ALLOC_DEFAULT_ON, init_on_alloc);
static inline bool want_init_on_alloc(gfp_t flags)
{
	if (static_branch_maybe(CONFIG_INIT_ON_ALLOC_DEFAULT_ON,
				&init_on_alloc))
		return true;
	return flags & __GFP_ZERO;
}

DECLARE_STATIC_KEY_MAYBE(CONFIG_INIT_ON_FREE_DEFAULT_ON, init_on_free);
static inline bool want_init_on_free(void)
{
	return static_branch_maybe(CONFIG_INIT_ON_FREE_DEFAULT_ON,
				   &init_on_free);
}

DECLARE_STATIC_KEY_FALSE(_debug_pagealloc_enabled);

static inline int in_gate_area_no_mm(unsigned long addr) { return 0; }

void *sparse_buffer_alloc(unsigned long size);
struct page * __populate_section_memmap(unsigned long pfn,
		unsigned long nr_pages, int nid, struct vmem_altmap *altmap,
		struct dev_pagemap *pgmap);
struct vmem_altmap;

static inline bool page_is_guard(struct page *page) { return false; }

#endif /* _LINUX_MM_H */
