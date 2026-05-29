import http.server
import json
import subprocess
import urllib.request
import os

class HealthHandler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == "/health":
            try:
                r = subprocess.run(["pgrep", "-f", "hermes_cli.main gateway"], capture_output=True, timeout=5)
                ok = r.returncode == 0
            except:
                ok = False
            self.send_response(200 if ok else 503)
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            self.wfile.write(json.dumps({"status": "ok" if ok else "down"}).encode())

        elif self.path == "/test-api":
            # Test the LLM API from Render's network
            api_key = os.environ.get("OGW_API_KEY", "")
            base_url = "https://opengateway.gitlawb.com/v1"
            result = {"api_key_set": bool(api_key), "api_key_prefix": api_key[:10] + "..." if api_key else "NONE"}
            
            url = f"{base_url}/chat/completions"
            data = json.dumps({
                "model": "mimo-v2.5-pro",
                "messages": [{"role": "user", "content": "say ok"}],
                "max_tokens": 3
            }).encode()
            
            req = urllib.request.Request(url, data=data, headers={
                "Authorization": f"Bearer {api_key}",
                "Content-Type": "application/json"
            })
            
            try:
                with urllib.request.urlopen(req, timeout=30) as resp:
                    r = json.loads(resp.read())
                    result["api_status"] = "working"
                    result["response"] = r.get("choices", [{}])[0].get("message", {}).get("content", "")
            except urllib.error.HTTPError as e:
                result["api_status"] = f"error_{e.code}"
                result["error"] = e.read().decode()[:500]
            except Exception as e:
                result["api_status"] = "exception"
                result["error"] = str(e)
            
            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            self.wfile.write(json.dumps(result, indent=2).encode())
        else:
            self.send_response(200)
            self.send_header("Content-Type", "text/plain")
            self.end_headers()
            self.wfile.write(b"Hermes Bot")

    def log_message(self, *a): pass

if __name__ == "__main__":
    http.server.HTTPServer(("0.0.0.0", 10000), HealthHandler).serve_forever()
