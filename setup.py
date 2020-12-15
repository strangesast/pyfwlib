import os
import platform
from setuptools import setup, Extension

fwlib_dir = os.path.join(os.getcwd(), "extern/fwlib/")

setup(
    name="fwlib",
    version="0.1",
    description="",
    ext_modules=[
        Extension(
            "_fwlib",
            sources=["fwlib_wrap.c"],
            # used during linking
            library_dirs=[fwlib_dir],
            libraries=["fwlib32"],
            # used during runtime
            runtime_library_dirs=[fwlib_dir],
        )
    ],
    # used to locate c header files
    include_dirs=[fwlib_dir],
    package_data={
        "": [
            os.path.join(fwlib_dir, "libfwlib32-linux-x86.so.1.0.5"),
            os.path.join(fwlib_dir, "libfwlib32-linux-x64.so.1.0.5"),
            os.path.join(fwlib_dir, "libfwlib32-linux-armv7.so.1.0.5"),
            os.path.join(fwlib_dir, "fwlib32.h"),
        ]
    },
)
