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

@test "when build_context not specified it uses repo root for build context" {
  file Dockerfile <<-EOF
FROM alpine:latest
COPY my-file /etc/my-file
EOF

  file my-file <<-EOF
Hello
EOF

  file .dock <<-EOF
  dockerfile Dockerfile
EOF

  run dock cat /etc/my-file
  [ "$status" -eq 0 ]
  [[ "$output" =~ "Hello" ]]
}

@test "when build_context specified it uses that path relative to repo root for build context" {
  mkdir -p context

  file context/Dockerfile <<-EOF
FROM alpine:latest
COPY my-file /etc/my-file
EOF


  file context/my-file <<-EOF
Hello
EOF

  file .dock <<-EOF
  build_context context
  dockerfile context/Dockerfile
EOF

  run dock cat /etc/my-file
  [ "$status" -eq 0 ]
  [[ "$output" =~ "Hello" ]]
}
