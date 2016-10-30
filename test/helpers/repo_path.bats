#!/usr/bin/env bats

load ../utils

setup() {
  destroy_all_containers
  original_dir="$(pwd)"
  actual_repo_path="$(create_repo)"
  cd "${actual_repo_path}"
}

teardown() {
  cd "${original_dir}"
}

@test "returns absolute path to the repo" {
  file .dock <<-EOF
image alpine:latest
echo "\$(repo_path)" > repo_path
EOF

  run dock echo
  [ "$status" -eq 0 ]
  [ "$(cat repo_path)" = "${actual_repo_path}" ]
}
