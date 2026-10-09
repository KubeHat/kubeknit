#!/usr/bin/env bats

COMMAND="$BATS_TEST_DIRNAME/../kubeknit"

load common

####  HELP

@test "help should not fail" {
  run ${COMMAND} help
  echo "$output"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "kubeknit helps to merge"* ]]
}

@test "--help should not fail" {
  run ${COMMAND} --help
  echo "$output"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "kubeknit helps to merge"* ]]
}

@test "-h should not fail" {
  run ${COMMAND} -h
  echo "$output"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "kubeknit helps to merge"* ]]
}

@test "no arguments given" {
  run ${COMMAND}
  echo "$output"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "kubeknit helps to merge"* ]]
}

####  MERGE

@test "merge --preserve-structure: three configs" {
  run ${COMMAND} merge --preserve-structure testdata/config{1,-2,3}
  echo "$output"
  [[ "$status" -eq 0 ]]
  [[ $(check_fixture 'testdata/config123' "$output") = 'same' ]]
}

@test "vanilla merge: three configs" {
  run ${COMMAND} merge testdata/config{1,-2,3}
  echo "$output"
  [[ "$status" -eq 0 ]]
  [[ $(check_fixture 'testdata/config123-flat' "$output") = 'same' ]]
}

@test "vanilla merge: single config" {
  run ${COMMAND} merge testdata/config123
  echo "$output"
  [[ "$status" -eq 0 ]]
  [[ $(check_fixture 'testdata/config123-flat' "$output") = 'same' ]]
}

####  IMPORT

@test "import single config and print to stdout" {
  use_config config1
  run ${COMMAND} import testdata/config-2
  echo "$output"
  [[ "$status" -eq 0 ]]
  [[ $(check_fixture 'testdata/config12-flat' "$output") = 'same' ]]
}

@test "import config with -- in name" {
  use_config config1
  cp testdata/config-2 testdata/config--2
  run ${COMMAND} import testdata/config--2
  rm testdata/config--2
  echo "$output"
  [[ "$status" -eq 0 ]]
  [[ $(check_fixture 'testdata/config12-flat' "$output") = 'same' ]]
}

@test "import multiple configs and print to stdout" {
  use_config config1
  run ${COMMAND} import testdata/config-2 testdata/config3
  echo "$output"
  [[ "$status" -eq 0 ]]
  [[ $(check_fixture 'testdata/config123-flat' "$output") = 'same' ]]
}

@test "import single config" {
  use_config config1
  run ${COMMAND} import --save testdata/config-2
  echo "$output"
  [[ "$status" -eq 0 ]]
  [[ "$output" = *'imported 1 kubeconfig(s) into '*' ✅' ]]
  [[ $(check_kubeconfig 'testdata/config12-flat') = 'same' ]]
}

@test "import multiple configs" {
  use_config config1
  run ${COMMAND} import -s testdata/config-2 testdata/config3
  echo "$output"
  [[ "$status" -eq 0 ]]
  [[ $(check_kubeconfig 'testdata/config123-flat') = 'same' ]]
}

@test "import single config and preserve structure" {
  use_config config1
  run ${COMMAND} import --preserve-structure --save testdata/config-2
  echo "$output"
  [[ "$status" -eq 0 ]]
  # relative certificate paths must still work after the import
  [[ $(check_kubeconfig "$(absolute_fixture config12)") = 'same' ]]
}

@test "import multiple configs and preserve structure" {
  use_config config1
  run ${COMMAND} import -p -s testdata/config-2 testdata/config3
  echo "$output"
  [[ "$status" -eq 0 ]]
  [[ $(check_kubeconfig "$(absolute_fixture config123)") = 'same' ]]
}

@test "import single config from stdin and print to stdout" {
  use_config config1
  run bash -c "cat testdata/config3 | ${COMMAND} import -i"
  echo "$output"
  [[ "$status" -eq 0 ]]
  [[ $(check_fixture 'testdata/config13-flat' "$output") = 'same' ]]
}

@test "import single config from stdin" {
  use_config config1
  run bash -c "cat testdata/config3 | ${COMMAND} import -i --save"
  echo "$output"
  [[ "$status" -eq 0 ]]
  [[ $(check_kubeconfig 'testdata/config13-flat') = 'same' ]]
}

@test "import no stdin should preserve .kube/config" {
  use_config config1
  run bash -c "${COMMAND} import -i --save < /dev/null"
  echo "$output"
  [[ "$status" -eq 1 ]]
  [[ "$output" = *"error: no kubeconfig received on stdin"* ]]
  [[ $(check_kubeconfig 'testdata/config1') = 'same' ]]
}

