#!/usr/bin/env bash


cd ..
rm -rf xmrig/
git clone https://github.com/xmrig/xmrig.git
cd xmrig
git checkout v5.2.1
mkdir build
cd build
cmake ..
make 
cd ..
cd ..

