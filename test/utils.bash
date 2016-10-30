# Defines helper functions used across a variety of tests.

create_repo() {
  local dir_name="${1:-}"
  if [ -z "${dir_name}" ]; then
    repo_path="$(mktemp --directory)"
  else
    repo_path="$(mktemp --directory)/${dir_name}"
  fi

  mkdir -p "${repo_path}"
  git init "${repo_path}" >/dev/null 2>&1

  echo ${repo_path}
}

destroy_all_containers() {
  docker ps -aq | xargs --no-run-if-empty docker rm --force
}

container_running() {
  [ "$(docker inspect --format={{.State.Status}} "$1")" = running ]
}

file() {
  local file=$1

  # `file` will be passed file contents via STDIN
  while read data; do
    echo "$data" >> "$file"
  done
}
