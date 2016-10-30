#!/bin/bash

# Entrypoint script that starts a Docker daemon inside the Dock container
# for us so that it is always available.

set -euo pipefail

start_docker() {
  # Don't do anything if daemon already running
  if docker info >/dev/null 2>&1; then
    return
  fi

  sudo dockerd >/dev/null 2>&1 &
  dockerd_pid=$!

  local max_tries=5
  for i in {1..5}; do
    if docker info >/dev/null 2>&1; then
      break
    fi
    echo "Waiting for Docker daemon to start ($i/5)..." >&2
    sleep 1
  done

  if ! docker info >/dev/null 2>&1; then
    echo "Docker daemon failed to start!" >&2
    return 1
  fi
}

start_docker
exec "$@"
