#!/bin/bash
echo "=== Hermes Bot Starting ==="

# Set up environment
export HOME=/opt/data
export HERMES_HOME=/opt/data/.hermes
export PATH="/opt/hermes/.venv/bin:${PATH}"

# Decode .env
if [ -n "$HERMES_ENV_B64" ]; then
    echo "$HERMES_ENV_B64" | base64 -d > /opt/data/.hermes/.env
    echo "Decoded .env"
fi

# Show config for debugging
echo "=== CONFIG ==="
cat /opt/data/.hermes/config.yaml
echo "=== .ENV KEYS ==="
grep -v "^#\|^$" /opt/data/.hermes/.env 2>/dev/null | cut -d= -f1

# Start health server
python3 -c "
import http.server, json, subprocess
class H(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header('Content-Type','application/json')
        self.end_headers()
        self.wfile.write(json.dumps({'status':'ok'}).encode())
    def log_message(self,*a): pass
http.server.HTTPServer(('0.0.0.0',10000),H).serve_forever()
" &
echo "Health server started"

sleep 2

# Start gateway
echo "=== STARTING GATEWAY ==="
cd /opt/data
exec python3 -m hermes_cli.main gateway run 2>&1
