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

@test "when -V flag specified it displays the Dock version" {
  run dock -V
  [ "$status" -eq 0 ]
  [[ "$output" =~ Dock:\ +[0-9]+\.[0-9]+\.[0-9]+ ]]
}

@test "when -V flag specified it displays the Docker version" {
  run dock -V
  [ "$status" -eq 0 ]
  [[ "$output" =~ Docker:\ +Docker\ version\ [0-9]+\.[0-9]+\.[0-9]+ ]]
}

@test "when -V flag specified it displays the Bash version" {
  run dock -V
  [ "$status" -eq 0 ]
  [[ "$output" =~ Bash:\ +"$BASH_VERSION" ]]
}

@test "when -V flag specified it displays the OS version" {
  run dock -V
  [ "$status" -eq 0 ]
  [[ "$output" =~ OS:\ +$(uname -a) ]]
}
