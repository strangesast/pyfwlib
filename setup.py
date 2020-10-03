import os
import platform
from setuptools import setup, Extension


libpath = os.path.join(os.getcwd(), "external/fwlib/libfwlib32.so")
if not os.path.isfile(libpath):
    plat = "linux"
    machine = platform.machine()
    version = "1.0.5"
    if machine == "x86_64":
        arch = "x64"
    elif machine == "i386":
        arch = "x86"
    elif machine.startswith("arm"):
        arch = "arm"
    else:
        pass
    fname = f"libfwlib32-{plat}-{arch}.so.{version}"
    os.symlink(fname, "external/fwlib/libfwlib32.so")
    os.symlink(fname, "external/fwlib/libfwlib32.so.1")

setup(
    name="fwlib",
    version="0.1",
    description="",
    ext_modules=[
        Extension(
            "fwlib",
            sources=["fwlibmodule.c"],
            # used during linking
            library_dirs=[os.path.join(os.getcwd(), "external/fwlib/")],
            libraries=["fwlib32"],
            # used during runtime
            runtime_library_dirs=[os.path.join(os.getcwd(), "external/fwlib")],
        )
    ],
    # used to locate c header files
    include_dirs=[os.path.join(os.getcwd(), "./external/fwlib")],
    package_data={
        "": [
            "external/fwlib/libfwlib32-linux-x86.so.1.0.5",
            "external/fwlib/libfwlib32-linux-x64.so.1.0.5",
            "external/fwlib/libfwlib32-linux-armv7.so.1.0.5",
            "external/fwlib/fwlib32.h",
        ]
    },
)
