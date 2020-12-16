from strangesast/fwlib:python

run apt-get update && apt-get install -y \
  swig \
  build-essential \
  libssl-dev \
  zlib1g-dev

workdir /usr/src/app

copy . .

run python3 setup.py install

cmd python3 test.py
