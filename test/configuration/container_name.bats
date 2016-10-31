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

@test "when container_name given no arguments it returns the name of the container" {
  file .dock <<-EOF
image alpine:latest
echo "\$(container_name)" > container_name
EOF

  run dock echo
  [ "$status" -eq 0 ]
  [ "$(cat container_name)" = my-project-dock ]
}

@test "when container_name given an argument it sets the name of the container" {
  file .dock <<-EOF
image alpine:latest
container_name my-custom-name
publish 5555:5555
EOF

  run dock echo
  [ "$status" -eq 0 ]

  dock -d nc -l -s 0.0.0.0 -p 5555 # Waits until connection opened to netcat
  [ "$(docker ps --quiet --filter name=my-custom-name | wc -l)" -eq 1 ]
  echo | nc 127.0.0.1 5555 # Stop the container by opening connection
}
