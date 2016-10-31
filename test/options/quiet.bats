#!/usr/bin/env bats

load ../utils

setup() {
  destroy_all_containers
  original_dir="$(pwd)"
  cd "$(create_repo)"
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
