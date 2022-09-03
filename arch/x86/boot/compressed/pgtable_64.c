#include "misc.h"
#include <asm/e820/types.h>
#include <asm/processor.h>
#include "pgtable.h"
#include "../string.h"

void paging_prepare(void)
{
	unsigned long *trampoline_32bit;

	trampoline_32bit = (unsigned long *)0x9d000;

	/* Clear trampoline memory first */
	memset(trampoline_32bit, 0, TRAMPOLINE_32BIT_SIZE);

	/* Copy trampoline code in place */
	memcpy(trampoline_32bit + TRAMPOLINE_32BIT_CODE_OFFSET / sizeof(unsigned long),
			&trampoline_32bit_src, TRAMPOLINE_32BIT_CODE_SIZE);
}
