#!/usr/bin/env bash


old_branch=develop
new_branch=feature/faster-ad-tls-v3

echo "Purpose: run the benchamrks on the local machine"
echo ""
echo "TODO"
echo "================================================================================"
echo "- [ ] prepare the program to run the non-stiff integrator"
echo "- [ ] download the right versions of math"
echo "- [ ] build with math develop"
echo "- [ ] build with math feature/faster-ad-tls-v3"
echo "- [ ] estimate order of magnitude to run a time"
echo "- [ ] pick a number of times to run, N"
echo "- [ ] pick a random seed"
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

echo "Setup submodules"
if [ ! -d "cmstan-old" ]; then
  git submodule add https://github.com/stan-dev/cmdstan cmdstan-old
  pushd cmdstan-old
  git submodule update --init --recursive
  pushd stan/lib/stan_math
  git checkout $old_branch
  popd
  popd
  git commit -m "adding CmdStan-old submodule with $old_branch" cmdstan-old .gitmodules
  
fi
if [ ! -d "cmdstan-new" ]; then
  git submodule add https://github.com/stan-dev/cmdstan cmdstan-new
  pushd cmdstan-new
  git submodule update --init --recursive
  pushd stan/lib/stan_math
  git checkout $new_branch
  popd
  popd
  git commit -m "adding CmdStan-new submodule with $new_branch" cmdstan-new .gitmodules
fi

