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

@test "when env_var specified without any arguments it returns error" {
  file .dock <<-EOF
image alpine:latest
env_var
EOF

  run dock echo
  [ "$status" -eq 1 ]
  [[ "$output" =~ "Must provide name and value for environment variable!" ]]
}

@test "when env_var specified name but not value it returns error" {
  file .dock <<-EOF
image alpine:latest
env_var MY_VAR
EOF

  run dock echo
  [ "$status" -eq 1 ]
  [[ "$output" =~ "Must provide value for environment variable MY_VAR!" ]]
}

@test "when env_var specified it is injected into container" {
  file .dock <<-EOF
image alpine:latest
env_var MY_VAR "some value with spaces"
EOF

  run env dock printenv MY_VAR
  [ "$status" -eq 0 ]
  [[ "$output" =~ "some value with spaces" ]]
}
