#!/bin/bash

# The micropython git repo and firmware.uf2 file should've been added to
# the .gitignore file for the picohelp git repository
sudo apt update &&
sudo apt install cmake gcc-arm-none-eabi libnewlib-arm-none-eabi build-essential &&
git clone -b master https://github.com/micropython/micropython.git &&
cd micropython/ &&
git submodule update --init -- lib/pico-sdk lib/tinyusb &&
make -C mpy-cross &&
cd ports/rp2/ &&
make &&
cd build-PICO/ &&
cp firmware.uf2 ../../../../
