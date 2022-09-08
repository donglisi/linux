	.text
	.section ".head.text","ax"
	.code64

	.globl startup_64
startup_64:
	leaq	(__end_init_task - 168)(%rip), %rsp
	leaq	_text(%rip), %rdi

	movl	$0xc0000101, %ecx
	movq	initial_gs(%rip), %rax
	movq	$_text, %rdx
	subq	%rdx, %rax
	addq	%rdi, %rax
	movq	%rax, %rdx
	shrq	$32, %rdx
	wrmsr

	pushq	%rsi
	call	startup_64_setup_env
	popq	%rsi

	pushq	$(2*8)
	leaq	.Lon_kernel_cs(%rip), %rax
	pushq	%rax
	lretq

.Lon_kernel_cs:
	leaq	_text(%rip), %rdi
	pushq 	%rsi
	call	__startup_64
	popq	%rsi

	addq	$(early_top_pgt - 0xffffffff80000000), %rax
	jmp	1f

	.globl secondary_startup_64
secondary_startup_64:
1:
	movl	$0, %ecx
	orl	$(((1) << (5)) | ((1) << (7))), %ecx
	movq	%rcx, %cr4

	addq	phys_base(%rip), %rax
	movq	%rax, %cr3

	movq	%cr4, %rcx
	movq	%rcx, %rax
	xorq	$((1) << (7)), %rcx
	movq	%rcx, %cr4
	movq	%rax, %cr4

	movq	$1f, %rax
	jmp	*%rax

1:
	lgdt	early_gdt_descr(%rip)

	xorl	%eax,%eax
	movl	%eax,%ds
	movl	%eax,%ss
	movl	%eax,%es
	movl	%eax,%fs
	movl	%eax,%gs

	movl	$0xc0000101,%ecx
	movl	initial_gs(%rip),%eax
	movl	initial_gs+4(%rip),%edx
	wrmsr

	movq	initial_stack(%rip), %rsp

	pushq	%rsi
	call	early_setup_idt
	popq	%rsi

	movl	$0x80000001, %eax
	cpuid
	movl	%edx,%edi

	movl	$0xc0000080, %ecx
	rdmsr

	movl	%eax, %edx
	btsl	$0, %eax
	btl	$20,%edi
	jnc	1f
	btsl	$11, %eax
	btsq	$63,early_pmd_flags(%rip)

1:
	cmpl	%edx, %eax
	je	1f
	xor	%edx, %edx
	wrmsr
1:

	movl	$(((1) << (0)) | ((1) << (1)) | ((1) << (4)) | ((1) << (5)) | ((1) << (16)) | ((1) << (18)) | ((1) << (31))), %eax
	movq	%rax, %cr0

	pushq	$0
	popfq

	movq	%rsi, %rdi

.Ljump_to_C_code:
	pushq	$.Lafter_lret # put return address on stack for unwinder
	xorl	%ebp, %ebp # clear frame pointer
	movq	initial_code(%rip), %rax
	pushq	$(2*8) # set correct cs
	pushq	%rax # target address in negative space
	lretq
.Lafter_lret:

	.section ".ref.data", "aw"
	.balign 8
	.globl initial_code
initial_code:
	.quad	x86_64_start_kernel

	.globl initial_gs
initial_gs:
	.quad	fixed_percpu_data

	.globl initial_stack
initial_stack:
	.quad	init_thread_union + ((1 << 12) << (2 + 0)) - 168

	.section ".init.text","ax"

	.globl early_idt_handler_array
early_idt_handler_array:
	i = 0
	.rept 32
	.if ((0x20027d00 >> i) & 1) == 0
		pushq	$0 # Dummy error code, to make stack frame uniform
	.endif
	pushq	$i # 72(%rsp) Vector number
	jmp	early_idt_handler_common
	i = i + 1
	.fill	early_idt_handler_array + i*(9 + (4*0)) - ., 1, 0xcc
	.endr

early_idt_handler_common:
	cld

	incl	early_recursion_flag(%rip)

	pushq	%rsi
	movq	8(%rsp), %rsi
	movq	%rdi, 8(%rsp)
	pushq	%rdx
	pushq	%rcx
	pushq	%rax
	pushq	%r8
	pushq	%r9
	pushq	%r10
	pushq	%r11
	pushq	%rbx
	pushq	%rbp
	pushq	%r12
	pushq	%r13
	pushq	%r14
	pushq	%r15

	movq	%rsp,%rdi
	call	do_early_exception

	decl	early_recursion_flag(%rip)
	jmp	restore_regs_and_return_to_kernel

	.section ".init.data","aw",%progbits

	.balign 4
	.globl early_top_pgt
	.balign (1 << 12)
early_top_pgt:
	.fill	512,8,0
	.fill	0,8,0

	.globl early_dynamic_pgts
	.balign (1 << 12)
early_dynamic_pgts:
	.fill	512*64,8,0

	.globl early_recursion_flag
early_recursion_flag:
	.long 0

	.data
	.globl init_top_pgt
	.balign (1 << 12)
init_top_pgt:
	.fill	512,8,0
	.fill	0,8,0

	.globl level3_kernel_pgt
	.balign (1 << 12)
level3_kernel_pgt:
	.fill	(((0xffffffff80000000) >> 30) & (512 -1)),8,0
	.quad	level2_kernel_pgt - 0xffffffff80000000 + ((1 << 0)|(1 << 1)| 0|(1 << 5)| 0|(1 << 6)| 0| 0)
	.quad	level2_fixmap_pgt - 0xffffffff80000000 + ((1 << 0)|(1 << 1)|(1 << 2)|(1 << 5)| 0|(1 << 6)| 0| 0)

	.globl level2_kernel_pgt
	.balign (1 << 12)
level2_kernel_pgt:
	i = 0
	.rept	((512 * 1024 * 1024)/(1 << 21))
	.quad	(0) + (i << 21) + (((1 << 0)|(1 << 1)| 0|(1 << 5)| 0|(1 << 6)|(1 << 7)|(1 << 8)))
	i = i + 1
	.endr

	.globl level2_fixmap_pgt
	.balign (1 << 12)
level2_fixmap_pgt:
	.fill	(512 - 4 - 2),8,0
	pgtno = 0
	.rept	(2)
	.quad	level1_fixmap_pgt + (pgtno << 12) - 0xffffffff80000000 + ((1 << 0)|(1 << 1)|(1 << 2)|(1 << 5)| 0|(1 << 6)| 0| 0)
	pgtno = pgtno + 1
	.endr
	.fill	4,8,0

	.globl level1_fixmap_pgt
	.balign (1 << 12)
level1_fixmap_pgt:
	.rept	(2)
	.fill	512,8,0
	.endr

	.data

	.align 16
	.globl early_gdt_descr
early_gdt_descr:
	.word	16*8-1

early_gdt_descr_base:
	.quad	gdt_page

	.align 16
	.globl phys_base
phys_base:
	.quad	0x0

	.section ".bss..page_aligned", "aw"
	.globl empty_zero_page
	.balign (1 << 12)
empty_zero_page:
	.skip	(1 << 12)

i:
	.long	0

pgtno:
	.long	0
