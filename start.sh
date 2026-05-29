#!/bin/bash
echo "=== Hermes Bot Debug Start ==="
echo "HOME=$HOME"
echo "HERMES_HOME=$HERMES_HOME"
echo "PATH=$PATH"

# Decode .env
if [ -n "$HERMES_ENV_B64" ]; then
    echo "$HERMES_ENV_B64" | base64 -d > /root/.hermes/.env
    echo "Decoded .env to /root/.hermes/.env"
fi

# Show config file
echo "=== CONFIG.YAML ==="
cat /root/.hermes/config.yaml
echo "=== END CONFIG ==="

# Show .env (keys only, no values)
echo "=== .ENV KEYS ==="
grep -v "^#\|^$" /root/.hermes/.env 2>/dev/null | cut -d= -f1
echo "=== END .ENV ==="

# Show which hermes
which python3
python3 -c "import hermes_cli; print(hermes_cli.__file__)"

# Start health server
python3 /app/health.py &
sleep 1

# Start gateway
echo "=== STARTING GATEWAY ==="
cd /root
exec python3 -m hermes_cli.main gateway run 2>&1
