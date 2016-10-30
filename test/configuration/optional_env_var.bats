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

@test "when optional_env_var is specified but not set on host it is ignored" {
  file .dock <<-EOF
image alpine:latest
optional_env_var MY_VAR
EOF

  run dock echo
  [ "$status" -eq 0 ]
}

@test "when optional_env_var is specified and set on host it is injected into the container" {
  file .dock <<-EOF
image alpine:latest
optional_env_var MY_VAR
EOF

  run env MY_VAR=foo dock printenv MY_VAR
  [ "$status" -eq 0 ]
  [[ "$output" =~ "foo" ]]
}

@test "when optional_env_var not given an argument returns an error" {
  file .dock <<-EOF
image alpine:latest
optional_env_var
EOF

  run dock echo
  [ "$status" -eq 1 ]
  [[ "$output" =~ "Must provide name of optional environment variable!" ]]
}
