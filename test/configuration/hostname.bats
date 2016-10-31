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

@test "when hostname given no arguments it returns the hostname of the container" {
  file .dock <<-EOF
image alpine:latest
echo "\$(hostname)" > hostname
EOF

  run dock echo
  [ "$status" -eq 0 ]
  [ "$(cat hostname)" = my-project-dock ]
}

@test "when hostname given an argument it sets the hostname of the container" {
  file .dock <<-EOF
image alpine:latest
hostname my-custom-name
publish 5555:5555
EOF

  run dock -q sh -c 'echo -n "$(hostname)"'
  echo "$output"
  [ "$status" -eq 0 ]
  [ "$output" = "my-custom-name" ]
}
