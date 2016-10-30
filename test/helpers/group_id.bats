#!/usr/local/bin/dock bats

load ../utils

project_name=my-project

setup() {
  destroy_all_containers
  original_dir="$(pwd)"
  cd "$(create_repo ${project_name})"

  file .dock <<-EOF
image=alpine:latest
pull=false
echo "\$(group_id)" > group_id
command=echo
EOF
}

teardown() {
  cd "${original_dir}"
}

@test "returns the group ID of the user who ran Dock" {
  run dock
  [ "$status" -eq 0 ]
  [ "$(cat group_id)" = "$(id -g)" ]
}
