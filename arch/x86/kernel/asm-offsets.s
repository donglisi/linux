	.file	"asm-offsets.c"
	.text
	.section	.text.startup,"ax",@progbits
	.p2align 4
	.globl	main
	.type	main, @function
main:
#APP
# 20 "arch/x86/kernel/asm-offsets_64.c" 1
	
.ascii "->"
# 0 "" 2
# 24 "arch/x86/kernel/asm-offsets_64.c" 1
	
.ascii "->KVM_STEAL_TIME_preempted $16 offsetof(struct kvm_steal_time, preempted)"
# 0 "" 2
# 25 "arch/x86/kernel/asm-offsets_64.c" 1
	
.ascii "->"
# 0 "" 2
# 29 "arch/x86/kernel/asm-offsets_64.c" 1
	
.ascii "->pt_regs_bx $40 offsetof(struct pt_regs, bx)"
# 0 "" 2
# 30 "arch/x86/kernel/asm-offsets_64.c" 1
	
.ascii "->pt_regs_cx $88 offsetof(struct pt_regs, cx)"
# 0 "" 2
# 31 "arch/x86/kernel/asm-offsets_64.c" 1
	
.ascii "->pt_regs_dx $96 offsetof(struct pt_regs, dx)"
# 0 "" 2
# 32 "arch/x86/kernel/asm-offsets_64.c" 1
	
.ascii "->pt_regs_sp $152 offsetof(struct pt_regs, sp)"
# 0 "" 2
# 33 "arch/x86/kernel/asm-offsets_64.c" 1
	
.ascii "->pt_regs_bp $32 offsetof(struct pt_regs, bp)"
# 0 "" 2
# 34 "arch/x86/kernel/asm-offsets_64.c" 1
	
.ascii "->pt_regs_si $104 offsetof(struct pt_regs, si)"
# 0 "" 2
# 35 "arch/x86/kernel/asm-offsets_64.c" 1
	
.ascii "->pt_regs_di $112 offsetof(struct pt_regs, di)"
# 0 "" 2
# 36 "arch/x86/kernel/asm-offsets_64.c" 1
	
.ascii "->pt_regs_r8 $72 offsetof(struct pt_regs, r8)"
# 0 "" 2
# 37 "arch/x86/kernel/asm-offsets_64.c" 1
	
.ascii "->pt_regs_r9 $64 offsetof(struct pt_regs, r9)"
# 0 "" 2
# 38 "arch/x86/kernel/asm-offsets_64.c" 1
	
.ascii "->pt_regs_r10 $56 offsetof(struct pt_regs, r10)"
# 0 "" 2
# 39 "arch/x86/kernel/asm-offsets_64.c" 1
	
.ascii "->pt_regs_r11 $48 offsetof(struct pt_regs, r11)"
# 0 "" 2
# 40 "arch/x86/kernel/asm-offsets_64.c" 1
	
.ascii "->pt_regs_r12 $24 offsetof(struct pt_regs, r12)"
# 0 "" 2
# 41 "arch/x86/kernel/asm-offsets_64.c" 1
	
.ascii "->pt_regs_r13 $16 offsetof(struct pt_regs, r13)"
# 0 "" 2
# 42 "arch/x86/kernel/asm-offsets_64.c" 1
	
.ascii "->pt_regs_r14 $8 offsetof(struct pt_regs, r14)"
# 0 "" 2
# 43 "arch/x86/kernel/asm-offsets_64.c" 1
	
.ascii "->pt_regs_r15 $0 offsetof(struct pt_regs, r15)"
# 0 "" 2
# 44 "arch/x86/kernel/asm-offsets_64.c" 1
	
.ascii "->pt_regs_flags $144 offsetof(struct pt_regs, flags)"
# 0 "" 2
# 45 "arch/x86/kernel/asm-offsets_64.c" 1
	
.ascii "->"
# 0 "" 2
# 49 "arch/x86/kernel/asm-offsets_64.c" 1
	
.ascii "->saved_context_cr0 $200 offsetof(struct saved_context, cr0)"
# 0 "" 2
# 50 "arch/x86/kernel/asm-offsets_64.c" 1
	
