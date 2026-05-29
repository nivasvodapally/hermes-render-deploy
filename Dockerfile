FROM python:3.12-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl git ripgrep procps build-essential python3-dev libffi-dev && \
    rm -rf /var/lib/apt/lists/*

# Install Node.js LTS
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - && \
    apt-get install -y nodejs && rm -rf /var/lib/apt/lists/*

# Install uv
COPY --from=ghcr.io/astral-sh/uv:0.11.6 /usr/local/bin/uv /usr/local/bin/

WORKDIR /app

# Clone hermes-agent
RUN git clone --depth 1 https://github.com/NousResearch/hermes-agent.git /app/hermes-agent
WORKDIR /app/hermes-agent
RUN uv sync --frozen --no-install-project --extra messaging 2>&1 | tail -3
RUN uv pip install --no-cache-dir --no-deps -e .

# Create hermes home
RUN mkdir -p /root/.hermes

# Copy deployment files
COPY start.sh /app/start.sh
COPY health.py /app/health.py
COPY config.yaml /root/.hermes/config.yaml
RUN chmod +x /app/start.sh

ENV HOME=/root
ENV HERMES_HOME=/root/.hermes
ENV PATH="/app/hermes-agent/.venv/bin:${PATH}"
ENV PYTHONUNBUFFERED=1

EXPOSE 10000

CMD ["/app/start.sh"]
