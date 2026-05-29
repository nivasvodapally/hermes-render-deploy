import http.server, json, subprocess, threading

class H(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        try:
            r = subprocess.run(["pgrep", "-f", "hermes_cli.main gateway"], capture_output=True, timeout=5)
            ok = r.returncode == 0
        except: ok = False
        self.send_response(200 if ok else 503)
        self.send_header("Content-Type", "application/json")
        self.end_headers()
        self.wfile.write(json.dumps({"status": "ok" if ok else "down"}).encode())
    def log_message(self, *a): pass

if __name__ == "__main__":
    http.server.HTTPServer(("0.0.0.0", 10000), H).serve_forever()
