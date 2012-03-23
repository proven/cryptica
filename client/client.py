from gevent import monkey; monkey.patch_all()
import socketio
import socketio.namespace
import socketio.mixins
import ws4py.client.geventclient


class WebSocketBackEnd(ws4py.client.geventclient.WebSocketClient):

    def __init__(self, url, io, protocols=None, extensions=None):
        ws4py.client.geventclient.WebSocketClient.__init__(
            self, url, protocols, extensions)
        self.io = io

    def process_response_line(self, response_line):
        print 'process_response_line: ' + response_line
        ws4py.client.geventclient.WebSocketClient.process_response_line(self, response_line)

    def opened(self):
        print 'WebSocketBackEnd connected'

    def send(self, message):
        # TODO: encrypt
        ws4py.client.geventclient.WebSocketClient.send(self, message)

    def received_message(self, message):
        print 'WebSocketBackEnd received: ' + message.data
        self.io.emit('message', str(message.data))

    def closed(self, code, reason='No reason'):
        print 'WebSocketBackEnd disconnected: ' + reason
        #self.io.close() # TODO: close loop?


class SocketIOFrontEnd(socketio.namespace.BaseNamespace):

    def get_initial_acl(self):
        return ['on_message']

    def process_packet(self, packet):
        # TODO: not receiving connect/disconnect
        print 'packet[type] = ' + packet['type']
        socketio.namespace.BaseNamespace.process_packet(self, packet)

    def recv_connect(self):
        print 'SocketIOFrontEnd connecting...'
        # TODO: instance per connection?
        self.ws = WebSocketBackEnd('ws://127.0.0.1:9000', self)
        self.ws.connect()
        print 'SocketIOFrontEnd connected'

    def recv_disconnect(self):
        print 'SocketIOFrontEnd disconnecting'
        self.ws.close()
        self.ws = None

    def on_message(self, message):
        print 'SocketIOFrontEnd sending: ' + message
        if not hasattr(self, 'ws'):
            self.ws = WebSocketBackEnd('ws://127.0.0.1:9000', self)
            self.ws.connect()            
        self.ws.send(message)


STATIC_FILES = {
    'index.html' : 'text/html',
    'socket.io-0.9.0.js' : 'text/javascript',
    'jquery-1.7.2.js' : 'text/javascript'
}

class Server(object):

    def __init__(self):
        self.buffer = []

    def __call__(self, environ, start_response):
        path = environ['PATH_INFO'].strip('/')

        if not path:
            path = 'index.html'

        if path in STATIC_FILES:
            try:
                data = open(path).read()
            except Exception:
                return not_found(start_response)

            start_response('200 OK', [('Content-Type', STATIC_FILES[path])])
            return [data]

        if path.startswith('socket.io'):
            socketio.socketio_manage(environ, {'': SocketIOFrontEnd})
        else:
            return not_found(start_response)


def not_found(start_response):
    start_response('404 Not Found', [])
    return ['<h1>Not Found</h1>']


if __name__ == '__main__':
    print 'Listening on port 8080 and on port 843 (flash policy server)'
    socketio.SocketIOServer(
        ('127.0.0.1', 8080),
        Server(),
        namespace="socket.io",
        policy_server=False).serve_forever()
