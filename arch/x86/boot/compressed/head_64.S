	.text

/*
 * Locally defined symbols should be marked hidden:
 */
	.hidden _bss
	.hidden _ebss
	.hidden _end

	.section ".head.text","ax"

	.code32

startup_32:
	/*
	 * 32bit entry is 0 and it is ABI so immutable!
	 * If we come here directly from a bootloader,
	 * kernel(text+data+bss+brk) ramdisk, zero_page, command line
	 * all need to be under the 4G limit.
	 */
	cld
	cli

/*
 * Calculate the delta between where we were compiled to run
 * at and where we were actually loaded at.  This can only be done
 * with a short local call on x86.  Nothing  else will tell us what
 * address we are running at.  The reserved chunk of the real-mode
 * data at 0x1e4 (defined as a scratch field) are used as the stack
 * for this calculation. Only 4 bytes are needed.
 */
	leal	(484 + 4)(%esi), %esp
	call	1f
1:
	popl	%ebp
	subl	$1b, %ebp

	/* Load new GDT with the 64bit segments using 32bit descriptor */
	leal	gdt(%ebp), %eax
	movl	%eax, 2(%eax)
	lgdt	(%eax)

	/* Load segment registers with our descriptors */
	movl	$(3*8), %eax
	movl	%eax, %ds
	movl	%eax, %es
	movl	%eax, %fs
	movl	%eax, %gs
	movl	%eax, %ss

	pushl	$(1*8)
	leal	1f(%ebp), %eax
	pushl	%eax
	lretl

1:	movl	$0x200000, %ebx

	/* Target address to relocate to for decompression */
	addl	608(%esi), %ebx
	subl	$_end, %ebx

/*
 * Prepare for entering 64 bit mode
 */

	/* Enable PAE mode */
	movl	%cr4, %eax
	orl	$32, %eax
	movl	%eax, %cr4

 /*
  * Build early 4G boot pagetable
  */
	/* Initialize Page tables to 0 */
	leal	pgtable(%ebx), %edi
	xorl	%eax, %eax
	movl	$((6*4096)/4), %ecx
	rep	stosl

	/* Build Level 4 */
	leal	pgtable + 0(%ebx), %edi
	leal	0x1007 (%edi), %eax
	movl	%eax, 0(%edi)

	/* Build Level 3 */
	leal	pgtable + 0x1000(%ebx), %edi
	leal	0x1007(%edi), %eax
	movl	$4, %ecx
1:	movl	%eax, 0x00(%edi)
	addl	$0x00001000, %eax
	addl	$8, %edi
	decl	%ecx
	jnz	1b

	/* Build Level 2 */
	leal	pgtable + 0x2000(%ebx), %edi
	movl	$0x00000183, %eax
	movl	$2048, %ecx
1:	movl	%eax, 0(%edi)
	addl	$0x00200000, %eax
	addl	$8, %edi
	decl	%ecx
	jnz	1b

	/* Enable the boot page tables */
	leal	pgtable(%ebx), %eax
	movl	%eax, %cr3

	/* Enable Long mode in EFER (Extended Feature Enable Register) */
	movl	$0xc0000080, %ecx
	rdmsr
	btsl	$8, %eax
	wrmsr

	/* After gdt is loaded */
	xorl	%eax, %eax
	lldt	%ax
	movl	$(4*8), %eax
	ltr	%ax

	/*
	 * Setup for the jump to 64bit mode
	 *
	 * When the jump is performed we will be in long mode but
	 * in 32bit compatibility mode with EFER.LME = 1, CS.L = 0, CS.D = 1
	 * (and in turn EFER.LMA = 1).	To jump into 64bit mode we use
	 * the new gdt/idt that has __KERNEL_CS with CS.L = 1.
	 * We place all of the values on our mini stack so lret can
	 * used to perform that far jump.
	 */
	leal	startup_64(%ebp), %eax

	pushl	$(2*8)
	pushl	%eax

	/* Enter paged protected Mode, activating Long Mode */
	movl	$(((1) << (0)) | ((1) << (1)) | ((1) << (4)) | ((1) << (5)) | ((1) << (16)) | ((1) << (18)) | ((1) << (31))), %eax
	movl	%eax, %cr0

	/* Jump from 32bit compatibility mode into 64bit mode. */
	lret

	.code64
	.org 0x200
