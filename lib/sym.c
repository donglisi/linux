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

int alloc_anon_inode;
int alloc_chrdev_region;
int alloc_file_pseudo;
int alloc_netdev_mqs;
int __alloc_skb;
int anon_inode_getfd;
int anon_inode_getfile;
int blk_cleanup_disk;
int blk_cleanup_queue;
int blk_execute_rq;
int blk_finish_plug;
int __blk_flush_plug;
int blk_lookup_devt;
int __blk_mq_alloc_disk;
int blk_mq_alloc_request;
int blk_mq_alloc_tag_set;
int blk_mq_complete_request;
int blk_mq_end_request;
int blk_mq_end_request_batch;
int blk_mq_free_request;
int blk_mq_free_tag_set;
int blk_mq_map_queues;
int blk_mq_start_request;
int blk_mq_start_stopped_hw_queues;
int blk_mq_stop_hw_queue;
int blk_mq_virtio_map_queues;
int blk_queue_alignment_offset;
int blk_queue_io_min;
int blk_queue_io_opt;
int blk_queue_logical_block_size;
int blk_queue_max_discard_sectors;
int blk_queue_max_discard_segments;
int blk_queue_max_hw_sectors;
int blk_queue_max_segments;
int blk_queue_max_segment_size;
int blk_queue_max_write_zeroes_sectors;
int blk_queue_physical_block_size;
int blk_queue_write_cache;
int blk_rq_map_kern;
int __blk_rq_map_sg;
int blk_start_plug;
int blk_status_to_errno;
int block_class;
int blockdev_superblock;
int buffer_heads_over_limit;
int buffer_init;
int cap_capable;
int cap_capget;
int cap_capset;
int cap_mmap_addr;
int cap_ptrace_access_check;
int cap_ptrace_traceme;
int cap_settime;
int cap_task_fix_setuid;
int cap_task_prctl;
int cap_task_setnice;
int cap_task_setscheduler;
int cap_vm_enough_memory;
int cdev_add;
int cdev_alloc;
int cdev_del;
int cdev_init;
int copy_fs_struct;
int __copy_io;
int copy_mnt_ns;
int deactivate_locked_super;
int default_pipe_buf_ops;
int del_gendisk;
int dev_activate;
int device_add_disk;
int dev_init_scheduler;
int done_path_create;
int do_trace_netlink_extack;
int d_path;
int dput;
int dump_mapping;
int dup_fd;
int emergency_sync;
int eth_header_ops;
int eth_mac_addr;
int ethtool_op_get_ts_info;
int eth_type_trans;
int exit_files;
int exit_fs;
int exit_io_context;
int fasync_helper;
int __fdget;
int fd_install;
int fget;
int fget_task;
int file_path;
int file_remove_privs;
int file_update_time;
int filp_open;
int fixed_size_llseek;
int fput;
int free_fs_struct;
int free_netdev;
int free_pipe_info;
int from_mnt_ns;
int __f_setown;
int generic_file_splice_read;
int generic_write_checks;
int get_fs_type;
int __get_task_comm;
int get_unused_fd_flags;
int I_BDEV;
int init_chdir;
int init_chroot;
int init_dup;
int init_eaccess;
int init_files;
int init_fs;
int init_mkdir;
int init_mknod;
int init_mount;
int init_net;
int init_pseudo;
int init_unlink;
int inode_add_lru;
int inode_permission;
int invalidate_bh_lrus_cpu;
int iput;
int iterate_fd;
int iter_file_splice_write;
int kernel_execve;
int kern_mount;
int kern_path;
int kern_path_create;
int kern_path_locked;
int kfree_skb_reason;
int kill_anon_super;
int kill_fasync;
int kill_litter_super;
int list_bdev_fs_names;
int mangle_path;
int __mark_inode_dirty;
int memory_read_from_buffer;
int mmap_min_addr;
int mntns_operations;
int __netif_rx;
int netif_set_tso_max_size;
int netlink_broadcast;
int netlink_has_listeners;
int __netlink_kernel_create;
int netlink_kernel_release;
int netlink_ns_capable;
int netlink_rcv_skb;
int net_ratelimit;
int no_llseek;
int nonseekable_open;
int noop_llseek;
int notify_change;
int nr_blockdev_pages;
int ns_get_path;
int page_cache_pipe_buf_ops;
int part_devt;
int path_noexec;
int path_put;
int pipe_lock;
int pipe_unlock;
int printk_all_partitions;
int proc_create;
int proc_create_data;
int proc_create_seq_private;
int proc_create_single_data;
int proc_flush_pid;
int proc_mkdir;
int proc_ns_file;
int proc_remove;
int proc_set_size;
int proc_tty_register_driver;
int proc_tty_unregister_driver;
int put_disk;
int put_files_struct;
int put_filesystem;
int put_mnt_ns;
int put_unused_fd;
int ramfs_init_fs_context;
int receive_fd;
int reconfigure_single;
int __register_blkdev;
int __register_chrdev;
int register_chrdev_region;
int register_filesystem;
int register_netdev;
int register_pernet_subsys;
int remove_proc_entry;
int rtnl_lock;
int rtnl_unlock;
int sb_clear_inode_writeback;
int sb_mark_inode_writeback;
int seq_list_next;
int seq_list_start;
int seq_lseek;
int __seq_open_private;
int seq_printf;
int seq_putc;
int seq_put_decimal_ll;
int seq_put_decimal_ull;
int seq_puts;
int seq_read;
int seq_release_private;
int seq_vprintf;
int seq_write;
int set_capacity_and_notify;
int set_disk_ro;
int set_dumpable;
int set_fs_pwd;
int set_fs_root;
int __set_task_comm;
int simple_pin_fs;
int simple_release_fs;
int simple_setattr;
int skb_copy_expand;
int skb_pull;
int skb_put;
int skb_tstamp_tx;
int __splice_from_pipe;
int splice_from_pipe;
int suid_dumpable;
int sysctl_nr_open;
int tgid_pidfd_to_pid;
int touch_atime;
int try_to_free_buffers;
int unregister_blkdev;
int __unregister_chrdev;
int unregister_chrdev_region;
int unregister_filesystem;
int vfs_fsync_range;
int vfs_getattr;
int vfs_kern_mount;
int vfs_mkdir;
int vfs_mknod;
int vfs_rmdir;
int vfs_unlink;
int wakeup_flusher_threads;
int wakeup_flusher_threads_bdi;
int wb_start_background_writeback;
int wb_workfn;
int __x64_sys_access;
int __x64_sys_chdir;
int __x64_sys_chmod;
int __x64_sys_chown;
int __x64_sys_chroot;
int __x64_sys_close;
int __x64_sys_close_range;
int __x64_sys_creat;
int __x64_sys_dup;
int __x64_sys_dup2;
int __x64_sys_dup3;
int __x64_sys_execve;
int __x64_sys_faccessat;
int __x64_sys_faccessat2;
int __x64_sys_fallocate;
int __x64_sys_fchdir;
int __x64_sys_fchmod;
int __x64_sys_fchmodat;
int __x64_sys_fchown;
int __x64_sys_fchownat;
int __x64_sys_fcntl;
int __x64_sys_fdatasync;
int __x64_sys_fgetxattr;
int __x64_sys_flistxattr;
int __x64_sys_fremovexattr;
int __x64_sys_fsconfig;
int __x64_sys_fsetxattr;
int __x64_sys_fsmount;
int __x64_sys_fsopen;
int __x64_sys_fspick;
int __x64_sys_fstatfs;
int __x64_sys_fsync;
int __x64_sys_ftruncate;
int __x64_sys_futimesat;
int __x64_sys_getcwd;
int __x64_sys_getdents;
int __x64_sys_getdents64;
int __x64_sys_getxattr;
int __x64_sys_ioctl;
int __x64_sys_lchown;
int __x64_sys_lgetxattr;
int __x64_sys_link;
int __x64_sys_linkat;
int __x64_sys_listxattr;
int __x64_sys_llistxattr;
int __x64_sys_lremovexattr;
int __x64_sys_lseek;
int __x64_sys_lsetxattr;
int __x64_sys_mkdir;
int __x64_sys_mkdirat;
int __x64_sys_mknod;
int __x64_sys_mknodat;
int __x64_sys_mount;
int __x64_sys_mount_setattr;
int __x64_sys_move_mount;
int __x64_sys_newfstat;
int __x64_sys_newfstatat;
int __x64_sys_newlstat;
int __x64_sys_newstat;
int __x64_sys_open;
int __x64_sys_openat;
int __x64_sys_openat2;
int __x64_sys_open_tree;
int __x64_sys_pipe;
int __x64_sys_pipe2;
int __x64_sys_pivot_root;
int __x64_sys_poll;
int __x64_sys_ppoll;
int __x64_sys_pread64;
int __x64_sys_preadv;
int __x64_sys_preadv2;
int __x64_sys_pselect6;
int __x64_sys_pwrite64;
int __x64_sys_pwritev;
int __x64_sys_pwritev2;
int __x64_sys_read;
int __x64_sys_readlink;
int __x64_sys_readlinkat;
int __x64_sys_readv;
int __x64_sys_removexattr;
int __x64_sys_rename;
int __x64_sys_renameat;
int __x64_sys_renameat2;
int __x64_sys_rmdir;
int __x64_sys_select;
int __x64_sys_sendfile64;
int __x64_sys_setxattr;
int __x64_sys_splice;
int __x64_sys_statfs;
int __x64_sys_statx;
int __x64_sys_symlink;
int __x64_sys_symlinkat;
int __x64_sys_sync;
int __x64_sys_sync_file_range;
int __x64_sys_syncfs;
int __x64_sys_tee;
int __x64_sys_truncate;
int __x64_sys_umount;
int __x64_sys_unlink;
int __x64_sys_unlinkat;
int __x64_sys_ustat;
int __x64_sys_utime;
int __x64_sys_utimensat;
int __x64_sys_utimes;
int __x64_sys_vhangup;
int __x64_sys_vmsplice;
int __x64_sys_write;
int __x64_sys_writev;

