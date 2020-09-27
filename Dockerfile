from python:3-slim-buster

#copy external/fwlib/libfwlib32-linux-x64.so.1.0.5 /usr/local/lib
#run ln -s /usr/local/lib/libfwlib32-linux-x64.so.1.0.5 /usr/local/lib/libfwlib32.so && ldconfig

run apt-get update -y && apt-get install -y build-essential

workdir /usr/src/fwlib

copy . .

run python3 setup.py install

workdir /usr/src/app

run python3 -c "import fwlib; print(fwlib);"
