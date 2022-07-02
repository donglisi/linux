#!/bin/sh

LD="$1"
KBUILD_LDFLAGS="$2"
LDFLAGS_vmlinux="$3"

${LD} ${KBUILD_LDFLAGS} ${LDFLAGS_vmlinux} --script=${objtree}/${KBUILD_LDS} --strip-debug -o vmlinux --whole-archive ${KBUILD_VMLINUX_OBJS} --no-whole-archive --start-group ${KBUILD_VMLINUX_LIBS} --end-group

$NM -n vmlinux | grep -v '\( [aNUw] \)\|\(__crc_\)\|\( \$[adt]\)\|\( \.L\)' > System.map