.ascii "->saved_context_cr2 $208 offsetof(struct saved_context, cr2)"
# 0 "" 2
# 51 "arch/x86/kernel/asm-offsets_64.c" 1
	
.ascii "->saved_context_cr3 $216 offsetof(struct saved_context, cr3)"
# 0 "" 2
# 52 "arch/x86/kernel/asm-offsets_64.c" 1
	
.ascii "->saved_context_cr4 $224 offsetof(struct saved_context, cr4)"
# 0 "" 2
# 53 "arch/x86/kernel/asm-offsets_64.c" 1
	
.ascii "->saved_context_gdt_desc $266 offsetof(struct saved_context, gdt_desc)"
# 0 "" 2
# 54 "arch/x86/kernel/asm-offsets_64.c" 1
	
.ascii "->"
# 0 "" 2
# 57 "arch/x86/kernel/asm-offsets_64.c" 1
	
.ascii "->"
# 0 "" 2
#NO_APP
	xorl	%eax, %eax
	ret
	.size	main, .-main
	.text
	.p2align 4
	.type	common, @function
common:
#APP
# 36 "arch/x86/kernel/asm-offsets.c" 1
	
.ascii "->"
# 0 "" 2
# 37 "arch/x86/kernel/asm-offsets.c" 1
	
.ascii "->TASK_threadsp $1816 offsetof(struct task_struct, thread.sp)"
# 0 "" 2
# 42 "arch/x86/kernel/asm-offsets.c" 1
	
.ascii "->"
# 0 "" 2
# 43 "arch/x86/kernel/asm-offsets.c" 1
	
.ascii "->pbe_address $0 offsetof(struct pbe, address)"
# 0 "" 2
# 44 "arch/x86/kernel/asm-offsets.c" 1
	
.ascii "->pbe_orig_address $8 offsetof(struct pbe, orig_address)"
# 0 "" 2
# 45 "arch/x86/kernel/asm-offsets.c" 1
	
.ascii "->pbe_next $16 offsetof(struct pbe, next)"
# 0 "" 2
# 70 "arch/x86/kernel/asm-offsets.c" 1
	
.ascii "->"
# 0 "" 2
# 71 "arch/x86/kernel/asm-offsets.c" 1
	
.ascii "->TDX_MODULE_rcx $0 offsetof(struct tdx_module_output, rcx)"
# 0 "" 2
# 72 "arch/x86/kernel/asm-offsets.c" 1
	
.ascii "->TDX_MODULE_rdx $8 offsetof(struct tdx_module_output, rdx)"
# 0 "" 2
# 73 "arch/x86/kernel/asm-offsets.c" 1
	
.ascii "->TDX_MODULE_r8 $16 offsetof(struct tdx_module_output, r8)"
# 0 "" 2
# 74 "arch/x86/kernel/asm-offsets.c" 1
	
.ascii "->TDX_MODULE_r9 $24 offsetof(struct tdx_module_output, r9)"
# 0 "" 2
# 75 "arch/x86/kernel/asm-offsets.c" 1
	
.ascii "->TDX_MODULE_r10 $32 offsetof(struct tdx_module_output, r10)"
# 0 "" 2
# 76 "arch/x86/kernel/asm-offsets.c" 1
	
.ascii "->TDX_MODULE_r11 $40 offsetof(struct tdx_module_output, r11)"
# 0 "" 2
# 78 "arch/x86/kernel/asm-offsets.c" 1
	
.ascii "->"
# 0 "" 2
# 79 "arch/x86/kernel/asm-offsets.c" 1
	
.ascii "->TDX_HYPERCALL_r10 $0 offsetof(struct tdx_hypercall_args, r10)"
# 0 "" 2
# 80 "arch/x86/kernel/asm-offsets.c" 1
	
.ascii "->TDX_HYPERCALL_r11 $8 offsetof(struct tdx_hypercall_args, r11)"
# 0 "" 2
# 81 "arch/x86/kernel/asm-offsets.c" 1
	
.ascii "->TDX_HYPERCALL_r12 $16 offsetof(struct tdx_hypercall_args, r12)"
# 0 "" 2
# 82 "arch/x86/kernel/asm-offsets.c" 1
	