startup_64:
	/*
	 * 64bit entry is 0x200 and it is ABI so immutable!
	 * We come here either from startup_32 or directly from a
	 * 64bit bootloader.
	 * If we come here from a bootloader, kernel(text+data+bss+brk),
	 * ramdisk, zero_page, command line could be above 4G.
	 * We depend on an identity mapped page table being provided
	 * that maps our entire kernel(text+data+bss+brk), zero page
	 * and command line.
	 */
	cld
	cli

	/* Setup data segments. */
	xorl	%eax, %eax
	movl	%eax, %ds
	movl	%eax, %es
	movl	%eax, %ss
	movl	%eax, %fs
	movl	%eax, %gs

	/*
	 * Compute the decompressed kernel start address.  It is where
	 * we were loaded at aligned to a 2M boundary. %rbp contains the
	 * decompressed kernel start address.
	 *
	 * If it is a relocatable kernel then decompress and run the kernel
	 * from load address aligned to 2MB addr, otherwise decompress and
	 * run the kernel from LOAD_PHYSICAL_ADDR
	 *
	 * We cannot rely on the calculation done in 32-bit mode, since we
	 * may have been invoked via the 64-bit entry point.
	 */

	/* Start with the delta to where the kernel will run at. */
	movq	$0x200000, %rbp

	/* Target address to relocate to for decompression */
	movl	608(%rsi), %ebx
	subl	$_end, %ebx
	addq	%rbp, %rbx

	/*
	 * At this point we are in long mode with 4-level paging enabled,
	 * but we might want to enable 5-level paging or vice versa.
	 *
	 * The problem is that we cannot do it directly. Setting or clearing
	 * CR4.LA57 in long mode would trigger #GP. So we need to switch off
	 * long mode and paging first.
	 *
	 * We also need a trampoline in lower memory to switch over from
	 * 4- to 5-level paging for cases when the bootloader puts the kernel
	 * above 4G, but didn't enable 5-level paging for us.
	 *
	 * The same trampoline can be used to switch from 5- to 4-level paging
	 * mode, like when starting 4-level paging kernel via kexec() when
	 * original kernel worked in 5-level paging mode.
	 *
	 * For the trampoline, we need the top page table to reside in lower
	 * memory as we don't have a way to load 64-bit values into CR3 in
	 * 32-bit mode.
	 *
	 * We go though the trampoline even if we don't have to: if we're
	 * already in a desired paging mode. This way the trampoline code gets
	 * tested on every boot.
	 */

	/* Make sure we have GDT with 32-bit code segment */
	leaq	gdt64(%rip), %rax
	addq	%rax, 2(%rax)
	lgdt	(%rax)

	/*
	 * paging_prepare() sets up the trampoline and checks if we need to
	 * enable 5-level paging.
	 *
	 * paging_prepare() returns a two-quadword structure which lands
	 * into RDX:RAX:
	 *   - Address of the trampoline is returned in RAX.
	 *   - Non zero RDX means trampoline needs to enable 5-level
	 *     paging.
	 *
	 * RSI holds real mode data and needs to be preserved across
	 * this function call.
	 */
	pushq	%rsi
	call	paging_prepare
	popq	%rsi
	movq	$0x9d000, %rax

	/* Save the trampoline address in RCX */
	movq	%rax, %rcx

	/*
	 * Load the address of trampoline_return() into RDI.
	 * It will be used by the trampoline to return to the main code.
	 */
	leaq	trampoline_return(%rip), %rdi

	/* Switch to compatibility mode (CS.L = 0 CS.D = 1) via far return */
	pushq	$(1*8)
	leaq	(1 << 12)(%rax), %rax
	pushq	%rax
	lretq

trampoline_return:
/*
 * Copy the compressed kernel to the end of our buffer
 * where decompression in place becomes safe.
 */
	pushq	%rsi
	leaq	(_bss-8)(%rip), %rsi
	leaq	_bss-8(%rbx), %rdi
	movl	$(_bss - startup_32), %ecx
	shrl	$3, %ecx
	std
	rep	movsq
	cld
	popq	%rsi

/*
 * Jump to the relocated address.
 */
	leaq	.Lrelocated(%rbx), %rax
	jmp	*%rax

	.text

.Lrelocated:
/*
 * Do the extraction, and jump to the new kernel..
 */
	pushq	%rsi
	movq	%rsi, %rdi
	leaq	boot_heap(%rip), %rsi
	leaq	input_data(%rip), %rdx
	movl	input_len(%rip), %ecx
	movq	%rbp, %r8
	movl	output_len(%rip), %r9d
	call	extract_kernel
	popq	%rsi

/*
 * Jump to the decompressed kernel.
 */
	jmp	*%rax

	.code32
/*
 * This is the 32-bit trampoline that will be copied over to low memory.
 *
 * RDI contains the return address (might be above 4G).
 * ECX contains the base address of the trampoline memory.
 * Non zero RDX means trampoline needs to enable 5-level paging.
 */
	.globl trampoline_32bit_src
trampoline_32bit_src:
	/* Set up data and stack segments */
	movl	$(3*8), %eax
	movl	%eax, %ds
	movl	%eax, %ss

	/* Set up new stack */
	leal	(2 * (1 << 12))(%ecx), %esp

	/* Calculate address of paging_enabled() once we are executing in the trampoline */
	leal	.Lpaging_enabled - trampoline_32bit_src + (1 << 12)(%ecx), %eax

	/* Prepare the stack for far return to Long Mode */
	pushl	$(2*8)
	pushl	%eax
	lret

	.code64
.Lpaging_enabled:
	/* Return from the trampoline */
	jmp	*%rdi

	.code32
	.data
gdt64:
	.word	gdt_end - gdt - 1
	.quad	gdt - gdt64

gdt:
	.word	gdt_end - gdt - 1
	.long	0
	.word	0
	.quad	0x00cf9a000000ffff	/* __KERNEL32_CS */
	.quad	0x00af9a000000ffff	/* __KERNEL_CS */
	.quad	0x00cf92000000ffff	/* __KERNEL_DS */
	.quad	0x0080890000000000	/* TS descriptor */

gdt_end:

/*
 * Stack and heap for uncompression
 */
	.bss
boot_heap:
	.fill	0x10000, 1, 0

/*
 * Space for page tables (not in .bss so not zeroed)
 */
	.section ".pgtable","aw",@nobits
pgtable:
	.fill	(6*4096), 1, 0