@test "import invalid file from stdin should preserve .kube/config" {
  use_config config1
  run bash -c "echo invalid | ${COMMAND} import -i --save"
  echo "$output"
  [[ "$status" -eq 1 ]]
  [[ $(check_kubeconfig 'testdata/config1') = 'same' ]]
}

@test "failed read of imported config should preserve .kube/config" {
  use_config config1
  chmod u-r testdata/config-2
  run ${COMMAND} import -s /does/not/exist testdata/config-2
  chmod u+r testdata/config-2
  echo "$output"
  [[ "$status" -eq 1 ]]
  [[ $(check_kubeconfig 'testdata/config1') = 'same' ]]
}

@test "import non-existing config should fail and preserve .kube/config" {
  use_config config1
  run ${COMMAND} import -s /does/not/exist
  echo "$output"
  [[ "$status" -eq 1 ]]
  [[ "$output" = *'error: kubeconfig "/does/not/exist" does not exist'* ]]
  [[ $(check_kubeconfig 'testdata/config1') = 'same' ]]
}

@test "import without configs should fail" {
  use_config config1
  run ${COMMAND} import --save
  echo "$output"
  [[ "$status" -eq 1 ]]
  [[ "$output" = *"error: kubeconfigs to import are missing"* ]]
  [[ $(check_kubeconfig 'testdata/config1') = 'same' ]]
}

@test "import --save writes to KUBECONFIG regardless of XDG_CACHE_HOME" {
  use_config config1
  export XDG_CACHE_HOME="$KUBEKNIT_TEST_DIR/cache"
  mkdir -p "$XDG_CACHE_HOME"
  run ${COMMAND} import --save testdata/config-2
  echo "$output"
  [[ "$status" -eq 0 ]]
  [[ $(check_kubeconfig 'testdata/config12-flat') = 'same' ]]
  [[ ! -e "$XDG_CACHE_HOME/config" ]]
}

@test "import --save writes to ~/.kube/config without KUBECONFIG" {
  unset KUBECONFIG
  run ${COMMAND} import --save testdata/config1
  echo "$output"
  [[ "$status" -eq 0 ]]
  [[ $(check_file 'testdata/config1' "$HOME/.kube/config") = 'same' ]]
}

@test "import --save writes to the first file in KUBECONFIG" {
  cp testdata/config1 "$KUBEKNIT_TEST_DIR/first"
  cp testdata/config3 "$KUBEKNIT_TEST_DIR/second"
  export KUBECONFIG="$KUBEKNIT_TEST_DIR/first:$KUBEKNIT_TEST_DIR/second"
  run ${COMMAND} import --save testdata/config-2
  echo "$output"
  [[ "$status" -eq 0 ]]
  [[ $(check_file 'testdata/config12-flat' "$KUBEKNIT_TEST_DIR/first") = 'same' ]]
  [[ $(check_file 'testdata/config3' "$KUBEKNIT_TEST_DIR/second") = 'same' ]]
}

@test "import flags may follow the config" {
  use_config config1
  run ${COMMAND} import testdata/config-2 --save
  echo "$output"
  [[ "$status" -eq 0 ]]
  [[ $(check_kubeconfig 'testdata/config12-flat') = 'same' ]]
}

@test "import from redirected stdin" {
  use_config config1
  run bash -c "${COMMAND} import -i --save < testdata/config3"
  echo "$output"
  [[ "$status" -eq 0 ]]
  [[ $(check_kubeconfig 'testdata/config13-flat') = 'same' ]]
}

@test "import '-' reads from stdin" {
  use_config config1
  run bash -c "cat testdata/config3 | ${COMMAND} import -s -"
  echo "$output"
  [[ "$status" -eq 0 ]]
  [[ $(check_kubeconfig 'testdata/config13-flat') = 'same' ]]
}

@test "import works from a read-only working directory" {
  [[ "$EUID" -ne 0 ]] || skip "root ignores file permissions"
  use_config config1
  local cfg="$(cd testdata && pwd -P)/config-2"
  mkdir "$KUBEKNIT_TEST_DIR/readonly"
  chmod a-w "$KUBEKNIT_TEST_DIR/readonly"
  run bash -c "cd '$KUBEKNIT_TEST_DIR/readonly' && ${COMMAND} import -s '$cfg'"
  echo "$output"
  [[ "$status" -eq 0 ]]
  [[ $(check_kubeconfig 'testdata/config12-flat') = 'same' ]]
}

