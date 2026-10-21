
var os = require("os");
var http = require("http");
var fs = require("fs");

var hostname = os.hostname();

http.createServer(function (req, res) {
  res.writeHead(200, {
    "Content-Type": "text/html; charset=utf-8"
  });

  var html = fs.readFileSync("index.html", "utf8");

  html = html
    .replaceAll("{{HOSTNAME}}", hostname)
    .replace("{{OS_TYPE}}", os.type())
    .replace("{{OS_PLATFORM}}", os.platform())
    .replace("{{OS_ARCH}}", os.arch())
    .replace("{{OS_RELEASE}}", os.release())
    .replace("{{CPU_COUNT}}", os.cpus().length)
    .replace("{{TOTAL_MEMORY}}", (os.totalmem() / 1024 / 1024).toFixed(0))
    .replace("{{FREE_MEMORY}}", (os.freemem() / 1024 / 1024).toFixed(0));

  res.end(html);
}).listen(3000, "0.0.0.0", function () {
  console.log("Server running on port 3000");
  console.log("Hello from " + hostname);
});
