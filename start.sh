#!/bin/bash
cd /root

# Health server in background (required by Render)
python3 -c "
import http.server, json, threading, subprocess
class H(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
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

# Main gateway - runs as PID 1
exec python3 -m hermes_cli.main gateway run
