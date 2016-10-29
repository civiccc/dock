#!/usr/bin/env bats

load ../utils

setup() {
  destroy-all-containers
  original_dir="$(pwd)"
  actual_repo_path="$(create_repo)"
  cd "${actual_repo_path}"
}

teardown() {
  cd "${original_dir}"
}

@test "returns absolute path to the repo" {
  file .dock <<-EOF
image=alpine:latest
pull=false
echo "\$(repo_path)" > repo_path
command=echo
EOF

  run dock
  [ "$status" -eq 0 ]
  [ "$(cat repo_path)" = "${actual_repo_path}" ]
}
