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


# Create map file with all symbols from ${1}
# See mksymap for additional details
mksysmap()
{
	${CONFIG_SHELL} "${srctree}/scripts/mksysmap" ${1} ${2}
}

# final build of init/
${MAKE} -f "${srctree}/scripts/Makefile.build" obj=init need-builtin=1

#link vmlinux.o
${MAKE} -f "${srctree}/scripts/Makefile.vmlinux_o"

info MODINFO modules.builtin.modinfo
${OBJCOPY} -j .modinfo -O binary vmlinux.o modules.builtin.modinfo
info GEN modules.builtin
# The second line aids cases where multiple modules share the same object.
tr '\0' '\n' < modules.builtin.modinfo | sed -n 's/^[[:alnum:]:_]*\.file=//p' |
	tr ' ' '\n' | uniq | sed -e 's:^:kernel/:' -e 's/$/.ko/' > modules.builtin

${LD} ${KBUILD_LDFLAGS} ${LDFLAGS_vmlinux} --script=${objtree}/${KBUILD_LDS} --strip-debug -o vmlinux --whole-archive ${KBUILD_VMLINUX_OBJS} --no-whole-archive --start-group ${KBUILD_VMLINUX_LIBS} --end-group

info SYSMAP System.map
mksysmap vmlinux System.map

# For fixdep
echo "vmlinux: $0" > .vmlinux.d
