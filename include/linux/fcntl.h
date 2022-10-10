/* SPDX-License-Identifier: GPL-2.0 */
#ifndef _LINUX_FCNTL_H
#define _LINUX_FCNTL_H

#include <linux/stat.h>
#include <uapi/linux/fcntl.h>

#ifndef force_o_largefile
#define force_o_largefile() (!IS_ENABLED(CONFIG_ARCH_32BIT_OFF_T))
#endif

#endif
