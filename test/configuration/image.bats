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

@test "when image not specified it returns an error" {
  file .dock <<-EOF
# An otherwise empty configuration
EOF

  run dock echo
  [ "$status" -eq 1 ]
  [[ "$output" =~ "Must specify either an image to run or a Dockerfile to build and run!" ]]
}

@test "when image specified it starts container using the image" {
  file .dock <<-EOF
image "alpine:latest"
EOF

  run dock cat /etc/os-release
  [ "$status" -eq 0 ]
  [[ "$output" =~ "Alpine" ]]
}

@test "when image and dockerfile specified it tags the built Dockerfile with image name" {
  file Dockerfile <<-EOF
FROM alpine:latest
RUN echo Hello > /etc/hello-world
EOF

  file .dock <<-EOF
dockerfile Dockerfile
image "my_image:latest"
EOF

  run dock cat /etc/hello-world
  [ "$status" -eq 0 ]
  [[ "$output" =~ "Hello" ]]

  dock -d nc -l -s 0.0.0.0 -p 5555
  run docker inspect --format {{.Config.Image}} my-project-dock
  docker stop my-project-dock || true
  [ "$status" -eq 0 ]
  [[ "$output" =~ "my-project:dock" ]]
}
