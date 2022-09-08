.macro POP_REGS
	popq %r15
	popq %r14
	popq %r13
	popq %r12
	popq %rbp
	popq %rbx
	popq %r11
	popq %r10
	popq %r9
	popq %r8
	popq %rax
	popq %rcx
	popq %rdx
	popq %rsi
	popq %rdi
.endm

.code64
.section .entry.text, "ax"
	.globl restore_regs_and_return_to_kernel
restore_regs_and_return_to_kernel:
	POP_REGS
	addq $8, %rsp
	iretq
