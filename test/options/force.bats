#!/usr/local/bin/dock bats

load ../utils

project_name=my-project

setup() {
  destroy_all_containers
  original_dir="$(pwd)"
  cd "$(create_repo ${project_name})"
  echo "image=alpine:latest" > .dock
}

teardown() {
  cd "${original_dir}"
}

@test "forcibly removing existing Dock container" {
  container_id="$(dock -d sh)"
  run dock -f echo
  [ "$status" -eq 0 ]
  ! container_running "$container_id"
}
