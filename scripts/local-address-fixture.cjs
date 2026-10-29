const http = require('node:http');

http.createServer((request, response) => {
  const match = /^\/api\/cep\/v2\/(\d{8})$/.exec(request.url);
  response.setHeader('content-type', 'application/json');
  if (!match) {
    response.writeHead(404);
    response.end(JSON.stringify({ error: 'Not found' }));
    return;
  }
  response.end(JSON.stringify({
    cep: match[1], state: 'GO', city: 'Goiania',
    neighborhood: 'Downtown', street: 'Development Street',
    location: { coordinates: { latitude: '-16.6869', longitude: '-49.2648' } },
  }));
}).listen(8080, '0.0.0.0');
