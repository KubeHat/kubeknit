#!/usr/bin/env bats

# Copyright 2019 Cornelius Weig
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# bats setup function
setup() {
  export KONFIG_TEST_DIR="$(mktemp -d)"
  export KUBECONFIG="${KONFIG_TEST_DIR}/config"
  # never touch the real ~/.kube/config
  export HOME="${KONFIG_TEST_DIR}/home"
  mkdir -p "$HOME"
  unset XDG_CACHE_HOME XDG_CONFIG_HOME
}

# bats teardown function
teardown() {
  chmod -R u+rwx "$KONFIG_TEST_DIR"
  rm -rf "$KONFIG_TEST_DIR"
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
  sed "s|: credentials/|: ${testdata}/credentials/|" "$BATS_TEST_DIRNAME/testdata/$1" > "$KONFIG_TEST_DIR/$1.abs"
  echo "$KONFIG_TEST_DIR/$1.abs"
}

# context_names CONFIG prints the context names of CONFIG, separated by spaces
context_names() {
  kubectl config view --kubeconfig "$1" -o 'jsonpath={.contexts[*].name}'
}

# kubeconfig_value CONFIG JSONPATH
kubeconfig_value() {
  kubectl config view --raw --kubeconfig "$1" -o "jsonpath=$2"
}
