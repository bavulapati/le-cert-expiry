const { app } = require('electron')
const https = require('https');
const fs = require('fs');


/*
 *                                        root1-expired
 *                                          /
 *                                        /
 * root2-self-signed        root2-cross-signed
 *            \             /
 *              \          /
 *              Intermediate
 *                  |
 *                  |
 *                server
 *
 */
const serverOptions = {
  key: fs.readFileSync('./server.key.pem'),
  cert: fs.readFileSync('./server.cert.pem'),
  ca: [
    fs.readFileSync('./intermediate.cert.pem'),
    fs.readFileSync('./root2.cert.pem')
  ],
  enableTrace: true
};

const clientOptions = {
  enableTrace: true,
  ca: [ 
    fs.readFileSync('./root1.cert.pem'),
    fs.readFileSync('./root2selfsigned.cert.pem'),
  ]
};

app.whenReady().then(() => {

  const server = https.createServer(serverOptions, function (req, res) {
    res.writeHead(200);
    res.end("hello world\n");
  }).listen(0, () => {
    https.get(`https://localhost:${server.address().port}`, clientOptions, (res) => {
      console.log('statusCode:', res.statusCode);
      console.log('headers:', res.headers);

      res.on('data', (d) => {
        d && process.stdout.write(d);
      }).on('end', (d) => {
        d && process.stdout.write(d);
        server.close();
        app.quit();
      });
    }).on('error', (e) => {
      console.error(e);
      server.close();
      app.quit();
    });
  });
});
