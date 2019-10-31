// Example of the server https is taken from here: https://engineering.circle.com/https-authorized-certs-with-node-js-315e548354a2
// Conversion of client1-crt.pem to certificate.pfx: https://stackoverflow.com/a/38408666/4637638
const express = require('express')
var https = require('https')
const auth = require('basic-auth')
const appHttps = express()
const appAuthBasic = express()
const fs = require('fs')

var options = { 
  key: fs.readFileSync('server-key.pem'), 
  cert: fs.readFileSync('server-crt.pem'), 
  ca: fs.readFileSync('ca-crt.pem'), 
  requestCert: true,
  rejectUnauthorized: false
};

appHttps.get('/', (req, res) => {
	const cert = req.connection.getPeerCertificate()

// The `req.client.authorized` flag will be true if the certificate is valid and was issued by a CA we white-listed
// earlier in `opts.ca`. We display the name of our user (CN = Common Name) and the name of the issuer, which is
// `localhost`.

	if (req.client.authorized) {
		res.send(`Hello ${cert.subject.CN}, your certificate was issued by ${cert.issuer.CN}!`)
// They can still provide a certificate which is not accepted by us. Unfortunately, the `cert` object will be an empty
// object instead of `null` if there is no certificate at all, so we have to check for a known field rather than
// truthiness.

	} else if (cert.subject) {
		res.status(403).send(`Sorry ${cert.subject.CN}, certificates from ${cert.issuer.CN} are not welcome here.`)
// And last, they can come to us with no certificate at all:
	} else {
		res.status(401).send(`Sorry, but you need to provide a client certificate to continue.`)
	}
})

// Let's create our HTTPS server and we're ready to go.
https.createServer(options, appHttps).listen(4433)

// Ensure this is before any other middleware or routes
appAuthBasic.use((req, res, next) => {
  let user = auth(req)

  if (user === undefined || user['name'] !== 'user 1' || user['pass'] !== 'password 1') {
    res.statusCode = 401
    res.setHeader('WWW-Authenticate', 'Basic realm="Node"')
    res.end('Unauthorized')
  } else {
    next()
  }
})

appAuthBasic.get("/", (req, res) => {
  res.send(`
    <html>
      <head>
      </head>
      <body>
        <p>HELLO</p>
      </body>
    </html>
  `);
})

appAuthBasic.listen(8081)