#!/bin/bash

# Windowsキー押す
# powershell と入力
# Windows PowerShell を起動
# taskkill /F /IM bash.exe
# taskkill /F /IM mintty.exe

set -ex

echo "start test"

rm -rf build
mkdir build
cd build

echo "configure"
cmake ..

echo "build"
make -j$(nproc)

echo "run test"
ctest --output-on-failure

echo "collect coverage"
lcov --capture \
     --directory . \
     --output-file coverage.info \
     --ignore-errors empty,inconsistent
#lcov --capture --directory . --output-file coverage.info --ignore-errors empty

echo "filter coverage"
lcov --capture \
     --directory . \
     --output-file coverage.info \
     --ignore-errors empty,inconsistent
# lcov --remove coverage.info '/usr/*' '*/googletest/*' \
#      --output-file coverage_filtered.info --ignore-errors empty

echo "generate html"
# 必要
# 検索　TimeDate
# perl-TimeDate
# cd test_project2
# cd build
# ls *.info
# coverage.info
# genhtml coverage.info --output-directory coverage
# C:\cygwin64\home\PC_User\test_project2\build\coverage
# 配下にhtml生成される
echo "coverage report:"
echo "$(pwd)/coverage/index.html"