#!/bin/bash
set -e

ROOT=$(pwd)
BUILD_DIR=$ROOT/build

rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

cd "$BUILD_DIR"

cmake -DCMAKE_BUILD_TYPE=Debug ..
cmake --build .

./unitTests --gtest_filter=CompMainTest.*