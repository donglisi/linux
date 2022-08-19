#!/usr/bin/env bash


dist () {
	ip=$1

	rsync --delete --exclude="*.git" --exclude="build" -a . $ip::linux
	ssh $1 "cd linux; make -j$2 "${@:3}" && find build -name "*.o" | cpio -o > /dev/shm/$ip.cpio 2> /dev/null"
	rsync $ip::shm/$1.cpio /dev/shm
	cpio -id < /dev/shm/$1.cpio 2> /dev/null
}

dist 192.168.1.3 16 kernel mm net lib &
pid[0]=$!
dist 192.168.1.4 12 fs block &
pid[1]=$!
trap "kill ${pid[0]} ${pid[1]}; exit 1" INT
make -j12 x86 drivers init lib_lib lib_x86
wait
make -j12
