// SPDX-License-Identifier: GPL-2.0
/*
 * The driver-specific portions of the driver model
 *
 * Copyright (c) 2001-2003 Patrick Mochel <mochel@osdl.org>
 * Copyright (c) 2004-2009 Greg Kroah-Hartman <gregkh@suse.de>
 * Copyright (c) 2008-2009 Novell Inc.
 * Copyright (c) 2012-2019 Greg Kroah-Hartman <gregkh@linuxfoundation.org>
 * Copyright (c) 2012-2019 Linux Foundation
 *
 * See Documentation/driver-api/driver-model/ for more information.
 */

#ifndef _DEVICE_DRIVER_H_
#define _DEVICE_DRIVER_H_

#include <linux/kobject.h>
#include <linux/klist.h>
#include <linux/pm.h>
#include <linux/device/bus.h>

/**
 * enum probe_type - device driver probe type to try
 *	Device drivers may opt in for special handling of their
 *	respective probe routines. This tells the core what to
 *	expect and prefer.
 *
 * @PROBE_DEFAULT_STRATEGY: Used by drivers that work equally well
 *	whether probed synchronously or asynchronously.
 * @PROBE_PREFER_ASYNCHRONOUS: Drivers for "slow" devices which
 *	probing order is not essential for booting the system may
 *	opt into executing their probes asynchronously.
 * @PROBE_FORCE_SYNCHRONOUS: Use this to annotate drivers that need
 *	their probe routines to run synchronously with driver and
 *	device registration (with the exception of -EPROBE_DEFER
 *	handling - re-probing always ends up being done asynchronously).
 *
 * Note that the end goal is to switch the kernel to use asynchronous
 * probing by default, so annotating drivers with
 * %PROBE_PREFER_ASYNCHRONOUS is a temporary measure that allows us
 * to speed up boot process while we are validating the rest of the
 * drivers.
 */
enum probe_type {
	PROBE_DEFAULT_STRATEGY,
	PROBE_PREFER_ASYNCHRONOUS,
	PROBE_FORCE_SYNCHRONOUS,
};

/**
 * struct device_driver - The basic device driver structure
 * @name:	Name of the device driver.
 * @bus:	The bus which the device of this driver belongs to.
 * @owner:	The module owner.
 * @mod_name:	Used for built-in modules.
 * @suppress_bind_attrs: Disables bind/unbind via sysfs.
 * @probe_type:	Type of the probe (synchronous or asynchronous) to use.
 * @of_match_table: The open firmware table.
 * @acpi_match_table: The ACPI match table.
 * @probe:	Called to query the existence of a specific device,
 *		whether this driver can work with it, and bind the driver
 *		to a specific device.
 * @sync_state:	Called to sync device state to software state after all the
 *		state tracking consumers linked to this device (present at
 *		the time of late_initcall) have successfully bound to a
 *		driver. If the device has no consumers, this function will
 *		be called at late_initcall_sync level. If the device has
 *		consumers that are never bound to a driver, this function
 *		will never get called until they do.
 * @remove:	Called when the device is removed from the system to
 *		unbind a device from this driver.
 * @shutdown:	Called at shut-down time to quiesce the device.
 * @suspend:	Called to put the device to sleep mode. Usually to a
 *		low power state.
 * @resume:	Called to bring a device from sleep mode.
 * @groups:	Default attributes that get created by the driver core
 *		automatically.
 * @dev_groups:	Additional attributes attached to device instance once
 *		it is bound to the driver.
 * @pm:		Power management operations of the device which matched
 *		this driver.
 * @coredump:	Called when sysfs entry is written to. The device driver
 *		is expected to call the dev_coredump API resulting in a
 *		uevent.
 * @p:		Driver core's private data, no one other than the driver
 *		core can touch this.
 *
 * The device driver-model tracks all of the drivers known to the system.
 * The main reason for this tracking is to enable the driver core to match
 * up drivers with new devices. Once drivers are known objects within the
 * system, however, a number of other things become possible. Device drivers
 * can export information and configuration variables that are independent
 * of any specific device.
 */
struct device_driver {
	const char		*name;
	struct bus_type		*bus;

	struct module		*owner;

	void (*sync_state)(struct device *dev);
	int (*remove) (struct device *dev);
	int (*suspend) (struct device *dev, pm_message_t state);
	int (*resume) (struct device *dev);
	const struct attribute_group **groups;

	struct driver_private *p;
};

struct device *driver_find_device(struct device_driver *drv,
				  struct device *start, const void *data,
				  int (*match)(struct device *dev, const void *data));

/**
 * driver_find_device_by_name - device iterator for locating a particular device
 * of a specific name.
 * @drv: the driver we're iterating
 * @name: name of the device to match
 */
static inline struct device *driver_find_device_by_name(struct device_driver *drv,
							const char *name)
{
	return driver_find_device(drv, NULL, name, device_match_name);
}

/**
 * driver_find_device_by_of_node- device iterator for locating a particular device
 * by of_node pointer.
 * @drv: the driver we're iterating
 * @np: of_node pointer to match.
 */
static inline struct device *
driver_find_device_by_of_node(struct device_driver *drv,
			      const struct device_node *np)
{
	return driver_find_device(drv, NULL, np, device_match_of_node);
}

/**
 * driver_find_device_by_fwnode- device iterator for locating a particular device
 * by fwnode pointer.
 * @drv: the driver we're iterating
 * @fwnode: fwnode pointer to match.
 */
static inline struct device *
driver_find_device_by_fwnode(struct device_driver *drv,
			     const struct fwnode_handle *fwnode)
{
	return driver_find_device(drv, NULL, fwnode, device_match_fwnode);
}

/**
 * driver_find_device_by_devt- device iterator for locating a particular device
 * by devt.
 * @drv: the driver we're iterating
 * @devt: devt pointer to match.
 */
static inline struct device *driver_find_device_by_devt(struct device_driver *drv,
							dev_t devt)
{
	return driver_find_device(drv, NULL, &devt, device_match_devt);
}

static inline struct device *driver_find_next_device(struct device_driver *drv,
						     struct device *start)
{
	return driver_find_device(drv, start, NULL, device_match_any);
}

static inline struct device *
driver_find_device_by_acpi_dev(struct device_driver *drv, const void *adev)
{
	return NULL;
}

#endif	/* _DEVICE_DRIVER_H_ */
