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

# This will always return true since we're running inside the Dock container,
# which is based on CentOS. Far from perfect but "good enough"
@test "returns true if the OS is Linux" {
  file .dock <<-EOF
image=alpine:latest
pull=false

if linux; then
  touch is_linux
fi
if ! linux; then
  touch is_not_linux
fi

command=echo
EOF

  run dock
  [ "$status" -eq 0 ]
  [ -e is_linux ]
  [ ! -e is_not_linux ]
}
