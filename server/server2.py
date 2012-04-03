#!/usr/bin/env python

import json_stream


def handle_stream(socket, address):
    stream = json_stream.ServerJsonStream(socket)
    stream.run()


if __name__ == '__main__':
    initialize_schema()
    server = gevent.server.StreamServer(
                ('127.0.0.1', 9000),
                handle_stream,
                certfile='../pki/data/certs/servercert.pem',
                keyfile='../pki/data/private/serverkey.pem',
                ca_certs='../pki/data/certs/cacert.pem',
                cert_reqs=ssl.CERT_REQUIRED,
                ssl_version=ssl.PROTOCOL_TLSv1)
    server.serve_forever()
