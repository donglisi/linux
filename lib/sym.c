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