int pci_alloc_irq_vectors_affinity;
int pci_bus_type;
int pci_device_is_present;
int pci_disable_device;
int pci_enable_device;
int pci_find_capability;
int pci_find_ext_capability;
int pci_find_next_capability;
int pci_free_irq_vectors;
int pci_irq_get_affinity;
int pci_irq_vector;
int pci_msi_ignore_mask;
int pci_read_config_byte;
int pci_read_config_dword;
int __pci_register_driver;
int pci_release_region;
int pci_release_selected_regions;
int pci_request_region;
int pci_request_selected_regions;
int pci_set_master;
int pci_unregister_driver;
int pci_write_config_byte;
int pci_write_config_dword;

int mc146818_set_time;
int rtc_time64_to_tm;
int rtc_valid_tm;

int clockevent_i8253_init;
int i8253_clockevent;
int register_virtio_driver;
int unregister_virtio_driver;
int virtio_break_device;
int virtio_check_driver_offered_feature;
int virtio_reset_device;
int virtqueue_add_inbuf;
int virtqueue_add_outbuf;
int virtqueue_detach_unused_buf;
int virtqueue_get_buf;
int virtqueue_is_broken;
int virtqueue_kick;

int call_rcu;
int finish_rcuwait;
int get_state_synchronize_rcu;
int init_srcu_struct;
int rcu_barrier;
int rcu_qs;
int rcu_sched_clock_irq;
int rcu_scheduler_starting;
int rcu_sync_dtor;
int rcu_sync_enter;
int rcu_sync_exit;
int rcu_sync_init;
int srcu_drive_gp;
int __srcu_read_unlock;
int synchronize_rcu;
int synchronize_srcu;

