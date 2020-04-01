#!/usr/bin/python
'https://stackoverflow.com/a/45044199/493161'
def response(flow):
    print("")
    print("="*50)
    #print("FOR: " + flow.request.url)
    print(flow.request.method + " " + flow.request.path + " " + flow.request.http_version)

    print("-"*50 + "request headers:")
    for k, v in flow.request.headers.items():
        print("%-20s: %s" % (k.upper(), v))

    print("-"*50 + "response headers:")
    for k, v in flow.response.headers.items():
        print("%-20s: %s" % (k.upper(), v))
        print("-"*50 + "request headers:")
