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

@test "when -h flag specified it displays help documentation" {
  run dock -h
  echo "$output"
  [ "$status" -eq 0 ]
  [[ "$output" =~ "dock is a tool" ]]
  [[ "$output" =~ "Usage: dock [options] [command]" ]]
}
