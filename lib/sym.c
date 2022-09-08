int early_pci_allowed;
int noioapicquirk;
int noioapicreroute;
int pcibios_assign_all_busses;
int pcibios_fixup_irqs;
int pcibios_irq_init;
int pci_legacy_init;
int read_pci_config;
int read_pci_config_16;
int read_pci_config_byte;
int write_pci_config;
int write_pci_config_16;

int apic;
int apic_intr_mode_init;
int apic_intr_mode_select;
int apic_needs_pit;
int arch_trigger_cpumask_backtrace;
int clear_IO_APIC;
int copy_fpstate_to_sigframe;
int disable_local_APIC;
int fpstate_free;
int fpu__alloc_mathframe;
int fpu__clear_user_states;
int fpu_clone;
int fpu__drop;
int fpu__exception_code;
int fpu_flush_thread;
int fpu__get_fpstate_size;
int fpu__init_cpu;
int fpu__init_system;
int fpu_reset_from_exception_fixup;
int fpu__restore_sig;
int __fpu_state_size_dynamic;
int fpu_sync_fpstate;
int fpu_thread_struct_whitelist;
int fpu_xstate_prctl;
int init_bsp_APIC;
int init_irq_alloc_info;
int irq_mis_count;
int lapic_assign_legacy_vector;
int lapic_assign_system_vectors;
int lapic_shutdown;
int lapic_timer_period;
int lapic_update_tsc_freq;
int native_create_pci_msi_domain;
int native_io_apic_read;
int native_restore_boot_irq_mode;
int proc_pid_arch_status;
int regset_fpregs_active;
int regset_xregset_fpregs_active;
int restore_boot_irq_mode;
int save_fpregs_to_fpstate;
int setup_boot_APIC_clock;
int setup_secondary_APIC_clock;
int spurious_interrupt;
int switch_fpu_return;
int sysvec_apic_timer_interrupt;
int sysvec_error_interrupt;
int sysvec_spurious_apic_interrupt;
int x86_vector_domain;
int xfd_enable_feature;
int xfpregs_get;
int xfpregs_set;
int xstateregs_get;
int xstateregs_set;
