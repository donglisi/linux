// SPDX-License-Identifier: GPL-2.0-or-later
/*
 * printk_safe.c - Safe printk for printk-deadlock-prone contexts
 */

#include <linux/preempt.h>
#include <linux/printk.h>

#include "internal.h"

static DEFINE_PER_CPU(int, printk_context);

/* Can be preempted by NMI. */
void __printk_safe_enter(void)
{
	this_cpu_inc(printk_context);
}

/* Can be preempted by NMI. */
void __printk_safe_exit(void)
{
	this_cpu_dec(printk_context);
}

asmlinkage int vprintk(const char *fmt, va_list args)
{

	/*
	 * Use the main logbuf even in NMI. But avoid calling console
	 * drivers that might have their own locks.
	 */
	if (this_cpu_read(printk_context) || in_nmi()) {
		int len;

		len = vprintk_store(0, LOGLEVEL_DEFAULT, NULL, fmt, args);
		defer_console_output();
		return len;
	}

	/* No obstacles. */
	return vprintk_default(fmt, args);
}
