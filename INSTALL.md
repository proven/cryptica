INSTALL
=======

client service model: Python implementation
-------------------------------------------

1. Install Python 2.7

2. Install required modules

[Tornado]

tornado
tornadio2
ws4py 0.2.1(!), ('Sec-WebSocket-Version', WS_VERSION[-1])
validictory

[gevent]

port install py27-gevent
gevent-socketio

openssl-dev, libevent-dev
gcc47, pyOpenSSL?, pycrypto

3. Generate test certificates and keys

cd pki
./generate.sh

4. Run Mongo DB

...

5. Run server

cd server
python server.py

6. Run client service

cd client
python client.py

7. Start client

http://localhost:8080
