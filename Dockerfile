FROM nousresearch/hermes-agent:latest

# Override the entrypoint to bypass s6-overlay
ENTRYPOINT []

# Copy our config
COPY config.yaml /opt/data/.hermes/config.yaml

# Copy start script
COPY start.sh /app/start.sh
RUN chmod +x /app/start.sh

ENV HOME=/opt/data
ENV HERMES_HOME=/opt/data/.hermes
ENV PYTHONUNBUFFERED=1

EXPOSE 10000

CMD ["/app/start.sh"]
