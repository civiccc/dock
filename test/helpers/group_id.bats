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

@test "returns the group ID of the user who ran Dock" {
  file .dock <<-EOF
image alpine:latest
echo "\$(group_id)" > group_id
EOF

  run dock echo
  [ "$status" -eq 0 ]
  [ "$(cat group_id)" = "$(id -g)" ]
}
