/* SPDX-License-Identifier: GPL-2.0 */
/*
 * Floating proportions with flexible aging period
 *
 *  Copyright (C) 2011, SUSE, Jan Kara <jack@suse.cz>
 */

#ifndef _LINUX_FLEX_PROPORTIONS_H
#define _LINUX_FLEX_PROPORTIONS_H

#include <linux/percpu_counter.h>
#include <linux/spinlock.h>
#include <linux/seqlock.h>
#include <linux/gfp.h>

/*
 * ---- Global proportion definitions ----
 */
struct fprop_global {
	/* Number of events in the current period */
	struct percpu_counter events;
	/* Current period */
	unsigned int period;
	/* Synchronization with period transitions */
	seqcount_t sequence;
};

/*
 *  ---- SINGLE ----
 */
struct fprop_local_single {
	/* the local events counter */
	unsigned long events;
	/* Period in which we last updated events */
	unsigned int period;
	raw_spinlock_t lock;	/* Protect period and numerator */
};

void __fprop_inc_single(struct fprop_global *p, struct fprop_local_single *pl);

static inline
void fprop_inc_single(struct fprop_global *p, struct fprop_local_single *pl)
{
	unsigned long flags;

	local_irq_save(flags);
	__fprop_inc_single(p, pl);
	local_irq_restore(flags);
}

/*
 * ---- PERCPU ----
 */
struct fprop_local_percpu {
	/* the local events counter */
	struct percpu_counter events;
	/* Period in which we last updated events */
	unsigned int period;
	raw_spinlock_t lock;	/* Protect period and numerator */
};

void __fprop_add_percpu(struct fprop_global *p, struct fprop_local_percpu *pl,
		long nr);

static inline
void fprop_inc_percpu(struct fprop_global *p, struct fprop_local_percpu *pl)
{
	unsigned long flags;

	local_irq_save(flags);
	__fprop_add_percpu(p, pl, 1);
	local_irq_restore(flags);
}

#endif
