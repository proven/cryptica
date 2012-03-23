cryptica
========

Currently, this is code for experimenting with different architectures for
a client-side encryption collaboration platform.

JavaScript client/UI model
--------------------------

UI and client-side crypto are implemented in JavaScript. To address the
trusted client issue, JavaScript is not served by the same server storing the
pre-encrypted data. This application is deployed via a static file, either
loaded directly (file://) or served from a static file server running on
localhost.

Issues:

* WSS Origin issue: can't run client as file:// (Chrome)
* Server certificate validation
** can't progamatically supply own CA in browser client.
** Chrome allows unsigned cert for WebSockets without warning; Firefox fails
unless user browses normally to domain.
* General concerns with JavaScript crypto
** "Javascript Cryptography Considered Harmful" http://www.matasano.com/articles/javascript-cryptography/
** "Final post on Javascript crypto" http://rdist.root.org/2010/11/29/final-post-on-javascript-crypto/
* Not using OpenSSL, which is subject to best scrutiny
** E.g., "Remote Timing Attacks are Still Practical" http://eprint.iacr.org/2011/232.pdf


JavaScript UI/client service model
----------------------------------

UI is implemented in JavaScript and run in a browser. A client "service" is a
localhost web server that serves the UI and also provides crypto services
(implemented in OpenSSL). The client service will provide additional services
including cert storage for cert-based authentication, indexing (pre-encryption),
and caching. The client uses a custom CA to authenticate the server.

Issues:

* Portability. Need to run a non-trivial web server on each target platform (
which includes mobile).