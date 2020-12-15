from i386/debian:buster

run apt-get update && apt-get install -y \
  swig \
  wget \
  xz-utils \
  build-essential \
  libssl-dev \
  zlib1g-dev

workdir /tmp
run wget -P /tmp https://www.python.org/ftp/python/3.9.0/Python-3.9.0.tar.xz && \
  tar -xf /tmp/Python-3.9.0.tar.xz -C /tmp
run ls /tmp

run wget -P /tmp https://phoenixnap.dl.sourceforge.net/project/swig/swig/swig-4.0.2/swig-4.0.2.tar.gz

run cd /tmp/Python-3.9.0 && \
  ./configure --enable-shared --enable-optimizations && \
  make -j4 && \
  make altinstall

copy extern/fwlib/libfwlib32-linux-x86.so.1.0.5 /usr/lib/libfwlib32.so
run ldconfig

workdir /usr/src/app

copy . .

run ./build.sh

cmd ./test.sh
