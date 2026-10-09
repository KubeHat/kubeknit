# Test data

Kubeconfig fixtures used by `test/knit.bats`. All certificates, keys and
passwords are dummies.

## Input configs

| File        | Contexts                         | Notes                                                        |
|-------------|----------------------------------|--------------------------------------------------------------|
| `config1`   | `context1`                       | flat: certificates are embedded (`*-data`)                   |
| `config-2`  | `context2`                       | non-flat: certificates are files in `credentials/`           |
| `config3`   | `context3`                       | user with username and password, no certificates            |
| `config23`  | `context2`, `context3`           | `config-2` and `config3` in one file                         |
| `config123` | `context1`, `context2`, `context3` | all three, usually loaded as the kubeconfig to modify      |

`credentials/` holds the dummy CA, client certificate and client key that the
non-flat configs reference by relative path. Tests use them to check that
flattening embeds certificates and that `-p` turns relative paths into
absolute ones, so the folder must stay next to the configs.

## Expected results

The `*-flat` files are what a command is expected to produce, with all
certificates embedded. `config12` is the expected result of
`import --preserve-structure config-2` into `config1`: the tests make its
relative certificate paths absolute before comparing.

| File             | Contexts                           |
|------------------|------------------------------------|
| `config2-flat`   | `context2`                         |
| `config12`       | `context1`, `context2` (not flat)  |
| `config12-flat`  | `context1`, `context2`             |
| `config13-flat`  | `context1`, `context3`             |
| `config23-flat`  | `context2`, `context3`             |
| `config123-flat` | `context1`, `context2`, `context3` |

## Running the tests

Install [bats](https://github.com/bats-core/bats-core) and kubectl, then run
from the repository root:

```sh
make test
```

The tests never touch your real kubeconfig: each one runs with `HOME` and
`KUBECONFIG` pointing to a temporary directory.

## Trying it by hand

Never use `--save` with a fixture as your kubeconfig, it would overwrite the
fixture. Work on a copy instead; `test/kubeconfig` is git-ignored:

```sh
cd test
cp testdata/config1 kubeconfig
export KUBECONFIG=$PWD/kubeconfig

../kubectl-knit import testdata/config23              # preview, nothing is changed
../kubectl-knit import --save testdata/config23       # imported 1 kubeconfig(s) into ... ✅
../kubectl-knit import --save testdata/config123      # ⚠️  warning: cluster "config-non-flat" already exists ...
../kubectl-knit delete context2                       # would delete ...
../kubectl-knit delete --save context2                # deleted context "context2" ✅
../kubectl-knit export context1 context3

cp testdata/config1 kubeconfig                    # start over
unset KUBECONFIG                                  # back to your real kubeconfig
rm kubeconfig                                     # clean up
```
