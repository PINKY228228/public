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
        ./tests/unit/run_unit_test.sh
        ;;
    coverage)
        echo "=== run all tests for coverage ==="

        ./tests/unit/run_unit_test.sh
        ./tests/csv/run_csv_test.sh

        echo "=== generate coverage ==="

        lcov --capture --directory . --output-file coverage.info
        lcov --remove coverage.info '/usr/*' --output-file coverage.info

        genhtml coverage.info --output-directory coverage_html

        echo ""
        echo "coverage html:"
        echo "coverage_html/index.html"
        ;;
    *)
        ./tests/unit/run_unit_test.sh
        ./tests/csv/run_csv_test.sh
        ;;
esac