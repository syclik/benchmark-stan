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
echo "    - [x] run and record develop 1 time with fixed seed"
echo "    - [x] run and record feature/faster-ad-tls-v3 with fixed seed"
echo "    - [x] compare output to validate they are identical"
echo "    - [x] run and record develop N times with fixed seed"
echo "    - [x] run and record feature/faster-ad-tls-v3 N times with fixed seed"
echo "================================================================================"
echo ""
echo ""

echo $(date) | tee progress.txt

echo "Setup submodules" | tee -a progress.txt
git submodule update --init --recursive

echo "Building everything" | tee -a progress.txt
echo "" > local
if [[ "$OSTYPE" == "linux-gnu" ]]; then
    echo "CXX=g++-5" >> local
else
    echo "CXX=/usr/local/opt/llvm@6/bin/clang++" >> local
fi
make clean
make build -j8

if [[ "$OSTYPE" == "linux-gnu" ]]; then
    FOLDER=linux
else
    FOLDER=mac
fi

mkdir -p $FOLDER

random_seed=06112019
N=10

echo "--------------------------------------------------------------------------------" | tee -a progress.txt
echo "Running once with no thread" | tee -a progress.txt
n=1

{ time ./benchmark-warfarin-old data file=benchmark-warfarin.data.R init=benchmark-warfarin.init.R sample num_warmup=150 num_samples=150 random seed=$random_seed output refresh=150 file=$FOLDER/old-warfarin-no-thread-$random_seed-$n.csv; } 2> $FOLDER/old-warfarin-no-thread-time.txt

{ time ./benchmark-warfarin-new data file=benchmark-warfarin.data.R init=benchmark-warfarin.init.R sample num_warmup=150 num_samples=150 random seed=$random_seed output refresh=150 file=$FOLDER/new-warfarin-no-thread-$random_seed-$n.csv; } 2> $FOLDER/new-warfarin-no-thread-time.txt

{ time ./benchmark-schools-4-old data file=schools.data.R sample num_warmup=150 num_samples=150 random seed=$random_seed output refresh=150 file=$FOLDER/old-schools-4-no-thread-$random_seed-$n.csv; } 2> $FOLDER/old-schools-4-no-thread-time.txt

{ time ./benchmark-schools-4-new data file=schools.data.R sample num_warmup=150 num_samples=150 random seed=$random_seed output refresh=150 file=$FOLDER/new-schools-4-no-thread-$random_seed-$n.csv; } 2> $FOLDER/new-schools-4-no-thread-time.txt

echo "Comparing output" | tee -a progress.txt
tail -n +39 $FOLDER/old-warfarin-no-thread-$random_seed-$n.csv | sed -e :a -e '$d;N;2,5ba' -e 'P;D' > $FOLDER/old-warfarin-ref.csv
tail -n +39 $FOLDER/new-warfarin-no-thread-$random_seed-$n.csv | sed -e :a -e '$d;N;2,5ba' -e 'P;D' > $FOLDER/new-warfarin-ref.csv
diff $FOLDER/old-warfarin-ref.csv $FOLDER/new-warfarin-ref.csv

tail -n +39 $FOLDER/old-schools-4-no-thread-$random_seed-$n.csv | sed -e :a -e '$d;N;2,5ba' -e 'P;D' > $FOLDER/old-schools-4-ref.csv
tail -n +39 $FOLDER/new-schools-4-no-thread-$random_seed-$n.csv | sed -e :a -e '$d;N;2,5ba' -e 'P;D' > $FOLDER/new-schools-4-ref.csv
diff $FOLDER/old-schools-4-ref.csv $FOLDER/new-schools-4-ref.csv

for n in $(seq 2 $N); do
    echo "running with no threads, iteration $n" | tee -a progress.txt
    { time ./benchmark-warfarin-old data file=benchmark-warfarin.data.R init=benchmark-warfarin.init.R sample num_warmup=150 num_samples=150 random seed=$random_seed output refresh=150 file=$FOLDER/old-warfarin-no-thread-$random_seed-$n.csv; } 2>> $FOLDER/old-warfarin-no-thread-time.txt
    { time ./benchmark-warfarin-new data file=benchmark-warfarin.data.R init=benchmark-warfarin.init.R sample num_warmup=150 num_samples=150 random seed=$random_seed output refresh=150 file=$FOLDER/new-warfarin-no-thread-$random_seed-$n.csv; } 2>> $FOLDER/new-warfarin-no-thread-time.txt
    tail -n +39 $FOLDER/new-warfarin-no-thread-$random_seed-$n.csv | sed -e :a -e '$d;N;2,5ba' -e 'P;D' > $FOLDER/new.csv
    diff $FOLDER/old-warfarin-ref.csv $FOLDER/new.csv

    { time ./benchmark-schools-4-old data file=schools.data.R sample num_warmup=150 num_samples=150 random seed=$random_seed output refresh=150 file=$FOLDER/old-schools-4-no-thread-$random_seed-$n.csv; } 2>> $FOLDER/old-schools-4-no-thread-time.txt
    { time ./benchmark-schools-4-new data file=schools.data.R sample num_warmup=150 num_samples=150 random seed=$random_seed output refresh=150 file=$FOLDER/new-schools-4-no-thread-$random_seed-$n.csv; } 2>> $FOLDER/new-schools-4-no-thread-time.txt
    tail -n +39 $FOLDER/new-schools-4-no-thread-$random_seed-$n.csv | sed -e :a -e '$d;N;2,5ba' -e 'P;D' > $FOLDER/new.csv
    diff $FOLDER/old-schools-4-ref.csv $FOLDER/new.csv

done






