#!/bin/sh
set -e

LD="$1"
KBUILD_LDFLAGS="$2"
LDFLAGS_vmlinux="$3"

# Nice output in kbuild format
# Will be supressed by "make -s"
info()
{
	printf "  %-7s %s\n" "${1}" "${2}"
}

${MAKE} -f "${srctree}/scripts/Makefile.build" obj=init need-builtin=1

${MAKE} -f "${srctree}/scripts/Makefile.vmlinux_o"

${LD} ${KBUILD_LDFLAGS} ${LDFLAGS_vmlinux} --script=${objtree}/${KBUILD_LDS} --strip-debug -o vmlinux --whole-archive ${KBUILD_VMLINUX_OBJS} --no-whole-archive --start-group ${KBUILD_VMLINUX_LIBS} --end-group

info SYSMAP System.map
$NM -n vmlinux | grep -v '\( [aNUw] \)\|\(__crc_\)\|\( \$[adt]\)\|\( \.L\)' > System.map

# For fixdep
echo "vmlinux: $0" > .vmlinux.d
