#!/usr/bin/env bats

load ../utils

setup() {
  destroy_all_containers
  original_dir="$(pwd)"
  cd "$(create_repo)"
}

teardown() {
  cd "${original_dir}"
}

@test "mounts project at path specified by workspace_path" {
  file .dock <<-EOF
image=alpine:latest
pull=false
workspace_path /custom-workspace
EOF

  run dock pwd
  [ "$status" -eq 0 ]
  [[ "$output" =~ "/custom-workspace" ]]
}
