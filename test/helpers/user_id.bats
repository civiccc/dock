#!/usr/local/bin/dock bats

load ../utils

project_name=my-project

setup() {
  destroy-all-containers
  original_dir="$(pwd)"
  cd "$(create_repo ${project_name})"

  file .dock <<-EOF
image=alpine:latest
pull=false
echo "\$(user_id)" > user_id
command=echo
EOF
}

teardown() {
  cd "${original_dir}"
}

@test "returns the user ID of the user who ran Dock" {
  run dock
  [ "$status" -eq 0 ]
  [ "$(cat user_id)" = "$(id -u)" ]
}
