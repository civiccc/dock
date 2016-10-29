#!/usr/bin/env bats

load ../utils

setup() {
  destroy-all-containers
  original_dir="$(pwd)"
  cd "$(create_repo)"
  file .dock <<-EOF
image=alpine:latest
pull=false

ask "Question 1" default_answer_1 answer_1
ask "Question 2" default_answer_2 answer_2
echo "\${answer_1}" > answer_1
echo "\${answer_2}" > answer_2

command=echo
EOF
}

teardown() {
  cd "${original_dir}"
}

@test "returns default answers when not run in an interactive context" {
  echo | dock
  [ "$(cat answer_1)" = default_answer_1 ]
  [ "$(cat answer_2)" = default_answer_2 ]
}

@test "prompts user on standard error for input when run in interactive context" {
  file answers <<-EOF
custom_answer_1
custom_answer_2
EOF

  # Since `script` returns when all input has been read, we need to append an
  # endless stream of "y" using `yes` onto the end of our answers so that
  # standard input doesn' close until `dock` has finished executing.
  yes | cat answers - | script -c dock /dev/null > output

  # Check that prompts are shown
  [[ "$(cat output)" =~ "Question 1" ]]
  [[ "$(cat output)" =~ "Question 2" ]]
  # ...and the default answers
  [[ "$(cat output)" =~ "default_answer_1" ]]
  [[ "$(cat output)" =~ "default_answer_2" ]]
}

@test "returns user's answers when run in an interactive context" {
  file answers <<-EOF
custom_answer_1
custom_answer_2
EOF

  # Since `script` returns when all input has been read, we need to append an
  # endless stream of "y" using `yes` onto the end of our answers so that
  # standard input doesn' close until `dock` has finished executing.
  yes | cat answers - | script -c dock /dev/null

  [ "$(cat answer_1)" = custom_answer_1 ]
  [ "$(cat answer_2)" = custom_answer_2 ]
}
