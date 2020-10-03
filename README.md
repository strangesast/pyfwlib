# Fwlib python extension

## Installation instructions
0. Install `python3`(3.8+) and `git`  
1. Run `pip install -e git+https://github.com/strangesast/fanuc-python-extension@ea457e34302f7b61f9289859e9f19925716cc949#egg=fwlib`  
2. Import library with `import fwlib`  

## Testing instructions
0. Optionally bind remote cnc port to your machine with `ssh localhost -L localhost:8193:$MACHINE_IP:$MACHINE_PORT -N`
   where MACHINE_IP & MACHINE_PORT correspond to your machine's ip address and port (typically 8193)  
1. Install and run the example (details in `example/README.md`)  
