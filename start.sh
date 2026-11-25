#!/usr/bin/env bash
set -euo pipefail
# Start an interactive benchmark pod, not an inference server.
mkdir -p /run/sshd
install -d -m 700 /root/.ssh
if [[ -n "${PUBLIC_KEY:-}" ]]; then
    printf '%s\n' "$PUBLIC_KEY" > /root/.ssh/authorized_keys
    chmod 600 /root/.ssh/authorized_keys
fi
ssh-keygen -A
/usr/sbin/sshd -t
if [[ "$#" -gt 0 ]]; then
    /usr/sbin/sshd -o PasswordAuthentication=no -o KbdInteractiveAuthentication=no -o PermitRootLogin=prohibit-password
    exec "$@"
fi
echo 'Benchmark container ready. Start vLLM manually or via the benchmark runner.'
exec /usr/sbin/sshd -D -e -o PasswordAuthentication=no -o KbdInteractiveAuthentication=no -o PermitRootLogin=prohibit-password
