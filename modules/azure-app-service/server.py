import os
import http.server

port = int(os.environ.get("WEBSITES_PORT", "8080"))

# Serve static files from the directory this script lives in
os.chdir(os.path.dirname(os.path.abspath(__file__)))

http.server.HTTPServer(("", port), http.server.SimpleHTTPRequestHandler).serve_forever()
