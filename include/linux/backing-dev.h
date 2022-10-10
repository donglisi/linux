/* SPDX-License-Identifier: GPL-2.0 */
/*
 * include/linux/backing-dev.h
 *
 * low-level device information and state which is propagated up through
 * to high-level code.
 */

#ifndef _LINUX_BACKING_DEV_H
#define _LINUX_BACKING_DEV_H

#include <linux/kernel.h>
#include <linux/fs.h>
#include <linux/sched.h>
#include <linux/device.h>
#include <linux/writeback.h>
#include <linux/backing-dev-defs.h>
#include <linux/slab.h>

static inline struct backing_dev_info *bdi_get(struct backing_dev_info *bdi)
{
	kref_get(&bdi->refcnt);
	return bdi;
}

static inline bool wb_has_dirty_io(struct bdi_writeback *wb)
{
	return test_bit(WB_has_dirty_io, &wb->state);
}

static inline bool bdi_has_dirty_io(struct backing_dev_info *bdi)
{
	/*
	 * @bdi->tot_write_bandwidth is guaranteed to be > 0 if there are
	 * any dirty wbs.  See wb_update_write_bandwidth().
	 */
	return atomic_long_read(&bdi->tot_write_bandwidth);
}

static inline void wb_stat_mod(struct bdi_writeback *wb,
				 enum wb_stat_item item, s64 amount)
{
	percpu_counter_add_batch(&wb->stat[item], amount, WB_STAT_BATCH);
}

static inline void inc_wb_stat(struct bdi_writeback *wb, enum wb_stat_item item)
{
	wb_stat_mod(wb, item, 1);
}

static inline void dec_wb_stat(struct bdi_writeback *wb, enum wb_stat_item item)
{
	wb_stat_mod(wb, item, -1);
}

static inline s64 wb_stat(struct bdi_writeback *wb, enum wb_stat_item item)
{
	return percpu_counter_read_positive(&wb->stat[item]);
}

static inline s64 wb_stat_sum(struct bdi_writeback *wb, enum wb_stat_item item)
{
	return percpu_counter_sum_positive(&wb->stat[item]);
}

/*
 * maximal error of a stat counter.
 */
static inline unsigned long wb_stat_error(void)
{
	return 1;
}

/*
 * Flags in backing_dev_info::capability
 *
 * BDI_CAP_WRITEBACK:		Supports dirty page writeback, and dirty pages
 *				should contribute to accounting
 * BDI_CAP_WRITEBACK_ACCT:	Automatically account writeback pages
 * BDI_CAP_STRICTLIMIT:		Keep number of dirty pages below bdi threshold
 */
#define BDI_CAP_WRITEBACK		(1 << 0)

/**
 * writeback_in_progress - determine whether there is writeback in progress
 * @wb: bdi_writeback of interest
 *
 * Determine whether there is writeback waiting to be handled against a
 * bdi_writeback.
 */
static inline bool writeback_in_progress(struct bdi_writeback *wb)
{
	return test_bit(WB_writeback_running, &wb->state);
}

struct backing_dev_info *inode_to_bdi(struct inode *inode);

static inline bool mapping_can_writeback(struct address_space *mapping)
{
	return inode_to_bdi(mapping->host)->capabilities & BDI_CAP_WRITEBACK;
}

static inline int bdi_sched_wait(void *word)
{
	schedule();
	return 0;
}

static inline bool inode_cgwb_enabled(struct inode *inode)
{
	return false;
}

static inline struct bdi_writeback *wb_find_current(struct backing_dev_info *bdi)
{
	return &bdi->wb;
}

static inline struct bdi_writeback *
wb_get_create_current(struct backing_dev_info *bdi, gfp_t gfp)
{
	return &bdi->wb;
}

static inline bool inode_to_wb_is_valid(struct inode *inode)
{
	return true;
}

static inline struct bdi_writeback *inode_to_wb(struct inode *inode)
{
	return &inode_to_bdi(inode)->wb;
}

static inline struct bdi_writeback *inode_to_wb_wbc(
				struct inode *inode,
				struct writeback_control *wbc)
{
	return inode_to_wb(inode);
}


static inline struct bdi_writeback *
unlocked_inode_to_wb_begin(struct inode *inode, struct wb_lock_cookie *cookie)
{
	return inode_to_wb(inode);
}

static inline void unlocked_inode_to_wb_end(struct inode *inode,
					    struct wb_lock_cookie *cookie)
{
}

static inline void wb_memcg_offline(struct mem_cgroup *memcg)
{
}

static inline void wb_blkcg_offline(struct cgroup_subsys_state *css)
{
}

#endif	/* _LINUX_BACKING_DEV_H */