.ascii "->TDX_HYPERCALL_r13 $24 offsetof(struct tdx_hypercall_args, r13)"
# 0 "" 2
# 83 "arch/x86/kernel/asm-offsets.c" 1
	
.ascii "->TDX_HYPERCALL_r14 $32 offsetof(struct tdx_hypercall_args, r14)"
# 0 "" 2
# 84 "arch/x86/kernel/asm-offsets.c" 1
	
.ascii "->TDX_HYPERCALL_r15 $40 offsetof(struct tdx_hypercall_args, r15)"
# 0 "" 2
# 86 "arch/x86/kernel/asm-offsets.c" 1
	
.ascii "->"
# 0 "" 2
# 87 "arch/x86/kernel/asm-offsets.c" 1
	
.ascii "->BP_scratch $484 offsetof(struct boot_params, scratch)"
# 0 "" 2
# 88 "arch/x86/kernel/asm-offsets.c" 1
	
.ascii "->BP_secure_boot $492 offsetof(struct boot_params, secure_boot)"
# 0 "" 2
# 89 "arch/x86/kernel/asm-offsets.c" 1
	
.ascii "->BP_loadflags $529 offsetof(struct boot_params, hdr.loadflags)"
# 0 "" 2
# 90 "arch/x86/kernel/asm-offsets.c" 1
	
.ascii "->BP_hardware_subarch $572 offsetof(struct boot_params, hdr.hardware_subarch)"
# 0 "" 2
# 91 "arch/x86/kernel/asm-offsets.c" 1
	
.ascii "->BP_version $518 offsetof(struct boot_params, hdr.version)"
# 0 "" 2
# 92 "arch/x86/kernel/asm-offsets.c" 1
	
.ascii "->BP_kernel_alignment $560 offsetof(struct boot_params, hdr.kernel_alignment)"
# 0 "" 2
# 93 "arch/x86/kernel/asm-offsets.c" 1
	
.ascii "->BP_init_size $608 offsetof(struct boot_params, hdr.init_size)"
# 0 "" 2
# 94 "arch/x86/kernel/asm-offsets.c" 1
	
.ascii "->BP_pref_address $600 offsetof(struct boot_params, hdr.pref_address)"
# 0 "" 2
# 96 "arch/x86/kernel/asm-offsets.c" 1
	
.ascii "->"
# 0 "" 2
# 97 "arch/x86/kernel/asm-offsets.c" 1
	
.ascii "->PTREGS_SIZE $168 sizeof(struct pt_regs)"
# 0 "" 2
# 100 "arch/x86/kernel/asm-offsets.c" 1
	
.ascii "->TLB_STATE_user_pcid_flush_mask $22 offsetof(struct tlb_state, user_pcid_flush_mask)"
# 0 "" 2
# 103 "arch/x86/kernel/asm-offsets.c" 1
	
.ascii "->CPU_ENTRY_AREA_entry_stack $4096 offsetof(struct cpu_entry_area, entry_stack_page)"
# 0 "" 2
# 104 "arch/x86/kernel/asm-offsets.c" 1
	
.ascii "->SIZEOF_entry_stack $4096 sizeof(struct entry_stack)"
# 0 "" 2
# 105 "arch/x86/kernel/asm-offsets.c" 1
	
.ascii "->MASK_entry_stack $-4096 (~(sizeof(struct entry_stack) - 1))"
# 0 "" 2
# 108 "arch/x86/kernel/asm-offsets.c" 1
	
.ascii "->TSS_sp0 $4 offsetof(struct tss_struct, x86_tss.sp0)"
# 0 "" 2
# 109 "arch/x86/kernel/asm-offsets.c" 1
	
.ascii "->TSS_sp1 $12 offsetof(struct tss_struct, x86_tss.sp1)"
# 0 "" 2
# 110 "arch/x86/kernel/asm-offsets.c" 1
	
.ascii "->TSS_sp2 $20 offsetof(struct tss_struct, x86_tss.sp2)"
# 0 "" 2
#NO_APP
	ret
	.size	common, .-common
	.ident	"GCC: (GNU) 12.0.1 20220413 (Red Hat 12.0.1-0)"
	.section	.note.GNU-stack,"",@progbits
