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
echo "CXXFLAGS += -DSTAN_THREADS" >> local
if [[ "$OSTYPE" == "linux-gnu" ]]; then
    echo "CXX=g++-5" >> local
else
    echo "CXX=/usr/local/opt/llvm@6/bin/clang++" >> local
fi
make build -j8

if [[ "$OSTYPE" == "linux-gnu" ]]; then
    FOLDER=linux
else
    FOLDER=mac
fi

mkdir -p $FOLDER

random_seed=3172019
N=10
threads=(2 4)

echo "Running once with 1 thread" | tee -a progress.txt
thread=1
n=1
export STAN_NUM_THREADS=$thread

{ time ./benchmark-warfarin-old data file=benchmark-warfarin.data.R init=benchmark-warfarin.init.R sample num_warmup=150 num_samples=150 random seed=$random_seed output refresh=150 file=$FOLDER/old-$thread-$random_seed-$n.csv; } 2> $FOLDER/old-$thread-time.txt

{ time ./benchmark-warfarin-new data file=benchmark-warfarin.data.R init=benchmark-warfarin.init.R sample num_warmup=150 num_samples=150 random seed=$random_seed output refresh=150 file=$FOLDER/new-$thread-$random_seed-$n.csv; } 2> $FOLDER/new-$thread-time.txt


echo "Comparing output" | tee -a progress.txt
tail -n +39 $FOLDER/old-$thread-$random_seed-$n.csv | sed -e :a -e '$d;N;2,5ba' -e 'P;D' > $FOLDER/old-ref.csv
tail -n +39 $FOLDER/new-$thread-$random_seed-$n.csv | sed -e :a -e '$d;N;2,5ba' -e 'P;D' > $FOLDER/new-ref.csv
diff $FOLDER/old-ref.csv $FOLDER/new-ref.csv

for n in $(seq 2 $N); do
    echo "running with $thread threads, iteration $n" | tee -a progress.txt
    { time ./benchmark-warfarin-old data file=benchmark-warfarin.data.R init=benchmark-warfarin.init.R sample num_warmup=150 num_samples=150 random seed=$random_seed output refresh=150 file=$FOLDER/old-$thread-$random_seed-$n.csv; } 2>> $FOLDER/old-$thread-time.txt
    { time ./benchmark-warfarin-new data file=benchmark-warfarin.data.R init=benchmark-warfarin.init.R sample num_warmup=150 num_samples=150 random seed=$random_seed output refresh=150 file=$FOLDER/new-$thread-$random_seed-$n.csv; } 2>> $FOLDER/new-$thread-time.txt
    tail -n +39 $FOLDER/new-$thread-$random_seed-$n.csv | sed -e :a -e '$d;N;2,5ba' -e 'P;D' > $FOLDER/new.csv
    diff $FOLDER/old-ref.csv $FOLDER/new.csv
done


for thread in "${threads[@]}"; do
    rm -f $FOLDER/old-$thread-time.txt $FOLDER/new-$thread-time.txt
    export STAN_NUM_THREADS=$thread
    for n in $(seq 1 $N); do
	echo "running with $thread threads, iteration $n" | tee -a progress.txt
	{ time ./benchmark-warfarin-old data file=benchmark-warfarin.data.R init=benchmark-warfarin.init.R sample num_warmup=150 num_samples=150 random seed=$random_seed output refresh=150 file=$FOLDER/old-$thread-$random_seed-$n.csv; } 2>> $FOLDER/old-$thread-time.txt
	{ time ./benchmark-warfarin-new data file=benchmark-warfarin.data.R init=benchmark-warfarin.init.R sample num_warmup=150 num_samples=150 random seed=$random_seed output refresh=150 file=$FOLDER/new-$thread-$random_seed-$n.csv; } 2>> $FOLDER/new-$thread-time.txt
	tail -n +39 $FOLDER/new-$thread-$random_seed-$n.csv | sed -e :a -e '$d;N;2,5ba' -e 'P;D' > $FOLDER/new.csv
	diff $FOLDER/old-ref.csv $FOLDER/new.csv
    done
done
