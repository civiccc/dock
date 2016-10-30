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

@test "returns the user ID of the user who ran Dock" {
  file .dock <<-EOF
image alpine:latest
echo "\$(user_id)" > user_id
EOF

  run dock echo
  [ "$status" -eq 0 ]
  [ "$(cat user_id)" = "$(id -u)" ]
}
