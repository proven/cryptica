#!/usr/bin/env python

import json_stream
import cryptica.common.transport


class RequestHandler(cryptica.common.transport.JsonRpcRequestHandler):
    def handle_request_setUser(self, request):
        return None, None

    def handle_request_getUsers(self, request):
        return None, None

    def handle_request_setGroup(self, request):
        return None, None

    def handle_request_getGroups(self, request):
        return None, None

    def handle_request_setDiscussion(self, request):
        return None, None

    def handle_request_getDiscussions(self, request):
        return None, None

    def handle_request_joinDiscussion(self, request):
        return None, None

    def handle_request_leaveDiscussion(self, request):
        return None, None

    def handle_request_putMessage(self, request):
        return None, None

    def handle_request_getMessages(self, request):
        return None, None

    def handle_request_putAttachment(self, request):
        return None, None

    def handle_request_getAttachment(self, request):
        return None, None


class Server(cryptica.common.transport.JsonRpcServer):
    def __init__(self):
        cryptica.common.transport.JsonRpcServer.__init__(
            handler=RequestHandler)


if __name__ == '__main__':
    server = Server()
    server.serve_forever()
