#include <linux/pe.h>
#include <asm/segment.h>
#include <asm/boot.h>
#include <asm/page_types.h>
#include <asm/setup.h>
#include <asm/bootparam.h>
#include "boot.h"
#include "zoffset.h"

BOOTSEG		= 0x07C0		/* original address of boot-sector */
SYSSEG		= 0x1000		/* historical load address >> 4 */

	.code16
	.section ".bstext", "ax"

bootsect_start:
	.section ".bsdata", "a"
bugger_off_msg:
	.ascii	"Use a boot loader.\r\n"
	.ascii	"\n"
	.ascii	"Remove disk and press any key to reboot...\r\n"
	.byte	0

	.section ".header", "a"
	.globl	sentinel
sentinel:	.byte 0xff, 0xff        /* Used to detect broken loaders */

	.globl	hdr
hdr:
setup_sects:	.byte 0			/* Filled in by build.c */
root_flags:	.word 0
syssize:	.long 0			/* Filled in by build.c */
ram_size:	.word 0			/* Obsolete */
vid_mode:	.word 0
root_dev:	.word 0			/* Filled in by build.c */
boot_flag:	.word 0xAA55

	# offset 512, entry point

	.globl	_start
_start:
		# Explicitly enter this as bytes, or the assembler
		# tries to generate a 3-byte jump here, which causes
		# everything else to push off to the wrong offset.
		.byte	0xeb		# short (2-byte) jump
		.byte	start_of_setup-1f
1:

	# Part 2 of the header, from the old setup.S
		.ascii	"HdrS"		# header signature
		.word	0x020f		# header version number (>= 0x0105)
		.globl realmode_swtch
realmode_swtch:	.word	0, 0		# default_switch, SETUPSEG
start_sys_seg:	.word	SYSSEG		# obsolete and meaningless, but just
		.word	0 # pointing to kernel version string
type_of_loader:	.byte	0		# 0 means ancient bootloader, newer
loadflags:
		.byte	LOADED_HIGH	# The kernel is to be loaded high

setup_move_size: .word  0x8000		# size to move, when setup is not
code32_start:				# here loaders can put a different
		.long	0x100000	# 0x100000 = default for big kernel

ramdisk_image:	.long	0		# address of loaded ramdisk image
ramdisk_size:	.long	0		# its size in bytes

bootsect_kludge:
		.long	0		# obsolete

heap_end_ptr:	.word	_end+STACK_SIZE-512
ext_loader_ver:
		.byte	0		# Extended boot loader version
ext_loader_type:
		.byte	0		# Extended boot loader type

cmd_line_ptr:	.long	0
initrd_addr_max: .long 0x7fffffff
kernel_alignment:  .long CONFIG_PHYSICAL_ALIGN	#physical addr alignment
						#required for protected mode
						#kernel
relocatable_kernel:    .byte 0
min_alignment:		.byte MIN_KERNEL_ALIGN_LG2	# minimum alignment

xloadflags:		.word 0

cmdline_size:   .long   COMMAND_LINE_SIZE-1     #length of the command line,
                                                #added with boot protocol
                                                #version 2.06

hardware_subarch:	.long 0			# subarchitecture, added with 2.07
						# default to 0 for normal x86 PC

hardware_subarch_data:	.quad 0

payload_offset:		.long 0
payload_length:		.long 0

setup_data:		.quad 0			# 64-bit physical pointer to
						# single linked list of
						# struct setup_data

pref_address:		.quad LOAD_PHYSICAL_ADDR	# preferred load addr

#define ZO_z_extra_bytes	((ZO_z_output_len >> 8) + 131072)
#if ZO_z_output_len > ZO_z_input_len
# define ZO_z_extract_offset	(ZO_z_output_len + ZO_z_extra_bytes - \
				 ZO_z_input_len)
#else
# define ZO_z_extract_offset	ZO_z_extra_bytes
#endif

/*
 * The extract_offset has to be bigger than ZO head section. Otherwise when
 * the head code is running to move ZO to the end of the buffer, it will
 * overwrite the head code itself.
 */
#if (ZO__ehead - ZO_startup_32) > ZO_z_extract_offset
# define ZO_z_min_extract_offset ((ZO__ehead - ZO_startup_32 + 4095) & ~4095)
#else
# define ZO_z_min_extract_offset ((ZO_z_extract_offset + 4095) & ~4095)
#endif

#define ZO_INIT_SIZE	(ZO__end - ZO_startup_32 + ZO_z_min_extract_offset)

#define VO_INIT_SIZE	(VO__end - VO__text)
#if ZO_INIT_SIZE > VO_INIT_SIZE
# define INIT_SIZE ZO_INIT_SIZE
#else
# define INIT_SIZE VO_INIT_SIZE
#endif

init_size:		.long INIT_SIZE		# kernel initialization size
handover_offset:	.long 0			# Filled in by build.c
kernel_info_offset:	.long 0			# Filled in by build.c

# End of setup header #####################################################

	.section ".entrytext", "ax"
start_of_setup:
	calll	main
