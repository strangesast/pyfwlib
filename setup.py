#from distutils.core import setup, Extension
import os
import platform
from os import path
from setuptools import setup, Extension

#os.environ["CC"] = "gcc"
#os.environ["CXX"] = "gcc"
extension_module = Extension(
    'fwlib',
     sources=['fwlibmodule.c'],
     #library_dirs=[path.join(os.getcwd(), './external/fwlib/')],
     #runtime_library_dirs=[path.join(os.getcwd(), './external/fwlib/')],
     libraries=['fwlib32']
)

setup(
    name = 'fwlib',
    version = '0.1',
    description = '',
    ext_modules = [extension_module],
    #include_dirs = [path.join(os.getcwd(), './external/fwlib')],
    #package_data={'': ['external/fwlib/libfwlib32.so', 'external/fwlib/fwlib32.h']},
)
