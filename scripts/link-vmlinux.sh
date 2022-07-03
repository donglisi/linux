#!/bin/sh

ld -m elf_x86_64 -z max-page-size=0x200000 --script=${objtree}/${KBUILD_LDS} --strip-debug -o vmlinux --whole-archive ${KBUILD_VMLINUX_OBJS} --no-whole-archive --start-group ${KBUILD_VMLINUX_LIBS} --end-group

$NM -n vmlinux | grep -v '\( [aNUw] \)\|\(__crc_\)\|\( \$[adt]\)\|\( \.L\)' > System.map
