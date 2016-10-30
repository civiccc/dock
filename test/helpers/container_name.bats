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

@test "returns the name of the container" {
  file .dock <<-EOF
image=alpine:latest
pull=false
echo "\$(container_name)" > container_name
command=echo
EOF

  run dock
  [ "$status" -eq 0 ]
  [ "$(cat container_name)" = my-project-dock ]
}

@test "returns the name defined by container_name option" {
  file .dock <<-EOF
image=alpine:latest
pull=false
container_name my-custom-name
echo "\$(container_name)" > container_name
command=echo
EOF

  run dock
  [ "$status" -eq 0 ]
  [ "$(cat container_name)" = my-custom-name ]
}
