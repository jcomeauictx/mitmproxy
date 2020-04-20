import logging
from mitmproxy.proxy import protocol

logging.basicConfig(level=logging.INFO if __debug__ else logging.WARN)

class HttpProxy(protocol.Layer, protocol.ServerConnectionMixin):

    def __init__(self, *args, **kwargs):
        logging.info('HttpProxy init args: %s, kwargs: %s', args, kwargs)
        super().__init__(*args, **kwargs)

    def __call__(self):
        layer = self.ctx.next_layer(self)
        logging.info('HttpProxy.__call__: layer=%s', layer)
        try:
            layer()
        finally:
            if self.server_conn.connected():
                self.disconnect()


class HttpUpstreamProxy(protocol.Layer, protocol.ServerConnectionMixin):

    def __init__(self, ctx, server_address):
        super().__init__(ctx, server_address=server_address)
        logging.info('HttpUpstreamProxy: server_address=%s', server_address)

    def __call__(self):
        layer = self.ctx.next_layer(self)
        try:
            layer()
        finally:
            if self.server_conn.connected():
                self.disconnect()
