# fwlib & swig

```bash
git submodule update --init --recursive
# depending on architecture
ln -s extern/fwlib/libfwlib32-linux-x64.so.1.0.5 libfwlib32.so
# from virtualenv / Docker
python3 setup.py install
python3 test.py
```