@test "import --save keeps a symlinked kubeconfig" {
  cp testdata/config1 "$KUBEKNIT_TEST_DIR/real-config"
  ln -s "$KUBEKNIT_TEST_DIR/real-config" "$KUBECONFIG"
  run ${COMMAND} import -s testdata/config-2
  echo "$output"
  [[ "$status" -eq 0 ]]
  [[ -L "$KUBECONFIG" ]]
  [[ $(check_file 'testdata/config12-flat' "$KUBEKNIT_TEST_DIR/real-config") = 'same' ]]
}

@test "import keeps existing entries and warns about conflicts" {
  use_config config1
  sed 's/context2/context1/' "$(absolute_fixture config-2)" > "$KUBEKNIT_TEST_DIR/clash"
  run ${COMMAND} import -s "$KUBEKNIT_TEST_DIR/clash"
  echo "$output"
  [[ "$status" -eq 0 ]]
  [[ "$output" = *'⚠️  warning: context "context1" already exists'*'use --force to overwrite'* ]]
  [[ $(kubeconfig_value "$KUBECONFIG" '{.contexts[?(@.name=="context1")].context.cluster}') = 'config-flat' ]]
}

@test "import --force overwrites existing entries" {
  use_config config1
  sed 's/context2/context1/' "$(absolute_fixture config-2)" > "$KUBEKNIT_TEST_DIR/clash"
  run ${COMMAND} import -s --force "$KUBEKNIT_TEST_DIR/clash"
  echo "$output"
  [[ "$status" -eq 0 ]]
  [[ "$output" = *'warning: overwriting context "context1"'* ]]
  [[ $(kubeconfig_value "$KUBECONFIG" '{.contexts[?(@.name=="context1")].context.cluster}') = 'config-non-flat' ]]
}

@test "import --force keeps the current context" {
  use_config config1
  run ${COMMAND} import -s -f testdata/config3
  echo "$output"
  [[ "$status" -eq 0 ]]
  [[ $(kubeconfig_value "$KUBECONFIG" '{.current-context}') = 'context1' ]]
  [[ $(context_names "$KUBECONFIG") = 'context1 context3' ]]
}

@test "import does not warn about identical entries" {
  use_config config1
  run ${COMMAND} import -s testdata/config1
  echo "$output"
  [[ "$status" -eq 0 ]]
  [[ "$output" != *"warning"* ]]
  [[ $(check_kubeconfig 'testdata/config1') = 'same' ]]
}

####  DELETE

@test "delete context and print to stdout" {
  use_config config123
  run ${COMMAND} delete context2
  echo "$output"
  [[ "$status" -eq 0 ]]
  [[ "$output" = *'would delete context "context2"'* ]]
  [[ "$output" = *'nothing was changed, use --save'* ]]
  [[ $(check_fixture 'testdata/config13-flat' "$(${COMMAND} delete context2 2>/dev/null)") = 'same' ]]
  [[ $(check_kubeconfig 'testdata/config123') = 'same' ]]
}

@test "delete context and save" {
  use_config config123
  run ${COMMAND} delete --save context2
  echo "$output"
  [[ "$status" -eq 0 ]]
  [[ "$output" = *'deleted context "context2" ✅'* ]]
  [[ "$output" = *'deleted cluster "config-non-flat" ✅'* ]]
  [[ "$output" = *'deleted user "config-non-flat" ✅'* ]]
  [[ "$output" != *'apiVersion'* ]]
  [[ $(check_kubeconfig 'testdata/config13-flat') = 'same' ]]
}

@test "delete multiple contexts" {
  use_config config123
  run ${COMMAND} delete -s context2 context3
  echo "$output"
  [[ "$status" -eq 0 ]]
  [[ $(check_kubeconfig 'testdata/config1') = 'same' ]]
}

@test "delete current context unsets it" {
  use_config config123
  run ${COMMAND} delete -s context1
  echo "$output"
  [[ "$status" -eq 0 ]]
  [[ "$output" = *'warning: "context1" was the current context'* ]]
  [[ $(kubeconfig_value "$KUBECONFIG" '{.current-context}') = '' ]]
  [[ $(context_names "$KUBECONFIG") = 'context2 context3' ]]
}

