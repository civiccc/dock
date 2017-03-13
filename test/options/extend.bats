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

@test "extending a Dock container with no docker-compose file at project root" { 
  run dock -e test
  
  [ "$status" -eq 1 ]
  [[ "$output" =~ "does NOT exist!" ]]
}

@test "extending a Dock container with an invalid docker-compose schema" {
  file docker-compose.yml <<-EOF
version: 2 # version should be a string, not a numeral
EOF

  run dock -e test
  
  [ "$status" -eq 1 ]
  [[ "$output" =~ "Invalid docker-compose schema detected!" ]]
}

@test "extending a non-existent Dock container successfully" {
  file Dockerfile <<-EOF
FROM alpine:latest
EOF

  file .dock <<-EOF
dockerfile Dockerfile
default_command sleep 1
EOF

  file docker-compose.yml <<-EOF
version: '2'
EOF
  
  run dock -e test

  [ "$status" -eq 0 ]
  # verify image for Dock env has been created
  docker images --format '{{.Repository}}:{{.Tag}}'| grep dock-image:test
  # ensure Dock env container is left running 
  container_running test
}

@test "configuration labels are added to Dock container during extension" {
  file Dockerfile <<-EOF
FROM alpine:latest
EOF

  file .dock <<-EOF
dockerfile Dockerfile
default_command sleep 1
EOF

  file docker-compose.yml <<-EOF
version: '2'
EOF

  run dock -e test

  [ "$status" -eq 0 ]
  # verify labels have been set correctly
  labels="$(get_labels test)"
  echo "$labels" | grep compose.my-project
  echo "$labels" | grep dock.my-project
}

@test "workspace dir is set as repo root of project during extension" {
  file Dockerfile <<-EOF
FROM alpine:latest
EOF

  file .dock <<-EOF
dockerfile Dockerfile
default_command sleep 1
workspace_path /custom-workspace # .dock setting should be overridden
EOF

  file docker-compose.yml <<-EOF
version: '2'
EOF

  run dock -e test

  [ "$status" -eq 0 ]
  [[ "$(dock exec test pwd)" =~ "$(original_dir)" ]]
}
