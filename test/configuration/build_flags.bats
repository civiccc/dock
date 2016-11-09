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

@test "when build_flags specified it adds those args to the docker build command" {
  file Dockerfile <<-EOF
FROM alpine:latest
ARG MY_VAR
ENV MY_VAR \${MY_VAR}
RUN echo -n \$MY_VAR > /etc/result
EOF

  file .dock <<-EOF
dockerfile Dockerfile
build_flags --build-arg MY_VAR=some-value
EOF

  run dock -q cat /etc/result
  [ "$status" -eq 0 ]
  [ "$output" = "some-value" ]
}

@test "when build_flags specified with no arguments it returns error" {
  file Dockerfile <<-EOF
FROM alpine:latest
EOF

  file .dock <<-EOF
dockerfile Dockerfile
build_flags
EOF

  run dock echo
  [ "$status" -eq 1 ]
  [[ "$output" =~ "Must provide one or more arguments for build_flags!" ]]
}