@test "delete keeps clusters and users still in use" {
  use_config config1
  kubectl config set-context other --cluster=config-flat --user=config-flat > /dev/null
  run ${COMMAND} delete -s context1
  echo "$output"
  [[ "$status" -eq 0 ]]
  [[ "$output" != *'deleted cluster'* ]]
  [[ $(kubeconfig_value "$KUBECONFIG" '{.clusters[*].name}') = 'config-flat' ]]
  [[ $(kubeconfig_value "$KUBECONFIG" '{.users[*].name}') = 'config-flat' ]]
}

@test "delete contexts which share a cluster" {
  use_config config1
  kubectl config set-context other --cluster=config-flat --user=config-flat > /dev/null
  run ${COMMAND} delete -s context1 other
  echo "$output"
  [[ "$status" -eq 0 ]]
  [[ $(kubeconfig_value "$KUBECONFIG" '{.clusters[*].name}') = '' ]]
  [[ $(kubeconfig_value "$KUBECONFIG" '{.users[*].name}') = '' ]]
}

@test "delete --context-only keeps clusters and users" {
  use_config config123
  run ${COMMAND} delete -s --context-only context2
  echo "$output"
  [[ "$status" -eq 0 ]]
  [[ $(context_names "$KUBECONFIG") = 'context1 context3' ]]
  [[ $(kubeconfig_value "$KUBECONFIG" '{.clusters[*].name}') = 'config-flat config-non-flat config-passwd' ]]
}

@test "delete unknown context should fail and preserve .kube/config" {
  use_config config123
  run ${COMMAND} delete -s context2 nope
  echo "$output"
  [[ "$status" -eq 1 ]]
  [[ "$output" = *'🔴 error: context "nope" not found'* ]]
  [[ $(check_kubeconfig 'testdata/config123') = 'same' ]]
}

@test "delete without any context" {
  use_config config123
  run ${COMMAND} delete --save
  echo "$output"
  [[ "$status" -eq 1 ]]
  [[ "$output" = *"error: contexts to delete are missing"* ]]
}

####  EXPORT

@test "exporting with '--kubeconfig' yields original config - I" {
  run ${COMMAND} export context1 --kubeconfig testdata/config123
  echo "$output"
  [[ "$status" -eq 0 ]]
  [[ $(check_fixture 'testdata/config1' "$output") = 'same' ]]
}

@test "exporting with '--kubeconfig' yields original config - II" {
  run ${COMMAND} export -k testdata/config123 context2
  echo "$output"
  [[ "$status" -eq 0 ]]
  [[ $(check_fixture 'testdata/config2-flat' "$output") = 'same' ]]
}

@test "exporting with KUBECONFIG yields original config" {
  use_config config123
  run ${COMMAND} export context3
  echo "$output"
  [[ "$status" -eq 0 ]]
  [[ $(check_fixture 'testdata/config3' "$output") = 'same' ]]
}

@test "exporting with multiple from multiple kubeconfigs - I" {
  run ${COMMAND} split context2 context3 -k testdata/config1,testdata/config3 --kubeconfig testdata/config-2
  echo "$output"
  [[ "$status" -eq 0 ]]
  [[ $(check_fixture 'testdata/config23-flat' "$output") = 'same' ]]
}

@test "exporting with multiple from multiple kubeconfigs - II" {
  run ${COMMAND} split -k testdata/config1 context1 --kubeconfig testdata/config23 context2
  echo "$output"
  [[ "$status" -eq 0 ]]
  [[ $(check_fixture 'testdata/config12-flat' "$output") = 'same' ]]
}

@test "exporting without any context - I" {
  run ${COMMAND} export -k testdata/config1 -k testdata/config23
  echo "$output"
  [[ "$status" -eq 1 ]]
  [[ "$output" = *"error: contexts to export are missing"* ]]
}

@test "exporting without any context - II" {
  run ${COMMAND} export
  echo "$output"
  [[ "$status" -eq 1 ]]
  [[ "$output" = *"error: contexts to export are missing"* ]]
}

####  ERRORS

@test "no kubectl detected" {
  # /bin may contain kubectl (e.g. on GitHub runners), so build a PATH which
  # only provides bash for the shebang
  local bin="$KUBEKNIT_TEST_DIR/bin"
  mkdir -p "$bin"
  ln -s "$(command -v bash)" "$bin/bash"
  run env -u KUBEKNIT_KUBECTL PATH="$bin" ${COMMAND}
  echo "$output"
  [[ "$status" -eq 1 ]]
  [[ "$output" = "🔴 error: kubectl is not installed" ]]
}

