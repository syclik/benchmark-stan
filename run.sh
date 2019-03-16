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
echo "- [ ] repeat for number of threads 1, 2, 3, 4"
echo "    - [ ] run and record develop 1 time with fixed seed"
echo "    - [ ] run and record feature/faster-ad-tls-v3 with fixed seed"
echo "    - [ ] compare output to validate they are identical"
echo "    - [ ] run and record develop N times with fixed seed"
echo "    - [ ] run and record feature/faster-ad-tls-v3 N times with fixed seed"
echo "    - [ ] run and record develop N times with different seeds"
echo "    - [ ] run and record feature/faster-ad-tls-v3 N times with different seeds \(but same as above\)"
echo "================================================================================"
echo ""
echo ""

echo "Setup submodules" | tee progress.txt
git submodule update --init --recursive

echo "Building everything" | tee progress.txt
echo "CPPFLAGS=-DSTAN_THREADS" > local
if [[ "$OSTYPE" == "linux-gnu" ]]; then
    echo "CXX=g++-5" >> local
else
    echo "CXX=clang++-6" >> local
fi
make build -j8

random_seed=3172019
N=10

echo "Running once" | tee progress.txt

echo "Compare output" | tee progress.txt
tail -n +39 old-123-1.csv | sed -e :a -e '$d;N;2,5ba' -e 'P;D' > old-ref.csv
tail -n +39 new-123-1.csv | sed -e :a -e '$d;N;2,5ba' -e 'P;D' > new-ref.csv




# if recording csv:
# old/new, num threads, seed,  timing results
