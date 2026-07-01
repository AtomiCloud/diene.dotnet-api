#!/usr/bin/env bash
set -euo pipefail

# CI entry point: validate the base sample's Docker build context (build-prep / smoke).
# This only proves the image builds from infra/Dockerfile; downstream deployment packaging
# (push, helm, garden) belongs to the API template, not this base.

IMAGE="${CI_DOCKER_IMAGE:-diene-dotnet-base}:prep"

echo "🐳 Validating Docker build context (${IMAGE})..."
docker build -f infra/Dockerfile -t "${IMAGE}" .

echo "✅ Docker build-prep smoke passed"
