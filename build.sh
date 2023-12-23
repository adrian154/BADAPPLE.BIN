#!/bin/bash
rm resources/frames/*
ffmpeg -i $1 -s 80x25 resources/frames/%d.ppm
node make-video.js
nasm bootsector.asm -o bootsector.bin
cat bootsector.bin video.bin > BADAPPLE