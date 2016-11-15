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
container_hostname my-hostname
echo "\$(container_hostname)" > hostname
EOF

  run dock echo
  [ "$status" -eq 0 ]
  [ "$(cat hostname)" = my-hostname ]
}

@test "returns the hostname defined by container_hostname option" {
  file .dock <<-EOF
image alpine:latest
container_hostname my-custom-name
echo "\$(container_hostname)" > hostname
EOF

  run dock echo
  [ "$status" -eq 0 ]
  [ "$(cat hostname)" = my-custom-name ]
}
