#!/bin/bash
cd /root

# Health + logs server (reads from hermes log file AND stdout)
python3 -c "
import http.server, json, subprocess, os, glob
class H(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/logs':
            logs = ''
            # Try hermes log files
            for pattern in ['/root/.hermes/logs/*.log', '/tmp/*.log']:
                for f in glob.glob(pattern):
                    try:
                        with open(f) as fh:
                            logs += f'=== {f} ===\n' + fh.read()[-5000:] + '\n'
                    except: pass
            if not logs:
                logs = 'No log files found'
            self.send_response(200)
            self.send_header('Content-Type','text/plain')
            self.end_headers()
            self.wfile.write(logs.encode())
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

# Create log directory
mkdir -p /root/.hermes/logs

exec python3 -m hermes_cli.main gateway run
