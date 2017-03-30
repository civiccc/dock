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

@test "configuration labels are added to Dock container during extension" {
  file Dockerfile <<-EOF
FROM alpine:latest
RUN apk update && apk add jq && rm -rf /var/cache/apk/*
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

@test "compose configuration label is not added to Dock container if compose file does not exist" {
  file Dockerfile <<-EOF
FROM alpine:latest
RUN apk update && apk add jq && rm -rf /var/cache/apk/*
EOF

  file .dock <<-EOF
dockerfile Dockerfile
default_command sh
EOF

  run dock -e test

  [ "$status" -eq 0 ]
  labels="$(get_labels test)"
  # ensure compose construction label for project is NOT set
  [[ "${lines[1]}" =~ "Unable to locate a docker-compose.yml file" ]]
  echo "$labels" | grep -v compose.my-project
  echo "$labels" | grep dock.my-project
}

@test "workspace dir is set as repo root of project during extension" {
  file Dockerfile <<-EOF
FROM alpine:latest
RUN apk update && apk add jq && rm -rf /var/cache/apk/*
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
RUN apk update && apk add jq && rm -rf /var/cache/apk/*
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
RUN apk update && apk add jq && rm -rf /var/cache/apk/*
EOF

  file .dock <<-EOF
dockerfile Dockerfile
default_command sh
publish 7777:7777
EOF

  file docker-compose.yml <<-EOF
version: '2'
EOF

  run dock -e test

  [ "$status" -eq 0 ]
  # verify image for Dock env has been created
  docker images --format '{{.Repository}}:{{.Tag}}'| grep test:dock
  # ensure Dock env container is left running
  container_running test
  # verify extension project configuration labels are set accordingly
  labels="$(get_labels test)"
  echo "$labels" | grep compose.my-project
  echo "$labels" | grep dock.my-project
  # verify projects label is updated
  echo "$labels" | grep projects
  echo "$labels" | grep my-project
  # verify project ports are published
  docker port test 7777
}

@test "extending an existing Dock container successfully" {
  file Dockerfile <<-EOF
FROM alpine:latest
RUN apk update && apk add jq && rm -rf /var/cache/apk/*
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
    --label dock.aproject=bar --label projects=aproject alpine:latest sh
  docker commit test test:dock

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
  # verify projects label is updated
  echo "$labels" | grep projects
  echo "$labels" | grep my-project
  echo "$labels" | grep aproject
  # verify project ports are published
  docker port test 8888
}

@test "startup_services labels are set when specified by project configuration" {
  file Dockerfile <<-EOF
FROM alpine:latest
RUN apk update && apk add jq && rm -rf /var/cache/apk/*
EOF

  file .dock <<-EOF
dockerfile Dockerfile
startup_services 'service backend'
default_command sh
EOF

  file docker-compose.yml <<-EOF
version: '2'
EOF

  run dock -e test

  [ "$status" -eq 0 ]
  # verify startup_services label has been applied
  labels="$(get_labels test)"
  [ "$(echo "$labels" | grep -c startup_services)" -eq 1 ]
  echo "$labels" | grep service
  echo "$labels" | grep backend
}

@test "duplicate startup_services label values are filtered during extension" {
  file Dockerfile <<-EOF
FROM alpine:latest
RUN apk update && apk add jq && rm -rf /var/cache/apk/*
EOF

  file .dock <<-EOF
dockerfile Dockerfile
startup_services 'another_service backend another_backend'
default_command sh
EOF

  file docker-compose.yml <<-EOF
version: '2'
EOF

  docker run --name test -d --label startup_services='service backend' alpine:latest sh
  run dock -e test

  [ "$status" -eq 0 ]
  # verify duplicated startup_services labels are filtered accordingly
  labels="$(get_labels test)"
  [ "$(echo "$labels" | grep -c startup_services)" -eq 1 ]
  [ "$(echo "$labels" | grep -c service)" -eq 1 ]
  [ "$(echo "$labels" | grep -c another_service)" -eq 1 ]
  [ "$(echo "$labels" | grep -c backend)" -eq 1 ]
  [ "$(echo "$labels" | grep -c another_backend)" -eq 1 ]
}
