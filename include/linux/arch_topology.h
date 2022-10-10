/* SPDX-License-Identifier: GPL-2.0 */
/*
 * include/linux/arch_topology.h - arch specific cpu topology information
 */
#ifndef _LINUX_ARCH_TOPOLOGY_H_
#define _LINUX_ARCH_TOPOLOGY_H_

#include <linux/types.h>
#include <linux/percpu.h>

struct device_node;

DECLARE_PER_CPU(unsigned long, cpu_scale);

static inline unsigned long topology_get_cpu_scale(int cpu)
{
	return per_cpu(cpu_scale, cpu);
}

DECLARE_PER_CPU(unsigned long, arch_freq_scale);

static inline unsigned long topology_get_freq_scale(int cpu)
{
	return per_cpu(arch_freq_scale, cpu);
}

DECLARE_PER_CPU(unsigned long, thermal_pressure);

static inline unsigned long topology_get_thermal_pressure(int cpu)
{
	return per_cpu(thermal_pressure, cpu);
}

#endif /* _LINUX_ARCH_TOPOLOGY_H_ */
