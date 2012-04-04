import cryptica.common.transport
#from gevent import monkey; monkey.patch_all()...?
import socketio
import socketio.namespace
import socketio.mixins


class Client(cryptica.common.transport.JsonRpcClient):
    def __init__(self, front_end):
        cryptica.common.transport.Client.__init__(self)
        self.front_end = front_end

    def _relay_response(self, request, response):
        self.front_end.send_response(request, response)

    def close(self):
        self.front_end.close() # TODO: loop?

    def handle_response_setUser(self, request, response):
        self._relay_response(request, response)

    def handle_response_getUsers(self, request, response):
        pass

    def handle_response_setGroup(self, request, response):
        pass

    def handle_response_getGroups(self, request, response):
        pass

    def handle_response_setDiscussion(self, request, response):
        pass

    def handle_response_getDiscussions(self, request, response):
        pass

    def handle_response_joinDiscussion(self, request, response):
        pass

    def handle_response_leaveDiscussion(self, request, response):
        pass

    def handle_response_putMessage(self, request, response):
        pass

    def handle_response_getMessages(self, request, response):
        pass

    def handle_response_putAttachment(self, request, response):
        pass

    def handle_response_getAttachment(self, request, response):
        pass

    def handle_notification_newMessage(self, notification):
        pass

    def handle_notification_userJoined(self, notification):
        pass

    def handle_notification_userLeft(self, notification):
        pass


class SocketIOFrontEnd(socketio.namespace.BaseNamespace):
    def __init__(self):
        self.service = None

    def get_initial_acl(self):
        return ['on_request']

    def process_packet(self, packet):
        # TODO: not receiving connect/disconnect
        print 'packet[type] = ' + packet['type']
        socketio.namespace.BaseNamespace.process_packet(self, packet)

    def recv_connect(self):
        print 'SocketIOFrontEnd recv_connect'
        # TODO: instance per connection?
        # self.client = ...

    def recv_disconnect(self):
        print 'SocketIOFrontEnd disconnecting'
        self.client.close()
        self.client = None

    def on_request(self, request):
        # parse... (TODO: different schema)
        if not self.service:
            self.client = Client(self)
            self.client.start()
        self.client.send_request(request)

    def send_response(self, request, response):
        self.emit('response', [request, response])


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
