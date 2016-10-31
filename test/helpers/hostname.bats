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

@test "returns the hostname of the container" {
  file .dock <<-EOF
image alpine:latest
echo "\$(hostname)" > hostname
EOF

  run dock echo
  [ "$status" -eq 0 ]
  [ "$(cat hostname)" = my-project-dock ]
}

@test "returns the hostname defined by hostname option" {
  file .dock <<-EOF
image alpine:latest
hostname my-custom-name
echo "\$(hostname)" > hostname
EOF

  run dock echo
  [ "$status" -eq 0 ]
  [ "$(cat hostname)" = my-custom-name ]
}
