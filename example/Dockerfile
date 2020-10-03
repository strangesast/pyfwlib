from python:3-slim-buster

workdir /usr/src/app

run dpkg --add-architecture i386 && apt-get update -y && apt-get install -y build-essential

copy . .

#run ./external/fwlib/install.sh && \
run python3 setup.py install

#copy external/fwlib/libfwlib32-linux-x64.so.1.0.5 /usr/local/lib
#run ln -s /usr/local/lib/libfwlib32-linux-x64.so.1.0.5 /usr/local/lib/libfwlib32.so && ldconfig

#
#workdir /usr/src/fwlib
#
#copy . .
#
#
#workdir /usr/src/app
#
run python3 -c "import fwlib; print(fwlib);"
