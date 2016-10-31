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

@test "when quiet flag specified no output from Dock is emitted" {
  file .dock <<-EOF
image alpine:latest
EOF

  run dock -q echo -n Hello world
  [ "$status" -eq 0 ]
  [ "$output" = "Hello world" ]
}

@test "when quiet flag specified no output from Dockerfile build is emitted" {
  file Dockerfile <<-EOF
FROM alpine:latest
RUN touch /etc/something
EOF

  file .dock <<-EOF
dockerfile Dockerfile
EOF

  run dock -q echo -n Hello world
  echo "$output"
  [ "$status" -eq 0 ]
  [ "$output" = "Hello world" ]
}
