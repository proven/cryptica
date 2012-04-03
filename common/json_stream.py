#!/usr/bin/env python

import cStringIO
import gevent.server
import validictory


json_schema = None

def initialize_schema():
    with open('../common/schema.json', 'r') as f: 
        json_schema = json.load(f)
        # TODO: link up $refs manually, if necessary


def get_schema(name):
    return json_schema['properties'][name]


class JsonStream(object):
    def __init__(self, sock=None):
        self.send_queue = gevent.queue.Queue()
        if socket:
            self.sock = sock
        else:
            self._connect()

    def _connect():
        self.sock = gevent.socket.create_connection(('127.0.0.1', '9000'))
        self.ssl = gevent.ssl.wrap_socket(
                        self.sock,
                        certfile='../pki/data/certs/clientcert.pem',
                        keyfile='../pki/data/private/clientkey.pem',
                        ca_certs='../pki/data/certs/cacert.pem',
                        cert_reqs=ssl.CERT_REQUIRED,
                        ssl_version=ssl.PROTOCOL_TLSv1)

    def send(self, data):
        self.send_queue.put(data)

    def run(self):
        # Use an output queue to serialize socket writes which may be
        # triggered by both request processing and notifications.
    
        def writer():
            while True:
                data = send_queue.get()
                socket.write(data)
        send_greenlet = gevent.spawn(writer)
    
        try:
            # Accumulate input bytes into buffer and check for matching
            # outer {} of JSON-RPC call. Once matching brackets are found,
            # extract string and parse as JSON-RPC.
            
            MAX_MESSAGE_SIZE = 32768
            buffer = cStringIO.StringIO()
            bracket_count = 0
        
            while True:
                data = socket.read(4096)
                if not data:
                    raise Exception('Peer disconnected')
                if (buffer.tell() == 0 and
                    data[0] != '{'):
                    raise Exception('Missing expected {')
                start_index = 0
                for i in range(len(data)):
                    if data[i] == '{':
                        if bracket_count == 0:
                            start_index = i
                        bracket_count += 1
                    elif data[i] == '}':
                        bracket_count -= 1
                    if i > 0 and bracket_count == 0:
                        message = ''
                        if buffer.tell():
                            message = buffer.read()
                            buffer.truncate()
                        message += data[start_index:i]
                        handle_request(message)
                        start_index = i + 1
                leftover = data[start_index:]
                if buffer.tell() + len(leftover) > MAX_MESSAGE_SIZE:
                    raise Exception('Message too long')
                buffer.write(leftover)
        except Exception as e:
            print str(e)
            raise
        finally:
            send_greenlet.join(timeout=5)
            send_greenlet.kill()
            # TODO: remove send_queue from any subscriptions

    def spawn_run(self):
        gevent.spawn(self.run)


class JsonStreamServer(JsonStream):
    def __init__(self, sock):
        JsonStream.__init__(self, sock)

    def handle_message(self, message):
        request = json.loads(message)
        validictory.validate(request, get_schema('rpcRequest'))
        # TODO spawn greenlet for long-running request (allowing out-or-order response)
        response = {'id' : request.id}
        send_queue.put(json.dumps(response))


class JsonStreamClient(JsonStream):
    def __init__(self):
        JsonStream.__init__(self)
        self.next_id = 0
        self.pending_requests = {}

    def send_request(self, request):
        id = self.next_id
        self.next_id += 1
        request = {'id' : id}
        self.pending_requests[id] = request
        self.send(json.dumps(request))

    def handle_message(self, message):
        response = json.loads(message)
        # TODO: rpcNotification
        validictory.validate(response, get_schema('rpcResponse'))
        request = self.pending_requests.pop(response.id)
        self.handle_response(request, response)

    def handle_response(self, request, response):
        pass