int disable_irq;
int disable_irq_nosync;
int dummy_irq_chip;
int enable_irq;
int force_irqthreads_key;
int free_irq;
int handle_edge_irq;
int handle_level_irq;
int init_irq_proc;
int irq_chip_ack_parent;
int irq_chip_compose_msi_msg;
int irq_chip_retrigger_hierarchy;
int irq_dispose_mapping;
int __irq_domain_alloc_fwnode;
int __irq_domain_alloc_irqs;
int irq_domain_free_fwnode;
int irq_domain_set_info;
int irq_find_matching_fwspec;
int irq_get_irq_data;
int irq_modify_status;
int irq_set_chip_and_handler_name;
int irq_to_desc;
int msi_create_irq_domain;
int msi_domain_set_affinity;
int msi_get_domain_info;
int no_action;
int request_threaded_irq;

int do_futex;
int futex_exec_release;
int futex_exit_recursive;
int futex_exit_release;

int modify_user_hw_breakpoint;
int perf_bp_event;
int perf_event_delayed_put;
int perf_event_exit_task;
int perf_event_fork;
int perf_event_free_task;
int perf_event_init_task;
int perf_event_mmap;
int perf_event_namespaces;
int perf_event_overflow;
int perf_event_task_disable;
int perf_event_task_enable;
int __perf_event_task_sched_in;
int __perf_event_task_sched_out;
int perf_event_task_tick;
int perf_event_text_poke;
int perf_event_update_userpage;
int perf_pmu_disable;
int perf_pmu_enable;
int perf_pmu_register;
int perf_pmu_unregister;
int __perf_regs;
int perf_sample_event_took;
int perf_sched_events;
int ___perf_sw_event;
int __perf_sw_event;
int perf_swevent_enabled;
int put_callchain_buffers;
int register_user_hw_breakpoint;
int sysctl_perf_event_paranoid;
int unregister_hw_breakpoint;

