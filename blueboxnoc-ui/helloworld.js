// Load the http module to create an http server.
var http = require('http');
var tail = require('child_process').spawn("bash", ["-c", "while true; do echo Hello; sleep 1; done"]);


// Configure our HTTP server to respond with Hello World to all requests.
var server = http.createServer(function (request, response) {
    response.writeHead(200, {"Content-Type": "text/plain"});
    tail.stdout.on("data", function (data) {
        console.log("data");
        response.write(data);
    });
});

server.listen(80, "0.0.0.0");

// Put a friendly message on the terminal
console.log("Server running at http://0.0.0.0:80/");
