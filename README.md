# DeepSeek V4.1 Flash vLLM benchmark environment

Base: `vllm/vllm-openai:v0.33.0` (CUDA 13.0). Target: Linux x86-64, four H200 GPUs. Model weights are mounted separately at runtime. No model weights, private benchmark data or credentials belong in this public repository.

## Build and publish

Push these files to `main` in `senerozonder/deepseek-flash-v4.1-vllm-bench`. GitHub Actions builds and publishes to `ghcr.io/senerozonder/deepseek-flash-v4.1-vllm-bench:0.33.0` and a commit-specific tag. First publication may be private: change package visibility to public in GitHub Packages settings. The workflow uses the built-in GITHUB_TOKEN; no separate registry secret is needed.

Standard GitHub runners have limited disk. The workflow clears several preinstalled toolchains; if the build still runs out of space, use a larger or self-hosted runner with adequate disk, or build on a cheap staging machine. The build does not require a GPU.

## RunPod

Create a custom GPU Pod template using the published image. Select four H200 GPUs, a driver supporting CUDA 13.0, adequate host RAM and shared memory. Mount the existing Global Volume at its configured mount point. Enable direct SSH, expose TCP 22, add your SSH public key to RunPod and ensure PUBLIC_KEY reaches the container. Leave start command empty. Do not expose port 8000 publicly for local benchmarks. The entrypoint starts SSH only; the benchmark runner starts and stops vLLM.

After connecting:

```bash
nvidia-smi
nvidia-smi topo -m
free -h
df -h /dev/shm
python -c 'import torch, vllm; print(vllm.__version__, torch.version.cuda, torch.cuda.device_count())'
vllm serve --help=all | grep -i engram
```

Record `cat /opt/benchmark/requirements-frozen.txt`, the image digest and model revision for reproducibility. The base image's installed Python packages are constrained during installation to avoid changing the inference stack. New dependencies are resolved at build time; the frozen manifest and commit-specific image tag record the actual environment. No GPU smoke test is performed by GitHub Actions. Validate real model startup and tool calling separately before the benchmark sweep.
