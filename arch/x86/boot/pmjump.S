	.text
	.code16

	.globl protected_mode_jump
protected_mode_jump:
	movl	%eax, %esi # Pointer to boot_params table

	movw	$(3*8), %cx

	movl	%cr0, %edx
	orb	$((1) << (0)), %dl # Protected mode
	movl	%edx, %cr0

	addl	$0x10000, 2f
	# Transition to 32-bit mode
	.byte 0x66, 0xea # ljmpl opcode
2:	.long .Lin_pm32 # offset
	.word (2*8) # segment

	.code32
	.section ".text32","ax"
.Lin_pm32:
	# Set up data segments for flat 32-bit mode
	movl	%ecx, %ds
	movl	%ecx, %es
	movl	%ecx, %fs
	movl	%ecx, %gs
	movl	%ecx, %ss

	# Clear registers to allow for future extensions to the
	# 32-bit boot protocol
	xorl	%ecx, %ecx
	xorl	%edx, %edx
	xorl	%ebx, %ebx
	xorl	%ebp, %ebp
	xorl	%edi, %edi

	mov	$0x100000, %eax
	jmpl	*%eax # Jump to the 32-bit entrypoint
