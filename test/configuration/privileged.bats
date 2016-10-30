#!/usr/bin/env bats

load ../utils

setup() {
  destroy_all_containers
  original_dir="$(pwd)"
  cd "$(create_repo my-project)"
}

teardown() {
  cd "${original_dir}"
}

@test "when privileged called without any arguments returns privilege status" {
  file .dock <<-EOF
image alpine:latest
if privileged; then
  touch is_privileged
fi
if ! privileged; then
  touch is_not_privileged
fi
EOF

  run dock echo
  [ "$status" -eq 0 ]
  [ ! -e is_privileged ]
  [ -e is_not_privileged ]
}

@test "when privileged not specified container is not given privileges" {
  file .dock <<-EOF
image alpine:latest
detach true
EOF

  dock nc -l -s 0.0.0.0 -p 5555
  run docker inspect --format {{.HostConfig.Privileged}} my-project-dock
  docker stop my-project-dock || true
  [ "$status" -eq 0 ]
  [ "$output" = false ]
}

@test "when privileged set to false container is not given privileges" {
  file .dock <<-EOF
image alpine:latest
detach true
privileged false
EOF

  dock nc -l -s 0.0.0.0 -p 5555
  run docker inspect --format {{.HostConfig.Privileged}} my-project-dock
  docker stop my-project-dock || true
  [ "$status" -eq 0 ]
  [ "$output" = false ]
}

@test "when privileged specified container is given extended privileges" {
  file .dock <<-EOF
image alpine:latest
detach true
privileged true
EOF

  dock nc -l -s 0.0.0.0 -p 5555
  run docker inspect --format {{.HostConfig.Privileged}} my-project-dock
  docker stop my-project-dock
  [ "$status" -eq 0 ]
  [ "$output" = true ]
}
