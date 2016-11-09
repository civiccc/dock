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

@test "when run_flags specified it adds those args to the docker build command" {
  file .dock <<-EOF
image alpine:latest
run_flags --read-only
EOF

  run dock touch /etc/result
  [ "$status" -ne 0 ]
  [[ "$output" =~ "Read-only" ]]
}

@test "when run_flags specified with no arguments it returns error" {
  file .dock <<-EOF
image alpine:latest
run_flags
EOF

  run dock echo
  [ "$status" -eq 1 ]
  [[ "$output" =~ "Must provide one or more arguments for run_flags!" ]]
}
