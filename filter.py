#!/usr/bin/python
'https://stackoverflow.com/a/45044199/493161'
def response(flow):
    '''
    Log response to a unique log for these host-port combinations
    '''
    fromaddr = flow.client_conn.address
    fromhost = fromaddr[0]
    fromport = str(fromaddr[1])
    tohost = flow.request.host
    toport = str(flow.request.port)
    logname = '.'.join((fromhost, fromport, tohost, toport)) + '.log'
    with open(f'/var/log/mitmproxy/{logname}', 'a') as logfile:
        print(f'Request from {fromhost}:{fromport} to'
              f' {tohost}:{toport}', file=logfile)
