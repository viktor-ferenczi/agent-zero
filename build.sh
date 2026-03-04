#!/bin/bash
set -euo pipefail

REGISTRY="192.168.1.40:5000"
IMAGE="agent-zero"

# Ensure the local registry is configured as insecure.
# Add to /etc/docker/daemon.json if not already present:
#   { "insecure-registries": ["192.168.1.40:5000"] }
# Then restart Docker: sudo systemctl restart docker

echo "Building ${IMAGE}..."
docker build -f DockerfileLocal -t "${IMAGE}:latest" .

echo "Tagging for ${REGISTRY}..."
docker tag "${IMAGE}:latest" "${REGISTRY}/${IMAGE}:latest"

echo "Pushing to ${REGISTRY}..."
docker push "${REGISTRY}/${IMAGE}:latest"

echo "Done: ${REGISTRY}/${IMAGE}:latest"
