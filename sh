#!/usr/bin/env bash

remote_build ()
{
	ip=$1

	rsync --exclude="*" --include="*.h" --include="*.c" --include="*.S" -a . $ip::linux
	ssh $ip "cd /dev/shm/linux; make -j$2 "${@:3}" && find build -name "*.o" -o -name "*.d" | cpio -o > $ip.cpio 2> /dev/null"
	rsync $ip::linux/$ip.cpio .
	cpio -id < $ip.cpio 2> /dev/null
	rm $ip.cpio
}

prepare ()
{
	make clean && make prepare
	time echo "192.168.1.2::linux 192.168.1.4::linux" | xargs -n 1 rsync --delete --exclude=".git" --exclude="G*" -a .
}

build ()
{
	remote_build 192.168.1.2 12 fs mm drivers &
	pid[0]=$!
	
	remote_build 192.168.1.4 12 block &
	pid[1]=$!
	
	trap "kill ${pid[0]} ${pid[1]}; exit 1" INT
	
	make -j16 x86 lib_x86 kernel lib lib_lib init

	wait ${pid[0]} ${pid[1]}
	
	make -j16
}

$1
