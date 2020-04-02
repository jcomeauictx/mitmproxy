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
        print(f'Headers:', file=logfile)
        for k, v in flow.request.headers.items():
            print(f'{k}: {v}', file=logfile)
        print(file=logfile)
        print(f'Response from {tohost}:{toport} to'
              f' {fromhost}:{fromport}', file=logfile)
        print(f'Headers:', file=logfile)
        for k, v in flow.response.headers.items():
            print(f'{k}: {v}', file=logfile)
        print(file=logfile)
        print('Response payload:', file=logfile)
        print(flow.response.content.decode(), file=logfile)
