/* SPDX-License-Identifier: GPL-2.0 */
#ifndef _LINUX_KASAN_H
#define _LINUX_KASAN_H

#include <linux/bug.h>
#include <linux/kasan-enabled.h>
#include <linux/kernel.h>
#include <linux/static_key.h>
#include <linux/types.h>

struct kmem_cache;
struct page;
struct slab;
struct vm_struct;
struct task_struct;

typedef unsigned int __bitwise kasan_vmalloc_flags_t;

static inline int kasan_add_zero_shadow(void *start, unsigned long size)
{
	return 0;
}
static inline void kasan_remove_zero_shadow(void *start,
					unsigned long size)
{}

static inline bool kasan_has_integrated_init(void)
{
	return kasan_hw_tags_enabled();
}

static inline slab_flags_t kasan_never_merge(void)
{
	return 0;
}
static inline void kasan_unpoison_range(const void *address, size_t size) {}
static inline void kasan_poison_pages(struct page *page, unsigned int order,
				      bool init) {}
static inline void kasan_unpoison_pages(struct page *page, unsigned int order,
					bool init) {}
static inline void kasan_cache_create(struct kmem_cache *cache,
				      unsigned int *size,
				      slab_flags_t *flags) {}
static inline void kasan_cache_create_kmalloc(struct kmem_cache *cache) {}
static inline size_t kasan_metadata_size(struct kmem_cache *cache) { return 0; }
static inline void kasan_poison_slab(struct slab *slab) {}
static inline void kasan_unpoison_object_data(struct kmem_cache *cache,
					void *object) {}
static inline void kasan_poison_object_data(struct kmem_cache *cache,
					void *object) {}
static inline void *kasan_init_slab_obj(struct kmem_cache *cache,
				const void *object)
{
	return (void *)object;
}
static inline bool kasan_slab_free(struct kmem_cache *s, void *object, bool init)
{
	return false;
}
static inline void kasan_kfree_large(void *ptr) {}
static inline void kasan_slab_free_mempool(void *ptr) {}
static inline void *kasan_slab_alloc(struct kmem_cache *s, void *object,
				   gfp_t flags, bool init)
{
	return object;
}
static inline void *kasan_kmalloc(struct kmem_cache *s, const void *object,
				size_t size, gfp_t flags)
{
	return (void *)object;
}
static inline void *kasan_kmalloc_large(const void *ptr, size_t size, gfp_t flags)
{
	return (void *)ptr;
}
static inline void *kasan_krealloc(const void *object, size_t new_size,
				 gfp_t flags)
{
	return (void *)object;
}
static inline bool kasan_check_byte(const void *address)
{
	return true;
}

static inline void kasan_unpoison_task_stack(struct task_struct *task) {}


static inline void kasan_cache_shrink(struct kmem_cache *cache) {}
static inline void kasan_cache_shutdown(struct kmem_cache *cache) {}
static inline void kasan_record_aux_stack(void *ptr) {}
static inline void kasan_record_aux_stack_noalloc(void *ptr) {}

static inline void *kasan_reset_tag(const void *addr)
{
	return (void *)addr;
}

static inline void kasan_init_sw_tags(void) { }

static inline void kasan_init_hw_tags_cpu(void) { }
static inline void kasan_init_hw_tags(void) { }

static inline void kasan_populate_early_vm_area_shadow(void *start,
						       unsigned long size) { }
static inline int kasan_populate_vmalloc(unsigned long start,
					unsigned long size)
{
	return 0;
}
static inline void kasan_release_vmalloc(unsigned long start,
					 unsigned long end,
					 unsigned long free_region_start,
					 unsigned long free_region_end) { }

static inline void *kasan_unpoison_vmalloc(const void *start,
					   unsigned long size,
					   kasan_vmalloc_flags_t flags)
{
	return (void *)start;
}
static inline void kasan_poison_vmalloc(const void *start, unsigned long size)
{ }

static inline int kasan_alloc_module_shadow(void *addr, size_t size, gfp_t gfp_mask) { return 0; }
static inline void kasan_free_module_shadow(const struct vm_struct *vm) {}

static inline void kasan_non_canonical_hook(unsigned long addr) { }

#endif /* LINUX_KASAN_H */
