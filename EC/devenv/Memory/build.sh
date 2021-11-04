#!/bin/sh

jwasm -coff prac.asm
/usr/bin/i686-w64-mingw32-g++ -c  main.cpp
/usr/bin/i686-w64-mingw32-g++ main.o prac.o -static-libgcc -static-libstdc++
