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

@test "when build_arg specified it injects the build arg to the docker build command" {
  file Dockerfile <<-EOF
FROM alpine:latest
ARG MY_VAR
ENV MY_VAR \${MY_VAR}
RUN echo -n \$MY_VAR > /etc/result
EOF

  file .dock <<-EOF
dockerfile Dockerfile
build_arg MY_VAR "some value"
EOF

  run dock -q cat /etc/result
  [ "$status" -eq 0 ]
  [ "$output" = "some value" ]
}

@test "when build_arg specified without any arguments it returns error" {
  file .dock <<-EOF
image alpine:latest
build_arg
EOF

  run dock echo
  [ "$status" -eq 1 ]
  [[ "$output" =~ "Must provide name and value for build argument!" ]]
}

@test "when build_arg specified name but not value it returns error" {
  file .dock <<-EOF
image alpine:latest
build_arg MY_VAR
EOF

  run dock echo
  [ "$status" -eq 1 ]
  [[ "$output" =~ "Must provide value for build argument MY_VAR!" ]]
}
