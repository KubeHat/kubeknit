#!/usr/bin/env bats

# bats setup function
setup() {
  export KNIT_TEST_DIR="$(mktemp -d)"
  export KUBECONFIG="${KNIT_TEST_DIR}/config"
  # never touch the real ~/.kube/config
  export HOME="${KNIT_TEST_DIR}/home"
  mkdir -p "$HOME"
  unset XDG_CACHE_HOME XDG_CONFIG_HOME
}

# bats teardown function
teardown() {
  chmod -R u+rwx "$KNIT_TEST_DIR"
  rm -rf "$KNIT_TEST_DIR"
}

use_config() {
  cp "$BATS_TEST_DIRNAME/testdata/$1" "$KUBECONFIG"
}

# Newer kubectl versions omit "preferences: {}", so ignore it when comparing.
normalize() {
  grep -vx 'preferences: {}' || true
}

# check_file FIXTURE FILE
check_file() {
  diff -U3 <(normalize < "${1}") <(normalize < "${2}") && echo 'same' || echo 'different'
}

check_kubeconfig() {
  check_file "${1}" "${KUBECONFIG}"
}

check_fixture() {
  diff -U3 <(normalize < "${1}") <(echo "${2}" | normalize) && echo 'same' || echo 'different'
}

# absolute_fixture FIXTURE prints the path of a copy of FIXTURE, where relative
# certificate paths are replaced by absolute paths into testdata.
absolute_fixture() {
  local testdata
  testdata="$(cd "$BATS_TEST_DIRNAME/testdata" && pwd -P)"
  sed "s|: credentials/|: ${testdata}/credentials/|" "$BATS_TEST_DIRNAME/testdata/$1" > "$KNIT_TEST_DIR/$1.abs"
  echo "$KNIT_TEST_DIR/$1.abs"
}

# context_names CONFIG prints the context names of CONFIG, separated by spaces
context_names() {
  kubectl config view --kubeconfig "$1" -o 'jsonpath={.contexts[*].name}'
}

# kubeconfig_value CONFIG JSONPATH
kubeconfig_value() {
  kubectl config view --raw --kubeconfig "$1" -o "jsonpath=$2"
}
