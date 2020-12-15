#!/bin/bash
swig -python fwlib.i
gcc -fPIC -shared fwlib_wrap.c -o _fwlib.so -L. -lpthread -lm -lfwlib32 -I/usr/local/include/python3.9
