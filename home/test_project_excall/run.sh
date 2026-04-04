#!/bin/bash
set -e

ROOT=$(pwd)
BUILD_DIR=$ROOT/build

rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

cd "$BUILD_DIR"

cmake -DCMAKE_BUILD_TYPE=Debug ..
cmake --build .

# ctest:CMakeプロジェクトに登録された テストを実行するツール
#-R unitTests:テスト名が unitTests にマッチするものだけ実行
ctest -R unitTests --output-on-failure -V
#./unitTests --gtest_filter=CompMainTest.*