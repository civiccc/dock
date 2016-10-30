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

@test "when volume helper provided a specification it bind mounts" {
  echo "Some contents" > file_to_mount

  file .dock <<-EOF
image alpine:latest
volume "\$(repo_path)/file_to_mount:/etc/mounted_file"
EOF

  run dock cat /etc/mounted_file
  [ "$status" -eq 0 ]
  [[ "$output" =~ "Some contents" ]]
}

@test "when volume helper is not provided a specification it fails with an error" {
  file .dock <<-EOF
image alpine:latest
volume # No argument given should result in error
EOF

  run dock echo
  [ "$status" -eq 1 ]
  [[ "$output" =~ "Must provide volume specification!" ]]
}
