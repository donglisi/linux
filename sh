#!/usr/bin/env bash

echo "192.168.1.3::linux/ 192.168.1.4::linux/" | xargs -n 1 rsync --delete --exclude="*.git" --exclude="build" -a .

dist () {
	ip=$1
	ssh $1 "cd linux; make -j$2 "${@:3}" && tar cf $1.tar build"
	scp $1:linux/$1.tar . > /dev/null
	ssh $1 "rm linux/$1.tar"
	tar xf $1.tar
	rm $1.tar
}

dist 192.168.1.3 16 kernel mm net lib &
pid[0]=$!
dist 192.168.1.4 12 fs block &
pid[1]=$!
trap "kill ${pid[0]} ${pid[1]}; exit 1" INT
make -j12 x86 drivers init lib_lib lib_x86
wait
make -j12
