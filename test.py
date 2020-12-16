import fwlib

from pprint import pprint


def main():
  ip = '127.0.0.1'
  port = 8193

  print('connecting to machine at {}:{}...'.format(ip, port))
  ret, libh = fwlib.cnc_allclibhndl3(ip, port, 10)

  if ret != 0:
      raise Exception('failed to connect')

  ret, cncids = fwlib.cnc_rdcncid(libh)

  machine_id = '-'.join([f'{v:08x}' for v in cncids])
  print(f'{machine_id=}')

  ret, sysinfo = fwlib.cnc_sysinfo(libh);
  pprint(sysinfo)

  ret, axes = fwlib.cnc_rdaxisname(libh);
  print(f'{axes=}')

  # class of data, kinds of data, num of axis
  ret, axisdata = fwlib.cnc_rdaxisdata(libh, 1, [0, 1, 2, 3]);
  pprint(axisdata)

  ret, axisdata = fwlib.cnc_rdaxisdata(libh, 2, [0, 1, 2]);
  pprint(axisdata)

  fwlib.cnc_freelibhndl(libh)


if __name__ == '__main__':
    main()
