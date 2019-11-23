#!/usr/bin/env bash


cd ..
git clone https://github.com/xmrig/xmrig.git
cd xmrig
git checkout v5.0.1
mkdir build
cd build
cmake ..
make
cd ..
cd ..

