#!/usr/bin/env bats

load ../utils

project_name=my-project

setup() {
  destroy_all_containers
  original_dir="$(pwd)"
  cd "$(create_repo ${project_name})"
}

teardown() {
  cd "${original_dir}"
}

@test "specifying an explicit config file" {
  file .dock <<-EOF
image alpine:latest
default_command exit 1
EOF

  file .other-dock <<-EOF
image alpine:latest
default_command echo Hello
EOF

  run dock -c .other-dock
  [ "$status" -eq 0 ]
  [[ "$output" =~ "Hello" ]]
}

@test "specifying a non-existent config file" {
  run dock -c .other-dock echo
  [ "$status" -eq 1 ]
  [[ "$output" =~ "Dock configuration file '.other-dock' does not exist!" ]]
}
