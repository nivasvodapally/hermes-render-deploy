#!/bin/bash
set -e
echo "=== Hermes Bot Starting ==="

# If base64-encoded .env is provided, decode it (preferred - contains all secrets)
if [ -n "$HERMES_ENV_B64" ]; then
    echo "$HERMES_ENV_B64" | base64 -d > /root/.hermes/.env
    echo "Decoded .env from HERMES_ENV_B64"
else
    # Fallback: write individual env vars
    {
        echo "TELEGRAM_BOT_TOKEN=$TELEGRAM_BOT_TOKEN"
        echo "GATEWAY_ALLOW_ALL_USERS=true"
    } > /root/.hermes/.env
    echo "Wrote individual env vars to .env"
fi

# If base64-encoded config.yaml is provided, decode it
if [ -n "$HERMES_CONFIG_B64" ]; then
    echo "$HERMES_CONFIG_B64" | base64 -d > /root/.hermes/config.yaml
    echo "Decoded config from HERMES_CONFIG_B64"
fi

echo "Config ready!"

# Start health server in background (keeps Render alive)
python3 /app/health.py &
echo "Health server on port 10000"

sleep 2

# Start hermes gateway
echo "Starting Hermes Gateway..."
cd /root
exec python3 -m hermes_cli.main gateway run