int do_syscall_64;
int fixup_vdso_exception;
int vclocks_used;

int arch_scale_freq_tick;
int clear_cpu_cap;
int cpu_bugs_smt_update;
int mds_idle_clear;
int mds_user_clear;
int release_evntsel_nmi;
int release_perfctr_nmi;
int reserve_evntsel_nmi;
int reserve_perfctr_nmi;
int setup_clear_cpu_cap;
int switch_mm_always_ibpb;
int switch_mm_cond_ibpb;
int switch_mm_cond_l1d_flush;
int update_srbds_msr;
int write_spec_ctrl_current;
int x86_amd_ls_cfg_base;
int x86_amd_ls_cfg_ssbd_mask;
int x86_cap_flags;
int x86_match_cpu;
int x86_spec_ctrl_base;
int x86_spec_ctrl_setup_ap;

int add_timer;
int add_timer_on;
int clockevents_config_and_register;
int clocks_calc_mult_shift;
int clocksource_mark_unstable;
int __clocksource_register_scale;
int clocksource_unregister;
int del_timer;
int get_timespec64;
int hrtimer_active;
int hrtimer_forward;
int hrtimer_init;
int hrtimer_start_range_ns;
int hrtimer_try_to_cancel;
int init_timer_key;
int jiffies_64;
int jiffies_64_to_clock_t;
int jiffies_to_msecs;
int jiffies_to_timespec64;
int jiffies_to_usecs;
int ktime_get;
int ktime_get_real_seconds;
int ktime_get_seconds;
int ktime_get_with_offset;
int mktime64;
int mod_timer;
int __msecs_to_jiffies;
int msleep;
int msleep_interruptible;
int nsec_to_clock_t;
int ns_to_kernel_old_timeval;
int ns_to_timespec64;
int put_timespec64;
int schedule_hrtimeout_range;
int schedule_timeout;
int schedule_timeout_idle;
int schedule_timeout_interruptible;
int schedule_timeout_killable;
int schedule_timeout_uninterruptible;
int sysrq_timer_list_show;
int tick_broadcast_control;
int tick_broadcast_oneshot_control;
int tick_check_broadcast_expired;
int tick_irq_enter;
int time64_to_tm;
int timekeeping_suspended;


