#!/bin/bash
cd /root

# Capture logs to a file
exec > >(tee /tmp/gateway.log) 2>&1

# Health + logs server
python3 -c "
import http.server, json, subprocess, os
class H(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/logs':
            try:
                with open('/tmp/gateway.log') as f:
                    lines = f.readlines()[-100:]
                self.send_response(200)
                self.send_header('Content-Type','text/plain')
                self.end_headers()
                self.wfile.write(''.join(lines).encode())
            except:
                self.send_response(404)
                self.end_headers()
        else:
            try:
                r = subprocess.run(['pgrep','-f','hermes_cli.main'], capture_output=True, timeout=5)
                ok = r.returncode == 0
            except: ok = False
            self.send_response(200 if ok else 503)
            self.send_header('Content-Type','application/json')
            self.end_headers()
            self.wfile.write(json.dumps({'status':'ok' if ok else 'down'}).encode())
    def log_message(self,*a): pass
http.server.HTTPServer(('0.0.0.0',10000),H).serve_forever()
" &

echo "=== Starting Hermes Gateway ==="
exec python3 -m hermes_cli.main gateway run
