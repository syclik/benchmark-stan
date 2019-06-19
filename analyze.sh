#!/usr/bin/env bash

OS=(mac linux)
N=10
threads=(no-thread 1 2 4)
branches=(old new)
models=(schools-4 warfarin)

echo "os,branch,model,type,minutes,seconds,threads" > time.txt
for os in "${OS[@]}"; do
    for thread in "${threads[@]}"; do
	echo "OS = $os;  thread = $thread"
	for branch in "${branches[@]}"; do
	    for model in "${models[@]}"; do
		grep "^real" $os/$branch-$model-$thread-time.txt | sed "s|\([a-z]*\).\([0-9]*\)m\([0-9.]*\)s|$os,$b,$model,\1,\2,\3,$thread|" >> time.txt
		grep "^sys" $os/$branch-$model-$thread-time.txt | sed "s|\([a-z]*\).\([0-9]*\)m\([0-9.]*\)s|$os,$b,$model,\1,\2,\3,$thread|" >> time.txt
		grep "^user" $os/$branch-$model-$thread-time.txt | sed "s|\([a-z]*\).\([0-9]*\)m\([0-9.]*\)s|$os,$b,$model,\1,\2,\3,$thread|" >> time.txt
	    done
	done
    done
done

