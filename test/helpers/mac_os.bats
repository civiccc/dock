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

# This will always return false since we're running inside the Dock container,
# which is based on CentOS. Far from perfect but "good enough"
@test "returns whether the OS is macOS" {
  file .dock <<-EOF
image=alpine:latest
pull=false

if mac_os; then
  touch is_mac_os
fi
if ! mac_os; then
  touch is_not_mac_os
fi

command=echo
EOF

  run dock
  [ "$status" -eq 0 ]
  [ -e is_not_mac_os ]
  [ ! -e is_mac_os ]
}
