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

@test "configuration labels are added to Dock container during extension" {
  file Dockerfile <<-EOF
FROM alpine:latest
EOF

  file .dock <<-EOF
dockerfile Dockerfile
default_command sh
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
default_command sh
workspace_path /custom-workspace # .dock setting should be overridden
EOF

  file docker-compose.yml <<-EOF
version: '2'
EOF

  run dock -e test

  [ "$status" -eq 0 ]
  [[ "$(dock exec test pwd)" =~ "$(original_dir)" ]]
}

@test "extending a project overrides previous Dock configuration labels for project" {
  file Dockerfile <<-EOF
FROM alpine:latest
EOF

  file .dock <<-EOF
dockerfile Dockerfile
default_command sh
EOF

  file docker-compose.yml <<-EOF
version: '2'
EOF

  docker run --name test -d --label compose.my-project=foo --label dock.my-project=bar \
    alpine:latest sh

  run dock -e test

  [ "$status" -eq 0 ]
  # ensure project configuration labels previously set are overriden appropriately 
  labels="$(get_labels test)"
  [ "$(echo "$labels" | grep -c foo)" -eq 0 ]
  [ "$(echo "$labels" | grep -c bar)" -eq 0 ]
  [ "$(echo "$labels" | grep -c ${repo_path}/docker-compose.yml)" -eq 1 ]
  [ "$(echo "$labels" | grep -c ${repo_path}/.dock)" -eq 1 ]
}

@test "extending a non-existent Dock container successfully" {
  file Dockerfile <<-EOF
FROM alpine:latest
EOF

  file .dock <<-EOF
dockerfile Dockerfile
default_command sh
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

@test "extending an existing Dock container successfully" {
  file Dockerfile <<-EOF
FROM alpine:latest
EOF

  echo "mytesting" > /tmp/myfile
  file .dock <<-EOF
dockerfile Dockerfile
volume "/tmp/myfile:/myprojectrepo/myfile"
publish 8888:8888
default_command sh
EOF

  file docker-compose.yml <<-EOF
version: '2'
EOF

  echo "atesting" > /tmp/afile
  docker run --name test -d --volume /tmp/afile:/aprojectrepo/afile --label compose.aproject=foo \
    --label dock.aproject=bar alpine:latest sh
  dock -e test

  run docker exec test cat /myprojectrepo/myfile

  [ "$status" -eq 0 ]
  # verify proper volume mounting of extension project and preservation of existing project mounts
  [[ "$output" =~ "mytesting" ]]
  [[ "$(docker exec test cat /aprojectrepo/afile)" =~ "atesting" ]]
  # verify extension project configuration labels are set accordingly
  labels="$(get_labels test)"
  echo "$labels" | grep compose.my-project
  echo "$labels" | grep dock.my-project
  # verify project ports are published
  docker port test | grep 8888
}
