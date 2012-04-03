import json_stream
#from gevent import monkey; monkey.patch_all()
import socketio
import socketio.namespace
import socketio.mixins


class Service(json_stream.JsonStreamClient):
    def __init__(self, front_end):
        json_stream.JsonStreamClient.__init__(self)
        self.front_end = front_end

    def handle_response(self, request, response):
        self.io.emit('message', '...')

    def close(self):
        self.front_end.close() # TODO: loop?


class SocketIOFrontEnd(socketio.namespace.BaseNamespace):
    def __init__(self):
        self.service = None

    def get_initial_acl(self):
        return ['on_message']

    def process_packet(self, packet):
        # TODO: not receiving connect/disconnect
        print 'packet[type] = ' + packet['type']
        socketio.namespace.BaseNamespace.process_packet(self, packet)

    def recv_connect(self):
        print 'SocketIOFrontEnd recv_connect'
        # TODO: instance per connection?
        # self.service = ...

    def recv_disconnect(self):
        print 'SocketIOFrontEnd disconnecting'
        self.service.close()
        self.service = None

    def on_message(self, message):
        if not self.service:
            self.service = Service(self)
            self.service.spawn_run()
        self.service.send_request(message)

    def send_response(self, response):
        self.emit('message', json.dumps(response))


class WebServer(object):

    STATIC_FILES = {
        'index.html' : 'text/html',
        'socket.io-0.9.0.js' : 'text/javascript',
        'jquery-1.7.2.js' : 'text/javascript'
    }

    def __call__(self, environ, start_response):
        path = environ['PATH_INFO'].strip('/')
        if not path:
            path = 'index.html'
        if path in STATIC_FILES:
            try:
                data = open(path).read()
            except Exception:
                return _not_found(start_response)
            start_response('200 OK', [('Content-Type', STATIC_FILES[path])])
            return [data]
        if path.startswith('socket.io'):
            socketio.socketio_manage(environ, {'': SocketIOFrontEnd})
        else:
            return _not_found(start_response)

    def _not_found(start_response):
        start_response('404 Not Found', [])
        return ['<h1>Not Found</h1>']


if __name__ == '__main__':
    print 'Listening on port 8080 and on port 843 (flash policy server)'
    socketio.SocketIOServer(
        ('127.0.0.1', 8080),
        WebServer(),
        namespace='socket.io',
        policy_server=False).serve_forever()
