# -- Imports ------------------------------------------------------------------
import fwlib  # namespace
from types import TracebackType
from typing import Optional, Type


class FocasException(Exception):
    pass


class UnableToReadMacro(FocasException):
    """Raised when a macro could not be read"""


class UnableToReadAxis(FocasException):
    """Raised when an axis could not be read"""


class FocasController:
    def __init__(self, ip: str, port: int = 8193, sample_rate: int = 10):
        self.ip = ip
        self.port = port
        self.sample_rate = sample_rate
        self.library_handle = None

    def __enter__(self): # -> Focas:
        """Initialize the connector class"""

        self.connect()
        return self

    def __exit__(
        self,
        exception_type: Optional[Type[BaseException]],
        exception_value: Optional[BaseException],
        traceback: Optional[TracebackType],
    ) -> None:
        """Clean up the resources used by the storage class

        Parameters
        ----------

        exception_type:
            The type of the exception in case of an exception

        exception_value:
            The value of the exception in case of an exception

        traceback:
            The traceback in case of an exception

        """

        self.disconnect()

    def connect(self):
        ret, self.libh = fwlib.cnc_allclibhndl3(self.ip, self.port, self.sample_rate)
        if ret != 0:
            raise ConnectionError(
                f"Unable to connect to Focas control (IP: {self.ip}, Port:"
                f" {self.port})"
            )

        self.library_handle = self.libh
        assert self.library_handle is not None, "Library handle not initialized"

    def disconnect(self):
        fwlib.cnc_freelibhndl(self.library_handle)

    def read_macro(self, register: int) -> int:
        ret, (_, dataFeature) = fwlib.cnc_rdmacror2(self.library_handle, register)
        if ret != 0:
            raise UnableToReadMacro(f"Unable to read macro “{register}”")
        return dataFeature

    def read_axis(self, category: int, index: int) -> int:
        ret, axisdata = fwlib.cnc_rdaxisdata(self.library_handle, category, [index])
        if ret != 0:
            raise UnableToReadAxis(f"Unable to read axis data “{category}”, “{index}”")
        return axisdata


if __name__ == "__main__":
    nc_data = []
    focas_controller = FocasController("192.168.1.10")
    with focas_controller:
        try:
            axis_tuples = [[1, 0], [2, 0], [3, 0], [5, 0], [5, 1]]
            for tuple in axis_tuples:
                axisdata = focas_controller.read_axis(tuple[0], tuple[1])
                for axis in axisdata:
                    nc_data.append(axis[1])
            print(nc_data)
        except (ConnectionError, UnableToReadMacro, UnableToReadAxis) as error:
            print(error)
            focas_controller.disconnect()
    print(nc_data)
