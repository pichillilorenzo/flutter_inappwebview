// Example of the server https is taken from here: https://engineering.circle.com/https-authorized-certs-with-node-js-315e548354a2
// Conversion of client1-crt.pem to certificate.pfx: https://stackoverflow.com/a/38408666/4637638
const express = require('express')
const https = require('https')
const cors = require('cors')
const auth = require('basic-auth')
const app = express()
const appHttps = express()
const appAuthBasic = express()
const fs = require('fs')
const path = require('path')
const bodyParser = require('body-parser');
const multiparty = require('multiparty');

var options = {
  key: fs.readFileSync('server-key.pem'),
  cert: fs.readFileSync('server-crt.pem'),
  ca: fs.readFileSync('ca-crt.pem'),
  requestCert: true,
  rejectUnauthorized: false
};

appHttps.get('/', (req, res) => {
  console.log(JSON.stringify(req.headers))
	const cert = req.connection.getPeerCertificate()

  // The `req.client.authorized` flag will be true if the certificate is valid and was issued by a CA we white-listed
  // earlier in `opts.ca`. We display the name of our user (CN = Common Name) and the name of the issuer, which is
  // `localhost`.

	if (req.client.authorized) {
		res.send(`
      <html>
        <head>
        </head>
        <body>
          <h1>Authorized</h1>
        </body>
      </html>
    `);
  // They can still provide a certificate which is not accepted by us. Unfortunately, the `cert` object will be an empty
  // object instead of `null` if there is no certificate at all, so we have to check for a known field rather than
  // truthiness.

	} else if (cert.subject) {
    console.log(`Sorry ${cert.subject.CN}, certificates from ${cert.issuer.CN} are not welcome here.`);
		res.status(403).send(`
      <html>
        <head>
        </head>
        <body>
          <h1>Forbidden</h1>
        </body>
      </html>
    `);
  // And last, they can come to us with no certificate at all:
	} else {
	  console.log(`Sorry, but you need to provide a client certificate to continue.`)
		res.status(401).send(`
      <html>
        <head>
        </head>
        <body>
          <h1>Unauthorized</h1>
        </body>
      </html>
    `);
	}
	res.end()
})

// Let's create our HTTPS server and we're ready to go.
https.createServer(options, appHttps).listen(4433)



// Ensure this is before any other middleware or routes
appAuthBasic.use((req, res, next) => {
  let user = auth(req)

  if (user === undefined || user['name'] !== 'USERNAME' || user['pass'] !== 'PASSWORD') {
    res.statusCode = 401
    res.setHeader('WWW-Authenticate', 'Basic realm="Node"')
    res.send(`
        <html>
          <head>
          </head>
          <body>
            <h1>Unauthorized</h1>
          </body>
        </html>
      `);
    res.end()
  } else {
    next()
  }
});

appAuthBasic.use(express.static(__dirname + '/public'));

appAuthBasic.get("/", (req, res) => {
  console.log(JSON.stringify(req.headers))
  res.send(`
    <html>
      <head>
      </head>
      <body>
        <h1>Authorized</h1>
      </body>
    </html>
  `);
  res.end()
});

appAuthBasic.get('/test-index', (req, res) => {
    res.sendFile(__dirname + '/public/test-index.html');
});

appAuthBasic.listen(8081);


app.use(cors());

app.use(bodyParser.urlencoded({extended: false}));
// Parse JSON bodies (as sent by API clients)
app.use(bodyParser.json());

app.use(express.static(__dirname + '/public'));

app.get("/", (req, res) => {
  console.log(JSON.stringify(req.headers))
  res.send(`
    <html>
      <head>
      </head>
      <body>
        <p>HELLO</p>
      </body>
    </html>
  `);
  res.end()
})

app.get('/test-index', (req, res) => {
    res.sendFile(__dirname + '/public/index.html');
})

app.post("/test-post", (req, res) => {
  console.log(JSON.stringify(req.headers))
  console.log(JSON.stringify(req.body))
  res.send(`
    <html>
      <head>
      </head>
      <body>
        <p>HELLO ${req.body.name}!</p>
      </body>
    </html>
  `);
  res.end()
})

app.post("/test-ajax-post", (req, res) => {
  console.log(JSON.stringify(req.headers));
  if (req.headers["content-type"].indexOf("multipart/form-data;") === 0) {
    const form = new multiparty.Form();
    form.parse(req, function(err, fields, files) {
      console.log(fields);
      res.set("Content-Type", "application/json")
      res.send(JSON.stringify({
        "firstname": fields.firstname[0],
        "lastname": fields.lastname[0],
      }));
      res.end();
    });
  } else {
    console.log(req.body);
    res.set("Content-Type", "application/json")
    res.send(JSON.stringify({
      "firstname": req.body.firstname,
      "lastname": req.body.lastname,
    }));
    res.end();
  }
})

app.get("/test-download-file", (req, res) => {
  console.log(JSON.stringify(req.headers))
  const filePath = path.join(__dirname, 'assets', 'flutter_logo.png');
  const stat = fs.statSync(filePath);
  const file = fs.readFileSync(filePath, 'binary');
  res.setHeader('Content-Length', stat.size);
  res.setHeader('Content-Type', 'image/png');
  res.setHeader('Content-Disposition', 'attachment; filename=flutter_logo.png');
  res.write(file, 'binary');
  res.end();
})

app.listen(8082)
