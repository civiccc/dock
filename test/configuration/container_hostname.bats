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

@test "when container_hostname given no arguments and hostname not set it errors" {
  file .dock <<-EOF
image alpine:latest
if container_hostname; then
  touch hostname-successful
else
  touch hostname-failed
fi
EOF

  run dock echo
  echo "$output"
  [ -e hostname-failed ]
}

@test "when container_hostname given no arguments and hostname set it returns hostname" {
  file .dock <<-EOF
image alpine:latest
container_hostname my-hostname
echo "\$(container_hostname)" > hostname
EOF

  run dock echo
  [ "$status" -eq 0 ]
  [ "$(cat hostname)" = my-hostname ]
}

@test "when hostname given an argument it sets the hostname of the container" {
  file .dock <<-EOF
image alpine:latest
container_hostname my-custom-name
publish 5555:5555
EOF

  run dock -q sh -c 'echo -n "$(hostname)"'
  [ "$status" -eq 0 ]
  [ "$output" = "my-custom-name" ]
}
