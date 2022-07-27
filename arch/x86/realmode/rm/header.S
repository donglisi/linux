/* SPDX-License-Identifier: GPL-2.0 */
/*
 * Real-mode blob header; this should match realmode.h and be
 * readonly; for mutable data instead add pointers into the .data
 * or .bss sections as appropriate.
 */

#include <linux/linkage.h>
#include <asm/page_types.h>
#include <asm/segment.h>

#include "realmode.h"
	
	.section ".header", "a"

	.balign	16
SYM_DATA_START(real_mode_header)
SYM_DATA_END(real_mode_header)

	/* End signature, used to verify integrity */
	.section ".signature","a"
	.balign 4
SYM_DATA(end_signature, .long REALMODE_END_SIGNATURE)
