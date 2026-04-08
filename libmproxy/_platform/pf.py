import logging
logging.basicConfig(level=logging.DEBUG if __debug__ else logging.INFO)

def lookup(address, port, s):
    '''
    Parse the pfctl state output s, to look up the destination host
    matching the client (address, port).

    Returns an (address, port) tuple, or None.
    '''
    spec = ('%s:%s' % (address, port)).encode()
    logging.debug('pf.lookup: s=%r', s)
    for i in s.split(b'\n'):
        if b'ESTABLISHED:ESTABLISHED' in i and spec in i:
            s = i.split()
            if len(s) > 4:
                s = s[4].split(b':')
                if len(s) == 2:
                    return s[0], int(s[1])
