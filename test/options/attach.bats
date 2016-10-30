#!/usr/bin/env bats

load ../utils

project_name=my-project

setup() {
  destroy_all_containers
  original_dir="$(pwd)"
  cd "$(create_repo ${project_name})"
}

teardown() {
  cd "${original_dir}"
}

@test "attaching when container is already running" {
  docker run --detach --interactive --name "${project_name}-dock" alpine:latest \
    sleep 5
  run dock -a
  # 137 status means we were killed by the container exiting
  [ "$status" -eq 137 ]
}

@test "attaching when container exists but is not running" {
  docker run --name "${project_name}-dock" alpine:latest echo
  run dock -a
  [ "$status" -eq 1 ]
  [[ "${lines[0]}" =~ "Container ${project_name}-dock exists but is not running, so you can't attach" ]]
}

@test "attaching when no container exists" {
  run dock -a
  [ "$status" -eq 1 ]
  [[ "${lines[0]}" =~ "No container named ${project_name}-dock is currently running." ]]
  [[ "${lines[1]}" =~ "You must start the container first before you can attach!" ]]
}