@test "unknown subcommand" {
  run ${COMMAND} foobar
  echo "$output"
  [[ "$status" -eq 1 ]]
  [[ "$output" = *"error: unknown command \"foobar\""* ]]
}

@test "unknown flag - export" {
  run ${COMMAND} export -u
  echo "$output"
  [[ "$status" -eq 1 ]]
  [[ "$output" = *"error: unrecognized flag \"-u\""* ]]
}

@test "unknown flag - import" {
  run ${COMMAND} import -u
  echo "$output"
  [[ "$status" -eq 1 ]]
  [[ "$output" = *"error: unrecognized flag \"-u\""* ]]
}

@test "unknown flag - merge" {
  run ${COMMAND} merge -u
  echo "$output"
  [[ "$status" -eq 1 ]]
  [[ "$output" = *"error: unrecognized flag \"-u\""* ]]
}

@test "unknown flag - I" {
  run ${COMMAND} -u
  echo "$output"
  [[ "$status" -eq 1 ]]
  [[ "$output" = *"error: unrecognized flag \"-u\""* ]]
}

@test "unknown flag - II" {
  run ${COMMAND} --unknown
  echo "$output"
  [[ "$status" -eq 1 ]]
  [[ "$output" = *"error: unrecognized flag \"--unknown\""* ]]
}

@test "unknown flag - delete" {
  run ${COMMAND} delete -u
  echo "$output"
  [[ "$status" -eq 1 ]]
  [[ "$output" = *"error: unrecognized flag \"-u\""* ]]
}

@test "merge without configs" {
  run ${COMMAND} merge
  echo "$output"
  [[ "$status" -eq 1 ]]
  [[ "$output" = *"error: kubeconfigs to merge are missing"* ]]
}

@test "merge non-existing config" {
  run ${COMMAND} merge testdata/config1 testdata/typo
  echo "$output"
  [[ "$status" -eq 1 ]]
  [[ "$output" = *'error: kubeconfig "testdata/typo" does not exist'* ]]
}

@test "export with missing kubeconfig value" {
  run ${COMMAND} export context1 -k
  echo "$output"
  [[ "$status" -eq 1 ]]
  [[ "$output" = *'error: flag "-k" requires a kubeconfig'* ]]
}

@test "export with --kubeconfig=" {
  run ${COMMAND} export context3 --kubeconfig=testdata/config1,testdata/config3
  echo "$output"
  [[ "$status" -eq 0 ]]
  [[ $(check_fixture 'testdata/config3' "$output") = 'same' ]]
}

@test "export non-existing kubeconfig" {
  run ${COMMAND} export context1 -k testdata/config1,testdata/typo
  echo "$output"
  [[ "$status" -eq 1 ]]
  [[ "$output" = *'error: kubeconfig "testdata/typo" does not exist'* ]]
}

####  MISC

@test "version" {
  run ${COMMAND} version
  echo "$output"
  [[ "$status" -eq 0 ]]
  [[ "$output" = "kubeknit v"* ]]
}

@test "completion bash" {
  run ${COMMAND} completion bash
  [[ "$status" -eq 0 ]]
  [[ "$output" = *"complete -o default -F _kubeknit kubeknit"* ]]
  bash -n <(echo "$output")
}

@test "completion zsh" {
  run ${COMMAND} completion zsh
  [[ "$status" -eq 0 ]]
  [[ "$output" = "autoload -U +X bashcompinit && bashcompinit"* ]]
}

@test "completion suggests contexts" {
  use_config config123
  run bash -c "source <(${COMMAND} completion bash)
    COMP_WORDS=(kubeknit delete con); COMP_CWORD=2; _kubeknit; echo \"\${COMPREPLY[*]}\""
  echo "$output"
  [[ "$status" -eq 0 ]]
  [[ "$output" = 'context1 context2 context3' ]]
}

@test "completion unknown shell" {
  run ${COMMAND} completion fish
  echo "$output"
  [[ "$status" -eq 1 ]]
  [[ "$output" = *'error: unsupported shell "fish"'* ]]
}

@test "no temporary files are left behind" {
  use_config config1
  export TMPDIR="$KUBEKNIT_TEST_DIR/tmp"
  mkdir "$TMPDIR"
  run ${COMMAND} import -s testdata/config-2
  [[ "$status" -eq 0 ]]
  run ${COMMAND} import -s /does/not/exist
  [[ "$status" -eq 1 ]]
  [[ -z "$(ls -A "$TMPDIR")" ]]
  [[ -z "$(ls testdata | grep kubeknit_ || true)" ]]
}
