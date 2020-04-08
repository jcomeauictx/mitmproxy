#!/usr/bin/python
'https://stackoverflow.com/a/45044199/493161'
import os, time

LOGDIR = os.getenv('LOGDIR') or os.path.join('var', 'log', 'mitmproxy')
HOME = os.path.expanduser('~')
CONFDIR = os.getenv('CONFDIR') or os.path.join(HOME, '.mitmproxy')

def response(flow):
    '''
    Log response to a unique log for these host-port combinations
    '''
    clientfilter, serverfilter = [], []
    filterfile = os.path.join(CONFDIR, 'clientfilter.txt')
    if os.path.exists(filterfile):
        with open(filterfile) as infile:
            clientfilter = [line.rstrip() for line in infile.readlines()]
    filterfile = os.path.join(CONFDIR, 'serverfilter.txt')
    if os.path.exists(filterfile):
        with open(filterfile) as infile:
            serverfilter = [line.rstrip() for line in infile.readlines()]
    print(f'clientfilter: {clientfilter}, serverfilter: {serverfilter}')
    fromaddr = flow.client_conn.address
    fromhost = fromaddr[0]
    fromport = str(fromaddr[1])
    tohost = flow.request.host
    if clientfilter and fromhost not in clientfilter:
        print(f'***** KILLING CONNECTION FROM {fromhost} *****')
        flow.kill()
    elif serverfilter and tohost not in serverfilter:
        print(f'***** KILLING CONNECTION TO {tohost} *****')
        flow.kill()
    toport = str(flow.request.port)
    unixtime = str(int(time.time()))
    logname = '_'.join((fromhost, tohost, unixtime))
    logpath = os.path.join(LOGDIR, logname)
    with open(logpath, 'a') as logfile:
        print(f'Request from {fromhost}:{fromport} to'
              f' {tohost}:{toport}', file=logfile)
        print(f'Headers:', file=logfile)
        print(f'{flow.request.method} {flow.request.path}'
              f' {flow.request.http_version}', file=logfile)
        for k, v in flow.request.headers.items():
            value=' '.join(v.split())
            print(f'{k}: {value}', file=logfile)
        print(file=logfile)
        print(f'Response from {tohost}:{toport} to'
              f' {fromhost}:{fromport}', file=logfile)
        print(f'Headers:', file=logfile)
        reason = flow.response.reason or ''
        print(f'{flow.response.http_version} {flow.response.status_code}'
              f' {reason}', file=logfile)
        for k, v in flow.response.headers.items():
            value=' '.join(v.split())
            print(f'{k}: {value}', file=logfile)
        print(file=logfile)
        print('Response payload:', file=logfile)
        print(flow.response.content.decode(), file=logfile)
