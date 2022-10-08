// SPDX-License-Identifier: GPL-2.0
/*
 * linux/mm/mmzone.c
 *
 * management codes for pgdats, zones and page flags
 */


#include <linux/stddef.h>
#include <linux/mmzone.h>

struct pglist_data *first_online_pgdat(void)
{
	return NODE_DATA(first_online_node);
}

struct pglist_data *next_online_pgdat(struct pglist_data *pgdat)
{
	return NULL;
}

/*
 * next_zone - helper magic for for_each_zone()
 */
struct zone *next_zone(struct zone *zone)
{
	return NULL;
}

static inline int zref_in_nodemask(struct zoneref *zref, nodemask_t *nodes)
{
	return 1;
}

/* Returns the next zone at or below highest_zoneidx in a zonelist */
struct zoneref *__next_zones_zonelist(struct zoneref *z,
					enum zone_type highest_zoneidx,
					nodemask_t *nodes)
{
	/*
	 * Find the next suitable zone to use for the allocation.
	 * Only filter based on nodemask if it's set
	 */
	if (unlikely(nodes == NULL))
		while (zonelist_zone_idx(z) > highest_zoneidx)
			z++;
	else
		while (zonelist_zone_idx(z) > highest_zoneidx ||
				(z->zone && !zref_in_nodemask(z, nodes)))
			z++;

	return z;
}
