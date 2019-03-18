#!/usr/bin/env bash

OS=(mac linux)
N=10
threads=(1 2 4)
branch=(old new)


echo "os,branch,type,minutes,seconds,threads" > time.txt
for os in "${OS[@]}"; do
    for thread in "${threads[@]}"; do
	echo "OS = $os;  thread = $thread"
	for b in "${branch[@]}"; do
	    grep "^real" $os/$b-$thread-time.txt | sed "s|\([a-z]*\).\([0-9]*\)m\([0-9.]*\)s|$os,$b,\1,\2,\3,$thread|" >> time.txt
	    grep "^sys" $os/$b-$thread-time.txt | sed "s|\([a-z]*\).\([0-9]*\)m\([0-9.]*\)s|$os,$b,\1,\2,\3,$thread|" >> time.txt
	    grep "^user" $os/$b-$thread-time.txt | sed "s|\([a-z]*\).\([0-9]*\)m\([0-9.]*\)s|$os,$b,\1,\2,\3,$thread|" >> time.txt
	done
    done
done

