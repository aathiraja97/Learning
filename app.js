// app.js
const http = require('http');

const PORT = process.env.PORT || 8080;
const VERSION = process.env.VERSION || 'v1';

const server = http.createServer((req, res) => {
  res.writeHead(200, {'Content-Type': 'text/plain'});
  res.end(`Hello from GKE! Version: ${VERSION}\n`);
});

server.listen(PORT, () => {
  console.log(`Listening on ${PORT}, version=${VERSION}`);
});