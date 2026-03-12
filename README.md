# IOPaint ROCm Docker (AMD GPU)

This repository provides a specialized Docker configuration for running [IOPaint](https://github.com/Sanster/IOPaint) with **AMD ROCm** support. It is optimized for setups using AMD Radeon GPUs (like the RX 6000 series) on Linux hosts, including support for Proxmox LXC deployments.

## Features
- **ROCm 7.1.1 Support**: Uses the latest official `rocm/pytorch` base image.
- **Cross-Platform Build**: for Intel/AMD (x86_64) targets.
- **GPU Offloading**: Pre-configured to offload models to VRAM.
- **Automated Build**: Simple `Makefile` for building and exporting the image.

## Prerequisites
- **Host Machine**: Linux with AMD GPU drivers installed.
- **Build Machine**: Docker with `buildx` support (standard on Docker Desktop for Mac/Windows).
- **GPU Compatibility**: This setup includes `HSA_OVERRIDE_GFX_VERSION=10.3.0` for RX 6000 series (gfx1030) compatibility.

---

## Quick Start

### 1. Build and Export (On Build Machine)
Use provided `Makefile`. This will build the `linux/amd64` image and export it as a compressed tarball into the `out/` directory.

```bash
# Build and export to out/iopaint-rocm-1.6.0.tar.gz
make all
```

### 2. Transfer and Load (On Target Machine)
Transfer the `.tar.gz` file from the `out/` directory to your target machine and load it into Docker:

```bash
docker load -i /path/to/file/iopaint-rocm-1.6.0.tar.gz
```

### 3. Deploy via Portainer (On Target Machine)
Once the image is loaded, you can create a new Stack in Portainer with the following `docker-compose.yaml`:

```yaml
services:
  iopaint:
    image: iopaint-rocm:latest
    container_name: iopaint-rocm
    devices:
      - /dev/kfd:/dev/kfd
      - /dev/dri:/dev/dri
    environment:
      - HSA_OVERRIDE_GFX_VERSION=10.3.0
    ports:
      - "8080:8080"
    volumes:
      # Using absolute paths is recommended for Portainer Stacks
      - /opt/iopaint/models:/root/.cache
      - /opt/iopaint/outputs:/app/outputs
    restart: unless-stopped
    command: iopaint start --model=lama --device=cuda --port=8080 --host=0.0.0.0
```

> **Note**: Replace `/opt/iopaint/models` and `/opt/iopaint/outputs` with your actual directories.

---

## Available Make Targets
- `make build`: Build the amd64 image locally.
- `make export`: Export the built image to the `out/` directory.
- `make all`: Build and export in one step.
- `make clean`: Remove the `out/` directory and its contents.

## License
This project follows the licensing of [IOPaint](https://github.com/Sanster/IOPaint).
