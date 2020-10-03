from contextlib import contextmanager
import os
import fwlib  # type: ignore


@contextmanager
def get_machine_connection(machine_ip, machine_port=8193, timeout=10):
    """wrap machine connection setup / cleanup methods"""
    fwlib.allclibhndl3(machine_ip, machine_port, timeout)
    try:
        yield
    finally:
        fwlib.freelibhndl()


if __name__ == "__main__":
    machine_ip, machine_port = (
        os.environ.get("MACHINE_IP", "127.0.0.1"),
        os.environ.get("MACHINE_PORT", "8193"),
    )
    with get_machine_connection(machine_ip, int(machine_port)):
        result = fwlib.rdcncid()
        print(f"Machine's unique id is: {result.get('id')}")
