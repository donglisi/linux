#!/bin/sh

set -e

info()
{
	printf "  %-7s %s\n" "${1}" "${2}"
}

vmlinux_link()
{
	local output=${1}

	info LD ${output}
	ld -m elf_x86_64 -z max-page-size=0x200000 --script=build/arch/x86/kernel/vmlinux.lds -o ${output} --whole-archive ${objs} --no-whole-archive --start-group ${libs} --end-group $2
}


kallsyms()
{
	info KSYMS ${2}
	nm -n ${1} | scripts/kallsyms --absolute-percpu --base-relative > ${2}
}

kallsyms_step()
{
	kallsymso_prev=${kallsymso}
	kallsyms_vmlinux=build/.tmp_vmlinux.kallsyms${1}
	kallsymso=${kallsyms_vmlinux}.o
	kallsyms_S=${kallsyms_vmlinux}.S

	vmlinux_link ${kallsyms_vmlinux} "${kallsymso_prev}"
	kallsyms ${kallsyms_vmlinux} ${kallsyms_S}

	info AS ${kallsyms_S}
	gcc -nostdinc -I./build/arch/x86/include/generated -Iinclude -Iarch/x86/include/uapi -include scripts/config.h -c -o ${kallsymso} ${kallsyms_S}
}

kallsymso=""
kallsymso_prev=""
kallsyms_vmlinux=""

# kallsyms_step 1
# kallsyms_step 2

vmlinux_link build/vmlinux "${kallsymso}"

info SYSMAP System.map
nm -n build/vmlinux | grep -v '\( [aNUw] \)\|\(__crc_\)\|\( \$[adt]\)\|\( \.L\)' > build/System.map

