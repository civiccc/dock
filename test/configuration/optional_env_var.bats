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

@test "when optional environment variable not set it ignores it" {
  file .dock <<-EOF
image=alpine:latest
pull=false
optional_env_var MY_VAR
EOF

  run dock echo
  [ "$status" -eq 0 ]
}

@test "when optional environment variable is set it is injected into the container" {
  file .dock <<-EOF
image=alpine:latest
pull=false
optional_env_var MY_VAR
EOF

  run env MY_VAR=foo dock printenv MY_VAR
  [ "$status" -eq 0 ]
  [[ "$output" =~ "foo" ]]
}

@test "when not given an argument is returns an error" {
  file .dock <<-EOF
image=alpine:latest
pull=false
optional_env_var
EOF

  run dock echo
  [ "$status" -eq 1 ]
  [[ "$output" =~ "Must provide name of optional environment variable!" ]]
}
