// SPDX-License-Identifier: GPL-2.0
/*
 * The class-specific portions of the driver model
 *
 * Copyright (c) 2001-2003 Patrick Mochel <mochel@osdl.org>
 * Copyright (c) 2004-2009 Greg Kroah-Hartman <gregkh@suse.de>
 * Copyright (c) 2008-2009 Novell Inc.
 * Copyright (c) 2012-2019 Greg Kroah-Hartman <gregkh@linuxfoundation.org>
 * Copyright (c) 2012-2019 Linux Foundation
 *
 * See Documentation/driver-api/driver-model/ for more information.
 */

#ifndef _DEVICE_CLASS_H_
#define _DEVICE_CLASS_H_

#include <linux/kobject.h>
#include <linux/klist.h>
#include <linux/pm.h>
#include <linux/device/bus.h>

struct device;
struct fwnode_handle;

/**
 * struct class - device classes
 * @name:	Name of the class.
 * @owner:	The module owner.
 * @class_groups: Default attributes of this class.
 * @dev_groups:	Default attributes of the devices that belong to the class.
 * @dev_kobj:	The kobject that represents this class and links it into the hierarchy.
 * @dev_uevent:	Called when a device is added, removed from this class, or a
 *		few other things that generate uevents to add the environment
 *		variables.
 * @devnode:	Callback to provide the devtmpfs.
 * @class_release: Called to release this class.
 * @dev_release: Called to release the device.
 * @shutdown_pre: Called at shut-down time before driver shutdown.
 * @ns_type:	Callbacks so sysfs can detemine namespaces.
 * @namespace:	Namespace of the device belongs to this class.
 * @get_ownership: Allows class to specify uid/gid of the sysfs directories
 *		for the devices belonging to the class. Usually tied to
 *		device's namespace.
 * @pm:		The default device power management operations of this class.
 * @p:		The private data of the driver core, no one other than the
 *		driver core can touch this.
 *
 * A class is a higher-level view of a device that abstracts out low-level
 * implementation details. Drivers may see a SCSI disk or an ATA disk, but,
 * at the class level, they are all simply disks. Classes allow user space
 * to work with devices based on what they do, rather than how they are
 * connected or how they work.
 */
struct class {
	const char		*name;
	struct module		*owner;

	const void *(*namespace)(struct device *dev);

	const struct dev_pm_ops *pm;

	struct subsys_private *p;
};

extern struct device *class_find_device(struct class *class,
					struct device *start, const void *data,
					int (*match)(struct device *, const void *));

/**
 * class_find_device_by_name - device iterator for locating a particular device
 * of a specific name.
 * @class: class type
 * @name: name of the device to match
 */
static inline struct device *class_find_device_by_name(struct class *class,
						       const char *name)
{
	return class_find_device(class, NULL, name, device_match_name);
}

/**
 * class_find_device_by_of_node : device iterator for locating a particular device
 * matching the of_node.
 * @class: class type
 * @np: of_node of the device to match.
 */
static inline struct device *
class_find_device_by_of_node(struct class *class, const struct device_node *np)
{
	return class_find_device(class, NULL, np, device_match_of_node);
}

/**
 * class_find_device_by_fwnode : device iterator for locating a particular device
 * matching the fwnode.
 * @class: class type
 * @fwnode: fwnode of the device to match.
 */
static inline struct device *
class_find_device_by_fwnode(struct class *class,
			    const struct fwnode_handle *fwnode)
{
	return class_find_device(class, NULL, fwnode, device_match_fwnode);
}

/**
 * class_find_device_by_devt : device iterator for locating a particular device
 * matching the device type.
 * @class: class type
 * @devt: device type of the device to match.
 */
static inline struct device *class_find_device_by_devt(struct class *class,
						       dev_t devt)
{
	return class_find_device(class, NULL, &devt, device_match_devt);
}

static inline struct device *
class_find_device_by_acpi_dev(struct class *class, const void *adev)
{
	return NULL;
}

struct class_attribute {
	struct attribute attr;
	ssize_t (*show)(struct class *class, struct class_attribute *attr,
			char *buf);
	ssize_t (*store)(struct class *class, struct class_attribute *attr,
			const char *buf, size_t count);
};

extern int __must_check class_create_file_ns(struct class *class,
					     const struct class_attribute *attr,
					     const void *ns);
extern void class_remove_file_ns(struct class *class,
				 const struct class_attribute *attr,
				 const void *ns);

static inline int __must_check class_create_file(struct class *class,
					const struct class_attribute *attr)
{
	return class_create_file_ns(class, attr, NULL);
}

static inline void class_remove_file(struct class *class,
				     const struct class_attribute *attr)
{
	return class_remove_file_ns(class, attr, NULL);
}

extern struct class * __must_check __class_create(struct module *owner,
						  const char *name,
						  struct lock_class_key *key);

#endif	/* _DEVICE_CLASS_H_ */
