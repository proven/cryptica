from gevent import monkey; monkey.patch_all()
import ws4py.websocket
import ws4py.server.geventserver


class Server(ws4py.websocket.WebSocket):

    def received_message(self, message):
        print 'Server echoing: ' + message.data
        self.send(message.data, message.is_binary)


if __name__ == '__main__':
    server = ws4py.server.geventserver.WebSocketServer(
                ('127.0.0.1', 9000),
                websocket_class=Server)
    server.serve_forever()
