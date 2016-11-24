#!/usr/bin/env bats

load ../utils

setup() {
  destroy_all_containers
  original_dir="$(pwd)"
  cd "$(create_repo my-project)"
}

teardown() {
  cd "${original_dir}"
}

@test "when DOCK_FORCE_DESTROY environment variable specified it destroys already-running container" {
  file .dock <<-EOF
image alpine:latest
EOF

  dock -d nc -l -s 0.0.0.0 -p 5555
  run env DOCK_FORCE_DESTROY=1 dock echo
  [ "$status" -eq 0 ]
  [[ "$output" =~ "Destroying container" ]]
}

@test "when DOCK_FORCE_DESTROY environment variable not specified and container already running it fails" {
  file .dock <<-EOF
image alpine:latest
EOF

  dock -d nc -l -s 0.0.0.0 -p 5555
  run bash -c "echo | dock echo"
  [ "$status" -eq 1 ]
  [[ "$output" =~ "already running" ]]
}
