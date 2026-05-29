#!/bin/bash
echo "=== Hermes Bot Starting ==="

# Decode .env
if [ -n "$HERMES_ENV_B64" ]; then
    echo "$HERMES_ENV_B64" | base64 -d > /root/.hermes/.env
    echo "Decoded .env"
    # Show which keys are set (not values)
    grep -v "^#\|^$" /root/.hermes/.env | cut -d= -f1 | head -20
fi

# Verify critical env vars
echo "TELEGRAM_BOT_TOKEN: ${TELEGRAM_BOT_TOKEN:+SET}"
echo "GATEWAY_ALLOW_ALL_USERS: ${GATEWAY_ALLOW_ALL_USERS:+SET}"

# Start health server
python3 /app/health.py &
echo "Health server on port 10000"

sleep 2

# Start gateway with verbose logging
echo "Starting Hermes Gateway..."
cd /root
exec python3 -m hermes_cli.main gateway run 2>&1
