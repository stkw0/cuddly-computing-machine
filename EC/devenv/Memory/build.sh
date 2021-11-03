#!/bin/sh

jwasm -coff prac.asm
/usr/bin/i686-w64-mingw32-g++ -c  memory.cpp
/usr/bin/i686-w64-mingw32-g++ memory.o prac.o -static-libgcc -static-libstdc++
