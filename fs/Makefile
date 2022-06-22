# SPDX-License-Identifier: GPL-2.0
#
# Makefile for the Linux filesystems.
#
# 14 Sep 2000, Christoph Hellwig <hch@infradead.org>
# Rewritten to use lists instead of if-statements.
# 

obj-$(CONFIG_SYSCTL)		+= sysctls.o

obj-y :=	open.o read_write.o file_table.o super.o \
		char_dev.o stat.o exec.o pipe.o namei.o fcntl.o \
		ioctl.o readdir.o select.o dcache.o inode.o \
		attr.o bad_inode.o file.o filesystems.o namespace.o \
		seq_file.o xattr.o libfs.o fs-writeback.o \
		pnode.o splice.o sync.o utimes.o d_path.o \
		stack.o fs_struct.o statfs.o fs_pin.o nsfs.o \
		fs_types.o fs_context.o fs_parser.o fsopen.o init.o \
		kernel_read_file.o remap_range.o

ifeq ($(CONFIG_BLOCK),y)
obj-y +=	buffer.o direct-io.o mpage.o
else
obj-y +=	no-block.o
endif

obj-$(CONFIG_PROC_FS) += proc_namespace.o

obj-$(CONFIG_EPOLL)		+= eventpoll.o
obj-y				+= anon_inodes.o
obj-$(CONFIG_SIGNALFD)		+= signalfd.o
obj-$(CONFIG_TIMERFD)		+= timerfd.o
obj-$(CONFIG_EVENTFD)		+= eventfd.o
obj-$(CONFIG_USERFAULTFD)	+= userfaultfd.o
obj-$(CONFIG_AIO)               += aio.o
obj-$(CONFIG_IO_URING)		+= io_uring.o
obj-$(CONFIG_IO_WQ)		+= io-wq.o
obj-$(CONFIG_FS_DAX)		+= dax.o
obj-$(CONFIG_FILE_LOCKING)      += locks.o
obj-$(CONFIG_BINFMT_AOUT)	+= binfmt_aout.o
obj-$(CONFIG_BINFMT_MISC)	+= binfmt_misc.o
obj-$(CONFIG_BINFMT_SCRIPT)	+= binfmt_script.o
obj-$(CONFIG_BINFMT_ELF)	+= binfmt_elf.o
obj-$(CONFIG_COMPAT_BINFMT_ELF)	+= compat_binfmt_elf.o
obj-$(CONFIG_BINFMT_ELF_FDPIC)	+= binfmt_elf_fdpic.o
obj-$(CONFIG_BINFMT_FLAT)	+= binfmt_flat.o

obj-$(CONFIG_FS_MBCACHE)	+= mbcache.o
obj-$(CONFIG_FS_POSIX_ACL)	+= posix_acl.o
obj-$(CONFIG_COREDUMP)		+= coredump.o
obj-$(CONFIG_SYSCTL)		+= drop_caches.o

obj-$(CONFIG_FHANDLE)		+= fhandle.o
obj-y				+= iomap/


obj-$(CONFIG_PROC_FS)		+= proc/
obj-$(CONFIG_KERNFS)		+= kernfs/
obj-$(CONFIG_SYSFS)		+= sysfs/
obj-y				+= devpts/

# Do not add any filesystems before this line
obj-$(CONFIG_EXT4_FS)		+= ext4/
obj-$(CONFIG_JBD2)		+= jbd2/
obj-y				+= ramfs/
obj-$(CONFIG_EXPORTFS)		+= exportfs/
