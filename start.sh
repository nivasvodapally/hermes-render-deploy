#!/bin/bash
set -e
echo "=== Hermes Gateway Starting ==="

# Decode .env
if [ -n "$HERMES_ENV_B64" ]; then
    echo "$HERMES_ENV_B64" | base64 -d > /root/.hermes/.env
fi

# Health server
python3 -c "
import http.server, json
class H(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header('Content-Type','application/json')
        self.end_headers()
        self.wfile.write(json.dumps({'status':'ok'}).encode())
    def log_message(self,*a): pass
http.server.HTTPServer(('0.0.0.0',10000),H).serve_forever()
" &

cd /root
exec python3 -m hermes_cli.main gateway run 2>&1
