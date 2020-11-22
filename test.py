import fwlib

def main():
  ip = '127.0.0.1'
  port = 8193

  ret = fwlib.cnc_startupprocess(0, 'focas.log')

  print('connecting to machine at {}:{}...'.format(ip, port))
  ret, libh = fwlib.cnc_allclibhndl3(ip, port, 10)

  if ret != 0:
      raise Exception('failed to connect')

  ret, cncids = fwlib.cnc_rdcncid(libh)

  ids = [cncids[0] & 0xffffffff, cncids[0] >> 32 & 0xffffffff, cncids[1] & 0xffffffff, cncids[1] >> 32 & 0xffffffff]
  ids = '-'.join([f'{v:08x}' for v in ids])
  print(f'machine id: {ids}')

  fwlib.cnc_freelibhndl(libh)
  fwlib.cnc_exitprocess()


if __name__ == '__main__':
    main()