int __class_create;
int class_destroy;
int class_find_device;
int _dev_err;
int device_create;
int device_create_with_groups;
int device_del;
int device_destroy;
int device_match_devt;
int device_register;
int device_shutdown;
int device_unregister;
int _dev_info;
int devm_add_action;
int devm_kasprintf;
int devm_kstrdup;
int _dev_printk;
int devres_add;
int __devres_alloc_node;
int devres_destroy;
int devres_find;
int devres_free;
int devres_get;
int devres_release;
int dev_set_name;
int devtmpfs_mount;
int _dev_warn;
int driver_init;
int driver_probe_done;
int fwnode_count_parents;
int fwnode_get_name;
int fwnode_get_name_prefix;
int fwnode_get_nth_parent;
int fwnode_handle_put;
int get_device;
int platform_device_register;
int put_device;
int register_cpu;
int register_syscore_ops;
int syscore_shutdown;
int wait_for_device_probe;

int disassociate_ctty;
int get_current_tty;
int hvc_alloc;
int hvc_instantiate;
int hvc_kick;
int hvc_poll;
int hvc_remove;
int __hvc_resize;
int __init_ldsem;
int ldsem_down_read;
int ldsem_down_read_trylock;
int ldsem_down_write;
int ldsem_up_read;
int ldsem_up_write;
int proc_clear_tty;
int session_clear_tty;
int __tty_check_change;
int tty_check_change;
int tty_get_pgrp;
int tty_jobctrl_ioctl;
int tty_lock;
int tty_lock_interruptible;
int tty_lock_slave;
int tty_open_proc_set_tty;
int tty_signal_session_leader;
int tty_termios_baud_rate;
int tty_termios_input_baud_rate;
int tty_unlock;
int tty_unlock_slave;

int n_tty_ioctl_helper;
int tty_buffer_cancel_work;
int tty_buffer_flush;
int tty_buffer_flush_work;
int tty_buffer_lock_exclusive;
int tty_buffer_restart_work;
int tty_buffer_unlock_exclusive;
int tty_chars_in_buffer;
int tty_driver_flush_buffer;
int tty_ldisc_deinit;
int tty_ldisc_deref;
int tty_ldisc_flush;
int tty_ldisc_hangup;
int tty_ldisc_init;
int tty_ldisc_lock;
int tty_ldisc_ref;
int tty_ldisc_ref_wait;
int tty_ldisc_reinit;
int tty_ldisc_release;
int tty_ldisc_setup;
int tty_ldisc_unlock;
int tty_register_ldisc;
int tty_set_ldisc;
int tty_sysctl_init;
int tty_throttle_safe;
int tty_unthrottle;
int tty_unthrottle_safe;
int tty_wait_until_sent;
int tty_write_room;
int n_tty_init;

int add_device_randomness;
int get_random_bytes;
int get_random_u32;
int get_random_u64;
int rng_is_initialized;

int idt_invalidate;
int idt_setup_apic_and_irq_gates;
int idt_setup_traps;
int load_current_idt;

int e820__memory_setup_extended;
int e820__reallocate_tables;
int e820__update_table;
int cpu_init;
int cpu_init_exception_handling;

int kernel_set_to_readonly;
int mark_rodata_ro;
int set_pte_vaddr;

int asm_load_gs_index;
int ret_from_fork;
int rewind_stack_and_make_dead;
int __switch_to_asm;

