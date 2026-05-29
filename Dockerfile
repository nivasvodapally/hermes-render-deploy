FROM nousresearch/hermes-agent:latest

# Config is already at /opt/data/.hermes/config.yaml (HERMES_HOME=/opt/data)
# Write our config
COPY config.yaml /opt/data/.hermes/config.yaml

# The .env will be decoded from HERMES_ENV_B64 at runtime
COPY start.sh /app/start.sh
RUN chmod +x /app/start.sh

CMD ["/app/start.sh"]
