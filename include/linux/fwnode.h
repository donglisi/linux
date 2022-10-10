/* SPDX-License-Identifier: GPL-2.0-only */
/*
 * fwnode.h - Firmware device node object handle type definition.
 *
 * Copyright (C) 2015, Intel Corporation
 * Author: Rafael J. Wysocki <rafael.j.wysocki@intel.com>
 */

#ifndef _LINUX_FWNODE_H_
#define _LINUX_FWNODE_H_

#include <linux/types.h>
#include <linux/list.h>
#include <linux/bits.h>
#include <linux/err.h>

struct fwnode_operations;
struct device;

#define FWNODE_FLAG_INITIALIZED			BIT(2)

struct fwnode_handle {
	const struct fwnode_operations *ops;
	struct device *dev;
	struct list_head suppliers;
	struct list_head consumers;
	u8 flags;
};

/**
 * struct fwnode_endpoint - Fwnode graph endpoint
 * @port: Port number
 * @id: Endpoint id
 * @local_fwnode: reference to the related fwnode
 */
struct fwnode_endpoint {
	unsigned int port;
	unsigned int id;
	const struct fwnode_handle *local_fwnode;
};

/*
 * ports and endpoints defined as software_nodes should all follow a common
 * naming scheme; use these macros to ensure commonality.
 */
#define SWNODE_GRAPH_PORT_NAME_FMT		"port@%u"
#define SWNODE_GRAPH_ENDPOINT_NAME_FMT		"endpoint@%u"

#define NR_FWNODE_REFERENCE_ARGS	8

/**
 * struct fwnode_reference_args - Fwnode reference with additional arguments
 * @fwnode:- A reference to the base fwnode
 * @nargs: Number of elements in @args array
 * @args: Integer arguments on the fwnode
 */
struct fwnode_reference_args {
	struct fwnode_handle *fwnode;
	unsigned int nargs;
	u64 args[NR_FWNODE_REFERENCE_ARGS];
};

/**
 * struct fwnode_operations - Operations for fwnode interface
 * @get: Get a reference to an fwnode.
 * @put: Put a reference to an fwnode.
 * @device_is_available: Return true if the device is available.
 * @device_get_match_data: Return the device driver match data.
 * @property_present: Return true if a property is present.
 * @property_read_int_array: Read an array of integer properties. Return zero on
 *			     success, a negative error code otherwise.
 * @property_read_string_array: Read an array of string properties. Return zero
 *				on success, a negative error code otherwise.
 * @get_name: Return the name of an fwnode.
 * @get_name_prefix: Get a prefix for a node (for printing purposes).
 * @get_parent: Return the parent of an fwnode.
 * @get_next_child_node: Return the next child node in an iteration.
 * @get_named_child_node: Return a child node with a given name.
 * @get_reference_args: Return a reference pointed to by a property, with args
 * @graph_get_next_endpoint: Return an endpoint node in an iteration.
 * @graph_get_remote_endpoint: Return the remote endpoint node of a local
 *			       endpoint node.
 * @graph_get_port_parent: Return the parent node of a port node.
 * @graph_parse_endpoint: Parse endpoint for port and endpoint id.
 * @add_links:	Create fwnode links to all the suppliers of the fwnode. Return
 *		zero on success, a negative error code otherwise.
 */
struct fwnode_operations {
	struct fwnode_handle *(*get)(struct fwnode_handle *fwnode);
	void (*put)(struct fwnode_handle *fwnode);
};

static inline void fwnode_init(struct fwnode_handle *fwnode,
			       const struct fwnode_operations *ops)
{
	fwnode->ops = ops;
	INIT_LIST_HEAD(&fwnode->consumers);
	INIT_LIST_HEAD(&fwnode->suppliers);
}

static inline void fwnode_dev_initialized(struct fwnode_handle *fwnode,
					  bool initialized)
{
	if (IS_ERR_OR_NULL(fwnode))
		return;

	if (initialized)
		fwnode->flags |= FWNODE_FLAG_INITIALIZED;
	else
		fwnode->flags &= ~FWNODE_FLAG_INITIALIZED;
}

#endif
