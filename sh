#!/usr/bin/env bash


dist () {
	ip=$1

	rsync --delete --exclude="*.git" --exclude="build" -a . $ip::linux
	ssh $1 "cd /dev/shm/linux; make -j$2 "${@:3}" && find build -name "*.o" | cpio -o > $ip.cpio 2> /dev/null"
	rsync $ip::linux/$1.cpio $1.cpio
	cpio -id < $1.cpio 2> /dev/null
	rm $1.cpio
}

dist 192.168.1.2 12 init net drivers mm &
pid[0]=$!
dist 192.168.1.4 12 fs lib_lib setup_objs &
pid[1]=$!
trap "kill ${pid[0]} ${pid[1]}; exit 1" INT
make -j16 x86 realmode_objs vobjs vmlinux_objs lib_x86 kernel block lib
wait
make -j16
