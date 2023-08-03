import os
import platform
from setuptools import setup, Extension

fwlib_dir = os.path.join(os.getcwd(), "extern/fwlib")
libpath = os.path.join(fwlib_dir, "libfwlib32.so")
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
    # print(f"{fname=}", f"{libpath=}")
    os.symlink(fname, os.path.join(fwlib_dir, "libfwlib32.so"))
    os.symlink(fname, os.path.join(fwlib_dir, "libfwlib32.so.1"))

setup(
    name="fwlib",
    version="0.1",
    description="",
    ext_modules=[
        Extension(
            "_fwlib",
            sources=["fwlib.i"],
            swig_opts=['-builtin'],
            #swig_opts=['-shadow'],
            # used during linking
            library_dirs=[fwlib_dir],
            include_dirs=[fwlib_dir],
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
