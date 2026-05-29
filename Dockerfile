FROM python:3.12-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl git ripgrep procps build-essential python3-dev libffi-dev && \
    rm -rf /var/lib/apt/lists/*

# Install Node.js 20
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && rm -rf /var/lib/apt/lists/*

# Install uv via pip
RUN pip install --no-cache-dir uv

WORKDIR /app

# Clone hermes-agent (shallow for speed)
RUN git clone --depth 1 https://github.com/NousResearch/hermes-agent.git /app/hermes-agent
WORKDIR /app/hermes-agent

# Install Python dependencies
RUN uv sync --no-install-project --extra messaging
RUN uv pip install --no-cache-dir --no-deps -e .

# Setup hermes home
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
