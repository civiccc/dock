#!/usr/bin/env bats

load ../utils

setup() {
  destroy-all-containers
  original_dir="$(pwd)"
  cd "$(create_repo my-project)"
}

teardown() {
  cd "${original_dir}"
}

@test "when dockerfile not specified it returns an error" {
  file .dock <<-EOF
# An otherwise empty configuration
EOF

  run dock echo
  [ "$status" -eq 1 ]
  [[ "$output" =~ "Must specify either an image to run or a Dockerfile to build and run!" ]]
}

@test "when dockerfile specified it builds and starts container with the image" {
  file Dockerfile <<-EOF
FROM alpine:latest
RUN echo Hello > /etc/hello-world
EOF

  file .dock <<-EOF
  dockerfile Dockerfile
EOF

  run dock echo /etc/hello-world
  [ "$status" -eq 0 ]
  [[ "$output" =~ "Hello" ]]
}
