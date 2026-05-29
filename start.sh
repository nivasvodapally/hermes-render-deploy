#!/bin/bash
echo "=== Hermes Bot Starting (Official Image) ==="

# Decode .env from Render env var
if [ -n "$HERMES_ENV_B64" ]; then
    echo "$HERMES_ENV_B64" | base64 -d > /opt/data/.hermes/.env
    echo "Decoded .env"
fi

# Debug: show config
echo "=== CONFIG ==="
cat /opt/data/.hermes/config.yaml
echo "=== END CONFIG ==="

# Debug: show .env keys
echo "=== .ENV KEYS ==="
grep -v "^#\|^$" /opt/data/.hermes/.env 2>/dev/null | cut -d= -f1
echo "=== END KEYS ==="

# Start health server
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

sleep 2
echo "Starting gateway..."
exec python3 -m hermes_cli.main gateway run 2>&1
