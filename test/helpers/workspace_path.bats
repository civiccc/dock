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

@test "returns absolute path to the directory mounted in container" {
  file .dock <<-EOF
image=alpine:latest
pull=false
echo "\$(workspace_path)" > workspace_path
command=echo
EOF

  run dock
  [ "$status" -eq 0 ]
  [ "$(cat workspace_path)" = /workspace ]
}

@test "returns absolute path defined by workspace_path option" {
  file .dock <<-EOF
image=alpine:latest
pull=false
workspace_path /custom-workspace
echo "\$(workspace_path)" > workspace_path
command=echo
EOF

  run dock
  [ "$status" -eq 0 ]
  [ "$(cat workspace_path)" = /custom-workspace ]
}
