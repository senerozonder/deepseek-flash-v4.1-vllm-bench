FROM vllm/vllm-openai:v0.33.0
LABEL org.opencontainers.image.source="https://github.com/senerozonder/deepseek-flash-v4.1-vllm-bench"
USER root
ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    MPLBACKEND=Agg \
    OMP_NUM_THREADS=1
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl git jq nano vim-tiny tmux htop rsync \
    openssh-server numactl pciutils procps iproute2 \
    && rm -f /etc/ssh/ssh_host_* \
    && rm -rf /var/lib/apt/lists/*
# Verify the base image's Python environment.
RUN python3 --version && \
    python3 -m pip --version && \
    python3 -c "from importlib.metadata import version; print(version('vllm'))" && \
    ln -sf "$(command -v python3)" /usr/local/bin/python

COPY requirements.txt /opt/benchmark/requirements.txt
# Keep every existing base-image Python distribution at its installed version.
RUN python -m pip list --format=freeze > /tmp/base-constraints.txt && \
    python -m pip install --no-cache-dir -c /tmp/base-constraints.txt -r /opt/benchmark/requirements.txt && \
    python -m pip check && \
    python -c "from importlib.metadata import version; assert version('vllm').split('+')[0] == '0.33.0', version('vllm')" && \
    python -m pip freeze > /opt/benchmark/requirements-frozen.txt && \
    rm /tmp/base-constraints.txt
COPY start.sh /usr/local/bin/benchmark-start.sh
RUN chmod 755 /usr/local/bin/benchmark-start.sh
WORKDIR /workspace
EXPOSE 22 8000
ENTRYPOINT ["/usr/local/bin/benchmark-start.sh"]
CMD []
