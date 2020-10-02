from contextlib import contextmanager
import fwlib # type: ignore

@contextmanager
def get_machine_connection(machine_ip, machine_port=8193, timeout=10):
    """wrap machine connection setup / cleanup methods"""
    fwlib.allclibhndl3(machine_ip, machine_port, timeout)
    try:
        yield
    finally:
        fwlib.freelibhndl()

if __name__ == '__main__':
    with get_machine_connection('localhost'):
        res = fwlib.rdcncid()
        print(res)
