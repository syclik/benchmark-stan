#!/usr/bin/env bash


echo Purpose: run the benchamrks on the local machine
echo 
echo TODO
echo ================================================================================
echo - [ ] prepare the program to run the non-stiff integrator
echo - [ ] build with math develop
echo - [ ] build with math feature/faster-ad-tls-v3
echo - [ ] estimate order of magnitude to run a time
echo - [ ] pick a number of times to run, N
echo - [ ] pick a random seed
echo - [ ] repeat for number of threads 1, 2, 3, 4
echo     - [ ] run and record develop 1 time with fixed seed
echo     - [ ] run and record feature/faster-ad-tls-v3 with fixed seed
echo     - [ ] compare output to validate they are identical
echo     - [ ] run and record develop N times with fixed seed
echo     - [ ] run and record feature/faster-ad-tls-v3 N times with fixed seed
echo     - [ ] run and record develop N times with different seeds
echo     - [ ] run and record feature/faster-ad-tls-v3 N times with different seeds (but same as above)
echo

