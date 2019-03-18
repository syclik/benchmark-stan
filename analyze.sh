#!/usr/bin/env bash

OS=(mac linux)
N=10
threads=(1 2 4)


echo "OS,type,minutes,seconds,threads" > time.txt
for os in "${OS[@]}"; do
    for thread in "${threads[@]}"; do
	echo "OS = $os;  thread = $thread"
	grep "^real" $os/new-$thread-time.txt | sed "s|\([a-z]*\).\([0-9]*\)m\([0-9.]*\)s|$os,\1,\2,\3,$thread|" >> time.txt
	grep "^sys" $os/new-$thread-time.txt | sed "s|\([a-z]*\).\([0-9]*\)m\([0-9.]*\)s|$os,\1,\2,\3,$thread|" >> time.txt
	grep "^user" $os/new-$thread-time.txt | sed "s|\([a-z]*\).\([0-9]*\)m\([0-9.]*\)s|$os,\1,\2,\3,$thread|" >> time.txt
    done
done

