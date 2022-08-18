	.file	"bounds.c"
	.text
	.section	.text.startup,"ax",@progbits
	.p2align 4
	.globl	main
	.type	main, @function
main:
#APP
# 19 "kernel/bounds.c" 1
	
.ascii "->NR_PAGEFLAGS $24 __NR_PAGEFLAGS"
# 0 "" 2
# 20 "kernel/bounds.c" 1
	
.ascii "->MAX_NR_ZONES $4 __MAX_NR_ZONES"
# 0 "" 2
# 24 "kernel/bounds.c" 1
	
.ascii "->SPINLOCK_SIZE $0 sizeof(spinlock_t)"
# 0 "" 2
#NO_APP
	xorl	%eax, %eax
	ret
	.size	main, .-main
	.ident	"GCC: (GNU) 12.0.1 20220413 (Red Hat 12.0.1-0)"
	.section	.note.GNU-stack,"",@progbits
