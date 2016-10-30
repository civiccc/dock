#!/usr/local/bin/dock bats

load ../utils

project_name=my-project

setup() {
  destroy_all_containers
  original_dir="$(pwd)"
  cd "$(create_repo ${project_name})"
  echo "image=alpine:latest" >> .dock
  echo "command='exit 1'" >> .dock
}

teardown() {
  cd "${original_dir}"
}

@test "specifying an explicit config file" {
  echo "image=alpine:latest" >> .other-dock
  echo "command=echo" >> .other-dock
  run dock -d -c .other-dock sh
  [ "$status" -eq 0 ]
}
