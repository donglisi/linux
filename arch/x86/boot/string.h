/* SPDX-License-Identifier: GPL-2.0 */
#ifndef BOOT_STRING_H
#define BOOT_STRING_H

#define memcpy(d,s,l) __builtin_memcpy(d,s,l)
#define memset(d,c,l) __builtin_memset(d,c,l)

#endif /* BOOT_STRING_H */
