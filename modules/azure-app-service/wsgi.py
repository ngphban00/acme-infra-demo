import os
import base64

_html = base64.b64decode(os.environ["INDEX_HTML_B64"]).decode()

def application(environ, start_response):
    start_response("200 OK", [("Content-Type", "text/html; charset=utf-8")])
    return [_html.encode()]
