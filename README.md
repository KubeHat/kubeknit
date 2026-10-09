# `kubeknit`

![Latest GitHub release](https://img.shields.io/github/release/KubeHat/kubeknit.svg)
![GitHub workflow status](https://img.shields.io/github/actions/workflow/status/KubeHat/kubeknit/ci.yml)
![GitHub stars](https://img.shields.io/github/stars/KubeHat/kubeknit.svg?label=github%20stars)

Import, delete, merge and export kubeconfig files. A single bash script around `kubectl config`.

kubeknit is a maintained fork of [konfig](https://github.com/corneliusweig/konfig) by Cornelius Weig,
see [doc/releases](doc/releases) for the changes.

## Install

With [krew](https://krew.sigs.k8s.io), then run it as `kubectl kubeknit`:
```bash
kubectl krew install kubeknit
```

Or download the script (needs `bash` and `kubectl`):
```bash
curl -Lo kubeknit https://github.com/KubeHat/kubeknit/releases/latest/download/kubeknit
chmod +x kubeknit && sudo mv kubeknit /usr/local/bin/
```

## Usage

| Command                       | Does                                                   |
|-------------------------------|--------------------------------------------------------|
| `kubeknit import <CONFIG>..`  | adds configs to your kubeconfig                        |
| `kubeknit delete <CONTEXT>..` | removes contexts, with their unused clusters and users |
| `kubeknit merge <CONFIG>..`   | prints several configs merged into one                 |
| `kubeknit export <CONTEXT>..` | prints a minimal config with only these contexts       |

Your kubeconfig is the first file in `KUBECONFIG`, or `~/.kube/config`.
`import` and `delete` only change it with `--save`; without it they just show what would happen.
Run `kubeknit help` for all flags.

### Import
```bash
kubeknit import --save new-cluster.yaml
cat new-cluster.yaml | kubeknit import --save -
```
```
imported 1 kubeconfig(s) into /home/me/.kube/config ✅
```
- Entries that already exist with the same name are kept, with a ⚠️ warning. `--force` replaces them.
- Your current context is not changed.
- Certificate files are embedded into your kubeconfig. `--preserve-structure` keeps them as file paths.

Never redirect into your kubeconfig, the shell empties it before kubeknit can read it:
```bash
kubeknit import new-cluster.yaml > ~/.kube/config   # WRONG, use --save
```

### Delete
```bash
kubeknit delete --save old-cluster
```
```
deleted context "old-cluster" ✅
deleted cluster "old-cluster" ✅
deleted user "old-cluster" ✅
```
The cluster and user are only deleted when no other context uses them. `--context-only` keeps them.

### Merge
```bash
kubeknit merge config1 config2 > merged.yaml
```

### Export
```bash
kubeknit export dev > dev.yaml
kubeknit export dev prod -k ~/.kube/config,other.yaml > dev-prod.yaml
```

### Shell completion
```bash
source <(kubeknit completion bash)   # or: zsh
```
