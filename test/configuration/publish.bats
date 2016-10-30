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

@test "when publish specified without any arguments it returns error" {
  file .dock <<-EOF
image alpine:latest
publish
EOF

  run dock echo
  [ "$status" -eq 1 ]
  [[ "$output" =~ "Must provide port publish specification as argument!" ]]
}

@test "when publish specified it publishes the port according to the spec" {
  file .dock <<-EOF
image alpine:latest
detach true
publish 5555:5555
EOF

  dock nc -l -s 0.0.0.0 -p 5555
  run bash -c "echo | nc 127.0.0.1 5555"
  [ "$status" -eq 0 ]
}

@test "when publish specified and port already bound on host it emits a warning" {
  file .dock <<-EOF
image alpine:latest
detach true
publish 5555:5555
EOF

  nc -l 127.0.0.1 5555 &
  nc_pid=$!
  run dock nc -l -s 0.0.0.0 -p 5555 -e echo Hello world
  kill $nc_pid || true
  [ "$status" -eq 0 ]
  [[ "$output" =~ "Ignoring port specification 5555:5555 since another process has already bound to localhost:$host_port" ]]
}
