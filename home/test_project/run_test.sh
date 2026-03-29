#!/bin/bash
set -e

MODE=$1

# ./run_test.sh csv
# 実際のテスト数を見る方法
# ./build/tests/csv/csvTests.exe
# ./build/tests/unit/unitTests.exe

case "$MODE" in
    csv)
        ./tests/csv/run_csv_test.sh
        ;;
    unit)
        # ./run_test.sh unit
# ■cygwinをVSCで
# PS C:\cygwin64\home\PC_User> C:\cygwin64\bin\bash.exe --login -i
# PC_User@DESKTOP-1OPBE7G ~
# $ which rm
# /usr/bin/rm
        ./tests/unit/run_unit_test.sh
        ;;
    coverage)
    echo "=== clean build ==="

    rm -rf build

    echo "=== configure coverage build ==="

    cmake -S . -B build -DENABLE_COVERAGE=ON

    echo "=== build ==="

    cmake --build build

    echo "=== run tests ==="

    cd build
    ctest --output-on-failure
    cd ..

    echo "=== generate coverage ==="
lcov --capture --directory build \
--ignore-errors inconsistent,mismatch \
--rc lcov_branch_coverage=1 \
--output-file coverage.info

#lcov --capture --directory build \
#--ignore-errors inconsistent \
#--output-file coverage.info
    lcov --remove coverage.info \
'/usr/*' \
'*/tests/*' \
'*/third_party/*' \
--output-file coverage.info

genhtml coverage.info \
--output-directory coverage_html \
--rc lcov_branch_coverage=1

    #genhtml coverage.info --output-directory coverage_html

    echo ""
    echo "coverage html:"
    echo "coverage_html/index.html"
    ;;
esac