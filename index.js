const http = require("http");
const {
  Elm: { Server }
} = require("./elm.js");

const app = Server.init();

app.ports.response.subscribe(([{ req, res }, status, response]) => {
  res.statusCode = status;
  res.end(response);
});

http
  .createServer((req, res) => {
    app.ports.onRequest.send({ req, res });
  })
  .listen(3000);