int groups_free;
int memremap;
int memunmap;
int sprint_backtrace;
int sprint_backtrace_build_id;
int sprint_symbol;
int sprint_symbol_build_id;
int sprint_symbol_no_offset;
int __fprop_add_percpu_max;
int fprop_fraction_percpu;
int fprop_global_init;
int fprop_local_destroy_percpu;
int fprop_local_init_percpu;
int fprop_new_period;
int ioread32;
int iowrite32;
int current_is_single_threaded;
int ida_alloc_range;
int ida_destroy;
int ida_free;
int idr_alloc;
int idr_alloc_cyclic;
int idr_find;
int idr_get_next;
int idr_remove;
int idr_replace;
int __irq_regs;
int ___ratelimit;
int search_extable;
int show_mem;
int sort_extable;
int __xa_clear_mark;
int xa_delete_node;
int xa_erase;
int __xa_insert;
int xa_load;
int xas_clear_mark;
int __xa_set_mark;
int xas_find;
int xas_find_conflict;
int xas_find_marked;
int xas_init_marks;
int xas_load;
int __xas_next;
int xas_nomem;
int xas_pause;
int __xas_prev;
int xas_set_mark;
int xas_store;
int check_zeroed_user;
int _copy_from_user;
int _copy_to_user;
int errseq_check;
int errseq_check_and_advance;
int errseq_set;
int refcount_dec_and_lock_irqsave;
int refcount_warn_saturate;
int llist_add_batch;
int cpu_idle_poll_ctrl;
int cpu_in_idle;
int cpu_startup_entry;
int idle_sched_class;
int pick_next_task_idle;
int fair_sched_class;
int init_cfs_rq;
int init_entity_runnable_average;
int init_sched_fair_class;
int pick_next_task_fair;
int post_init_entity_util_avg;
int reweight_task;
int sched_init_granularity;
int def_rt_bandwidth;
int init_rt_bandwidth;
int init_rt_rq;
int rt_sched_class;
int sched_rr_timeslice;
int sched_rt_bandwidth_account;
int sysctl_sched_rt_period;
int sysctl_sched_rt_runtime;
int __finish_swait;
int __init_swait_queue_head;
int __prepare_to_swait;
int swake_up_all_locked;
int swake_up_locked;
int calc_global_load_tick;
int calc_load_update;
int get_avenrun;
int complete;
int wait_for_completion;
int wait_for_completion_killable;
int task_cputime_adjusted;
int thread_group_cputime_adjusted;
int __checkparam_dl;
int __dl_clear_params;
int dl_param_changed;
int dl_sched_class;
int __getparam_dl;
int init_dl_inactive_task_timer;
int init_dl_rq;
int init_dl_task_timer;
int sched_dl_overflow;
int __setparam_dl;
int bit_wait;
int init_wait_var_entry;
int out_of_line_wait_on_bit;
int __var_waitqueue;
int wait_bit_init;
int wake_up_bit;
int wake_up_var;
int _atomic_dec_and_lock_irqsave;
int dump_stack;
int report_bug;
int show_regs_print_info;
int strncpy_from_user;
int strnlen_user;
int bust_spinlocks;
int kasprintf;
int kvasprintf;
int bdi_list;
int bdi_wq;
int inode_to_bdi;
int balance_dirty_pages_ratelimited;
int dirty_throttle_leaks;
int do_writepages;
int filemap_dirty_folio;
int folio_account_cleaned;
int __folio_cancel_dirty;
int folio_clear_dirty_for_io;
int __folio_end_writeback;
int folio_mark_dirty;
int folio_redirty_for_writepage;
int __folio_start_writeback;
int folio_wait_stable;
int folio_wait_writeback;
int global_dirty_limits;
int laptop_mode;
int node_dirty_ok;
int noop_dirty_folio;
int page_writeback_init;
int set_page_dirty_lock;
int anon_vma_clone;
int anon_vma_fork;
int __anon_vma_prepare;
int flush_tlb_batched_pending;
int folio_mkclean;
int folio_referenced;
int page_add_file_rmap;
int page_add_new_anon_rmap;
int page_move_anon_rmap;
int page_remove_rmap;
int try_to_unmap;
int try_to_unmap_flush;
int try_to_unmap_flush_dirty;
int unlink_anon_vmas;
int walk_page_range;
int can_do_mlock;
int mlock_new_page;
int mlock_page_drain_local;
int mlock_page_drain_remote;
int copy_vma;
int do_mmap;
int __do_munmap;
int do_munmap;
int exit_mmap;
int expand_stack;
int find_extend_vma;
int find_vma;
int get_mmap_base;
int get_unmapped_area;
int ksys_mmap_pgoff;
int may_expand_vm;
int mlock_future_check;
int mmap_address_hint_valid;
int mmap_init;
int pfn_modify_allowed;
int protection_map;
int stack_guard_gap;
int task_size_64bit;
int unlink_file_vma;
int va_align;
int __vma_adjust;
int __vma_link_rb;
int vm_stat_account;
int vm_unmapped_area;
int lookup_address_in_pgd;
int memtype_free;
int memtype_kernel_map_sync;
int memtype_reserve;
int set_direct_map_default_noflush;
int set_direct_map_invalid_noflush;
int set_memory_nx;
int set_memory_rw;
int _set_memory_uc;
int _set_memory_wb;
int _set_memory_wc;
int _set_memory_wt;
int track_pfn_copy;
int track_pfn_insert;
int track_pfn_remap;
int untrack_pfn;
int untrack_pfn_moved;
int cea_exception_stacks;
int get_cpu_entry_area;
int setup_cpu_entry_areas;
int __early_set_fixmap;
int fixup_exception;
int ioremap;
int ioremap_prot;
int iounmap;
int native_set_fixmap;
int pgd_alloc;
int pgd_free;
int pmd_clear_huge;
int pmd_free_pte_page;
int ___pmd_free_tlb;
int pmd_set_huge;
int pte_alloc_one;
int ___pte_free_tlb;
int ptep_set_access_flags;
int pud_clear_huge;
int pud_free_pmd_page;
int ___pud_free_tlb;
int pud_set_huge;
int __virt_addr_valid;
int page_cache_async_ra;
int page_cache_ra_order;
int page_cache_sync_ra;
int dump_page;
int gfpflag_names;
int pageflag_names;
int vmaflag_names;
int vma_is_secretmem;
int fault_in_readable;
int fault_in_safe_writeable;
int get_user_pages_fast;
int get_user_pages_remote;
int __mm_populate;
int copy_from_kernel_nofault;
int __copy_overflow;
int end_page_writeback;
int exit_oom_victim;
int lru_cache_add;
int mark_page_accessed;
int oom_adj_mutex;
int oom_lock;
int out_of_memory;
int pagecache_get_page;
int pagefault_out_of_memory;
int page_mapped;
int page_mapping;
int putback_lru_page;
int set_page_dirty;
int try_to_release_page;
int unlock_page;
int wait_on_page_writeback;
int init_mm_internals;
int mm_percpu_wq;
int shadow_nodes;
int vm_node_stat;
int vm_zone_stat;
int workingset_activation;
int workingset_age_nonresident;
int workingset_eviction;
int workingset_refault;
int workingset_update_node;
int debug_locks;
int debug_locks_off;
int guid_index;
int uuid_index;
int pmd_clear_bad;
int ptep_clear_flush;
int pud_clear_bad;
int tlb_finish_mmu;
int tlb_flush_mmu;
int tlb_gather_mmu;
int __tlb_remove_page_size;
int __die;
int die;
int die_addr;
int get_stack_info;
int hpet_time_init;
int irq_err_count;
int irq_init_percpu_irqstack;
int irq_stat;
int local_touch_nmi;
int oops_begin;
int oops_end;
int __register_nmi_handler;
int restart_nmi;
int show_iret_regs;
int show_opcodes;
int show_regs;
int show_stack;
int stop_nmi;
int arch_ptrace;
int hpet_address;
int hpet_force_user;
int hpet_msi_disable;
int hpet_readl;
int is_hpet_enabled;
int machine_emergency_restart;
int machine_halt;
int machine_power_off;
int machine_restart;
int ptrace_disable;
int send_sigtrap;
int task_user_regset_view;
int tsc_async_resets;
int tsc_store_and_check_tsc_adjust;
int tsc_verify_tsc_adjust;
int unwind_get_return_address;
int unwind_next_frame;
int __unwind_start;
int user_disable_single_step;
int user_enable_block_step;
int user_enable_single_step;
int user_single_step_report;
int cpu_dr7;
int flush_ptrace_hw_breakpoint;
int init_ISA_irqs;
int legacy_pic;
int native_init_IRQ;
int null_legacy_pic;
int poke_int3_handler;
int poking_addr;
int poking_mm;
int probe_roms;
int text_poke_bp;
int text_poke_early;
int x86_nops;
int perf_clear_dirty_counters;
int rdpmc_always_available_key;
int rdpmc_never_available_key;
int __const_udelay;
int __delay;
int read_current_timer;
int use_tsc_delay;
int mach_get_cmos_time;
int mach_set_rtc_mmss;
int cpu_khz_from_msr;
int capable;
int file_ns_capable;
int has_capability_noaudit;
int ns_capable;
int ns_capable_noaudit;
int ns_capable_setid;
int proc_dointvec;
int proc_dointvec_minmax;
int proc_doulongvec_minmax;
int ptracer_capable;
int async_synchronize_full;
int atomic_notifier_call_chain;
int atomic_notifier_call_chain_is_empty;
int atomic_notifier_chain_register;
int atomic_notifier_chain_register_unique_prio;
int atomic_notifier_chain_unregister;
int blocking_notifier_call_chain;
int blocking_notifier_chain_register;
int blocking_notifier_chain_register_unique_prio;
int blocking_notifier_chain_unregister;
int notify_die;
int reboot_notifier_list;
int alloc_pid;
int attach_pid;
int change_pid;
int detach_pid;
int find_get_pid;
int find_get_task_by_vpid;
int find_task_by_pid_ns;
int find_task_by_vpid;
int find_vpid;
int free_pid;
int get_task_pid;
int init_pid_ns;
int init_struct_pid;
int kernel_text_address;
int pidfd_get_pid;
int pid_nr_ns;
int pid_task;
int pid_vnr;
int put_pid;
int search_exception_tables;
int task_active_pid_ns;
int __task_pid_nr_ns;
int task_work_add;
int task_work_run;
int text_mutex;
int calculate_sigpending;
int copy_siginfo_to_user;
int do_no_restart_syscall;
int do_notify_parent;
int exit_ptrace;
int exit_signals;
int flush_signal_handlers;
int flush_sigqueue;
int force_sig;
int force_sig_fault;
int force_sig_pkuerr;
int free_uid;
int getrusage;
int get_signal;
int group_send_sig_info;
int ignore_signals;
int init_user_ns;
int kill_pgrp;
int __kill_pgrp_info;
int kill_pid;
int overflowuid;
int __ptrace_link;
int ptrace_may_access;
int ptrace_notify;
int __ptrace_unlink;
int recalc_sigpending;
int restore_altstack;
int root_user;
int send_sig;
int __set_current_blocked;
int set_current_blocked;
int signal_setup_done;
int task_join_group_stop;
int task_set_jobctl_pending;
int unhandled_signal;
int zap_other_threads;
int irq_work_queue;
int on_each_cpu_cond_mask;
int __static_call_return0;
int alloc_ucounts;
int dec_rlimit_ucounts;
int get_ucounts;
int inc_rlimit_ucounts;
int init_ucounts;
int is_ucounts_overlimit;
int put_ucounts;
int copy_creds;
int exit_creds;
int init_cred;
int prepare_creds;
int __put_cred;
int add_taint;
int oops_may_print;
int panic;
int panic_cpu;
int panic_notifier_list;
int panic_on_warn;
int __warn_printk;
int copy_namespaces;
int exit_task_namespaces;
int init_nsproxy;
int nsproxy_cache_init;
int switch_task_namespaces;
int unshare_nsproxy_namespaces;
int do_exit;
int put_task_struct_rcu_user;
int rcuwait_wake_up;
int thread_group_exited;
