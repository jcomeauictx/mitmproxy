'''
python2/3 compatibility shims for libmproxy
'''
import logging
try:
    import proxy, filt, flow, utils, controller, version, app, \
        platform, tnetstring, encoding, script
except ImportError:
    from . import proxy, filt, flow, utils, controller, version, app, \
        platform, tnetstring, encoding, script
try:
    import Queue
except ImportError:
    import queue as Queue
# python3 io.BytesIO is cStringIO.StringIO in Python2
try:
    import cStringIO
except ImportError:
    import io as cStringIO  # python3
try:
    from io import BytesIO
except ImportError:
    BytesIO = cStringIO.StringIO
# file, unicode, and basestring don't exist in python3
try:
    file
except NameError:
    file = open  # or better, io.open?
try:
    unicode
except NameError:
    unicode = str
try:
    basestring
except NameError:
    basestring = str
# urllib stuff
try:
    import urlparse
except ImportError:
    from urllib import parse as urlparse  # python3
try:
    from urllib import urlencode
except ImportError:
    from urllib.parse import urlencode
try:
    from cgi import parse_qsl
except ImportError:
    from urllib.parse import parse_qsl
try:
    import cookielib
    from Cookie import SimpleCookie
except ImportError:
    import http.cookiejar as cookielib
    from http.cookies import SimpleCookie  # server-side cookies
try:
    from urllib import quote, unquote
except ImportError:
    from urllib.parse import quote, unquote
# socketserver
try:
    import SocketServer
except ImportError:
    import socketserver as SocketServer
logging.basicConfig(level=logging.DEBUG if __debug__ else logging.INFO)
