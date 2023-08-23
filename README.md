# fwlib & swig

# Instructions  

## I - Install package automatically
```
pip3 install -e git+https://github.com/tonejca/pyfwlib.git@swig#egg=fwlib
```

## II - Install library semi-automated  
get fwlib  
```
git submodule update --init --recursive
```

get swig  
```
wget -qO- http://prdownloads.sourceforge.net/swig/swig-4.0.2.tar.gz | tar xvz
cd ./swig-4.0.2
./configure
make
sudo make install # optional
```

## with setuptools  
```
python3.9 -m venv env      # create virtualenv
source env/bin/activate    # use virtualenv
python3.9 setup.py install # compile & link library
python3.9 test.py          # verify module works
```

## manual build  
```
./swig-4.0.2/swig -I./swig-4.0.2/Lib/ -I./swig-4.0.2/Lib/python/ -python fwlib.i                       # create swig bindings
ln -s extern/fwlib/libfwlib32-linux-x64.so.1.0.5 libfwlib32.so                                         # link fwlib shared library
gcc -fPIC -shared fwlib_wrap.c -o _fwlib.so -L. -lpthread -lm -lfwlib32 -I/usr/local/include/python3.9 # compile python module
LD_LIBRARY_PATH=. python3.9 test.py                                                                    # verify module works
```
