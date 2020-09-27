#from distutils.core import setup, Extension
from setuptools import setup, Extension
from os import path
import os

extension_module = Extension(
    'fwlib',
     sources=['fwlibmodule.c'],
     library_dirs=[path.join(os.getcwd(), './external/fwlib/')],
     runtime_library_dirs=[path.join(os.getcwd(), './external/fwlib/')],
     libraries=['fwlib32']
)

setup(
    name = 'fwlib',
    version = '0.1',
    description = '',
    ext_modules = [extension_module],
    include_dirs = [path.join(os.getcwd(), './external/fwlib')],
    packages=[''],
    package_data={'': ['external/fwlib/libfwlib32.so', 'external/fwlib/fwlib32.h']},
)
