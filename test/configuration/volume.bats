#!/usr/bin/env bats

load ../utils

setup() {
  destroy-all-containers
  original_dir="$(pwd)"
  cd "$(create_repo)"
}

teardown() {
  cd "${original_dir}"
}

@test "when specification provided it mounts the volume" {
  echo "Some contents" > file_to_mount

  file .dock <<-EOF
image=alpine:latest
pull=false
volume "\$(repo_path)/file_to_mount:/etc/mounted_file"
EOF

  run dock cat /etc/mounted_file
  [ "$status" -eq 0 ]
  [[ "$output" =~ "Some contents" ]]
}

@test "when specification is not provided it fails with an error" {
  file .dock <<-EOF
image=alpine:latest
pull=false
volume # No argument given should result in error
EOF

  run dock echo
  [ "$status" -eq 1 ]
  [[ "$output" =~ "Must provide volume specification!" ]]
}
