ccflags-y += -I $(srctree)/arch/x86/kvm

include $(srctree)/virt/kvm/Makefile.kvm

obj-y += x86.o emulate.o i8259.o irq.o lapic.o i8254.o ioapic.o irq_comm.o cpuid.o pmu.o mtrr.o hyperv.o debugfs.o mmu/mmu.o mmu/page_track.o mmu/spte.o mmu/tdp_iter.o mmu/tdp_mmu.o vmx/vmx.o vmx/vmenter.o vmx/pmu_intel.o vmx/vmcs12.o vmx/evmcs.o vmx/nested.o vmx/posted_intr.o svm/svm.o svm/vmenter.o svm/pmu.o svm/nested.o svm/avic.o svm/sev.o
