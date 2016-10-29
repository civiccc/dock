#!/usr/local/bin/dock bats

load ../utils

project_name=my-project

setup() {
  destroy-all-containers
  original_dir="$(pwd)"
  cd "$(create_repo ${project_name})"
  echo "image=alpine:latest" > .dock
}

teardown() {
  cd "${original_dir}"
}

@test "running Dock container as detached" {
  run dock -d sh
  [ "$status" -eq 0 ]
  container-running "${project_name}-dock"
}
