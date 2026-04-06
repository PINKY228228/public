#!/bin/bash
set -e

ROOT_DIR=$(cd "$(dirname "$0")/../.." && pwd)
BUILD_DIR="$ROOT_DIR/build"

#rm -rf build #おかしくなったら
cmake -S "$ROOT_DIR/project" -B "$BUILD_DIR" -DCMAKE_BUILD_TYPE=Debug
#cmake -S "$ROOT_DIR" -B "$BUILD_DIR" -DCMAKE_BUILD_TYPE=Debug
#cmake --build "$BUILD_DIR" --verbose
cmake --build "$BUILD_DIR"

cd "$BUILD_DIR"
# ctest:CMakeプロジェクトに登録された テストを実行するツール
#-R unitTests:テスト名が unitTests にマッチするものだけ実行
ctest -R unitTests --output-on-failure -V