#!/usr/bin/env bash


echo "Purpose: run the benchamrks on the local machine"
echo ""
echo "TODO"
echo "================================================================================"
echo "- [x] prepare the program to run the non-stiff integrator"
echo "- [x] N/A. download the right versions of math"
echo "- [x] build with math develop"
echo "- [x] build with math feature/faster-ad-tls-v3"
echo "- [x] estimate order of magnitude to run a time: 250 x 250 = ~6 min"
echo "- [x] pick a number of times to run, 10"
echo "- [x] pick a random seed, 3172019"
echo "- [x] repeat for number of threads 1, 2, 3, 4"
echo "    - [x] run and record develop 1 time with fixed seed"
echo "    - [x] run and record feature/faster-ad-tls-v3 with fixed seed"
echo "    - [x] compare output to validate they are identical"
echo "    - [x] run and record develop N times with fixed seed"
echo "    - [x] run and record feature/faster-ad-tls-v3 N times with fixed seed"
echo "    - [ ] run and record develop N times with different seeds"
echo "    - [ ] run and record feature/faster-ad-tls-v3 N times with different seeds \(but same as above\)"
echo "================================================================================"
echo ""
echo ""

echo $(date) | tee progress.txt

echo "Setup submodules" | tee -a progress.txt
git submodule update --init --recursive

echo "Building everything" | tee -a progress.txt
echo "STAN_THREADS=true" > local
echo "CXXFLAGS += -DSTAN_THREADS"
if [[ "$OSTYPE" == "linux-gnu" ]]; then
    echo "CXX=g++-5" >> local
else
    echo "CXX=clang++" >> local
fi
make build -j8

random_seed=3172019
N=10
threads=(4 8)

echo "Running once with 1 thread" | tee -a progress.txt
thread=1
n=1
export STAN_NUM_THREADS=$thread

{ time ./benchmark-warfarin-old data file=benchmark-warfarin.data.R init=benchmark-warfarin.init.R sample num_warmup=250 num_samples=250 random seed=$random_seed output refresh=250 file=old-$thread-$random_seed-$n.csv; } 2> old-$thread-time.txt

{ time ./benchmark-warfarin-new data file=benchmark-warfarin.data.R init=benchmark-warfarin.init.R sample num_warmup=250 num_samples=250 random seed=$random_seed output refresh=250 file=new-$thread-$random_seed-$n.csv; } 2> new-$thread-time.txt


echo "Comparing output" | tee -a progress.txt
tail -n +39 old-$thread-$random_seed-$n.csv | sed -e :a -e '$d;N;2,5ba' -e 'P;D' > old-ref.csv
tail -n +39 new-$thread-$random_seed-$n.csv | sed -e :a -e '$d;N;2,5ba' -e 'P;D' > new-ref.csv
diff old-ref.csv new-ref.csv

for n in {2..$N}; do
    echo "running with $thread threads, iteration $n" | tee -a progress.txt
    { time ./benchmark-warfarin-old data file=benchmark-warfarin.data.R init=benchmark-warfarin.init.R sample num_warmup=250 num_samples=250 random seed=$random_seed output refresh=250 file=old-$thread-$random_seed-$n.csv; } 2>> old-$thread-time.txt
    { time ./benchmark-warfarin-new data file=benchmark-warfarin.data.R init=benchmark-warfarin.init.R sample num_warmup=250 num_samples=250 random seed=$random_seed output refresh=250 file=new-$thread-$random_seed-$n.csv; } 2>> new-$thread-time.txt
    tail -n +39 new-$thread-$random_seed-$n.csv | sed -e :a -e '$d;N;2,5ba' -e 'P;D' > new.csv
    diff old-ref.csv new.csv
done


for thread in "${threads[@]}"; do
    rm -f old-$thread-time.txt new-$thread-time.txt
    export STAN_NUM_THREADS=$thead
    for n in {2..$N}; do
	echo "running with $thread threads, iteration $n" | tee -a progress.txt
	{ time ./benchmark-warfarin-old data file=benchmark-warfarin.data.R init=benchmark-warfarin.init.R sample num_warmup=250 num_samples=250 random seed=$random_seed output refresh=250 file=old-$thread-$random_seed-$n.csv; } 2>> old-$thread-time.txt
	{ time ./benchmark-warfarin-new data file=benchmark-warfarin.data.R init=benchmark-warfarin.init.R sample num_warmup=250 num_samples=250 random seed=$random_seed output refresh=250 file=new-$thread-$random_seed-$n.csv; } 2>> new-$thread-time.txt
	tail -n +39 new-$thread-$random_seed-$n.csv | sed -e :a -e '$d;N;2,5ba' -e 'P;D' > new.csv
	diff old-ref.csv new.csv
    done
done
