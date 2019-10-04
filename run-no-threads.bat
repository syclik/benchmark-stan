REM Run benchmarks on Windows

echo %DATE%%TIME%

echo "Setup submodules"
git submodule update --init --recursive

echo "Building everything"

make clean
make build -j4

mkdir windows

SET RANDOM_SEED=06112019
SET N_TOTAL=10

echo "--------------------------------------------------------------------------------"
echo "Running once with no thread"

SET N=1

powershell -C "Measure-Command {.\benchmark-warfarin-old.exe data file=benchmark-warfarin.data.R init=benchmark-warfarin.init.R sample num_warmup=150 num_samples=150 random seed=%RANDOM_SEED% output refresh=150 file=windows/old-warfarin-no-thread-%RANDOM_SEED%-%N%.csv }" > windows/old-warfarin-no-thread-time.txt

powershell -C "Measure-Command {.\benchmark-warfarin-new.exe data file=benchmark-warfarin.data.R init=benchmark-warfarin.init.R sample num_warmup=150 num_samples=150 random seed=%RANDOM_SEED% output refresh=150 file=windows/new-warfarin-no-thread-%RANDOM_SEED%-%N%.csv }" > windows/new-warfarin-no-thread-time.txt

powershell -C "Measure-Command {.\benchmark-schools-4-old.exe data file=schools.data.R sample num_warmup=150 num_samples=150 random seed=%RANDOM_SEED% output refresh=150 file=windows/old-schools-4-no-thread-%RANDOM_SEED%-%N%.csv }" > windows/old-schools-4-no-thread-time.txt

powershell -C "Measure-Command {.\benchmark-schools-4-new.exe data file=schools.data.R sample num_warmup=150 num_samples=150 random seed=%RANDOM_SEED% output refresh=150 file=windows/new-schools-4-no-thread-%RANDOM_SEED%-%N%.csv }" > windows/new-schools-4-no-thread-time.txt


echo "Comparing output"

REM how do you compare the output to make sure it's right?
REM tail -n +39 $FOLDER/old-warfarin-no-thread-$random_seed-$n.csv | sed -e :a -e '$d;N;2,5ba' -e 'P;D' > $FOLDER/old-warfarin-ref.csv
REM tail -n +39 $FOLDER/new-warfarin-no-thread-$random_seed-$n.csv | sed -e :a -e '$d;N;2,5ba' -e 'P;D' > $FOLDER/new-warfarin-ref.csv
REM diff $FOLDER/old-warfarin-ref.csv $FOLDER/new-warfarin-ref.csv

REM tail -n +39 $FOLDER/old-schools-4-no-thread-$random_seed-$n.csv | sed -e :a -e '$d;N;2,5ba' -e 'P;D' > $FOLDER/old-schools-4-ref.csv
REM tail -n +39 $FOLDER/new-schools-4-no-thread-$random_seed-$n.csv | sed -e :a -e '$d;N;2,5ba' -e 'P;D' > $FOLDER/new-schools-4-ref.csv
REM diff $FOLDER/old-schools-4-ref.csv $FOLDER/new-schools-4-ref.csv

FOR /L %I IN (2,1,%N_TOTAL%) DO (
powershell -C "Measure-Command {.\benchmark-warfarin-old.exe data file=benchmark-warfarin.data.R init=benchmark-warfarin.init.R sample num_warmup=150 num_samples=150 random seed=%RANDOM_SEED% output refresh=150 file=windows/old-warfarin-no-thread-%RANDOM_SEED%-%I.csv }" >> windows/old-warfarin-no-thread-time.txt

powershell -C "Measure-Command {.\benchmark-warfarin-new.exe data file=benchmark-warfarin.data.R init=benchmark-warfarin.init.R sample num_warmup=150 num_samples=150 random seed=%RANDOM_SEED% output refresh=150 file=windows/new-warfarin-no-thread-%RANDOM_SEED%-%I.csv }" >> windows/new-warfarin-no-thread-time.txt

powershell -C "Measure-Command {.\benchmark-schools-4-old.exe data file=schools.data.R sample num_warmup=150 num_samples=150 random seed=%RANDOM_SEED% output refresh=150 file=windows/old-schools-4-no-thread-%RANDOM_SEED%-%I.csv }" >> windows/old-schools-4-no-thread-time.txt

powershell -C "Measure-Command {.\benchmark-schools-4-new.exe data file=schools.data.R sample num_warmup=150 num_samples=150 random seed=%RANDOM_SEED% output refresh=150 file=windows/new-schools-4-no-thread-%RANDOM_SEED%-%I.csv }" >> windows/new-schools-4-no-thread-time.txt

)


