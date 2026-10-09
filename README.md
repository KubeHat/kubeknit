# kubectl knit

![Latest GitHub release](https://img.shields.io/github/v/release/KubeHat/kubectl-knit)
![GitHub workflow status](https://img.shields.io/github/actions/workflow/status/KubeHat/kubectl-knit/ci.yml)
![GitHub stars](https://img.shields.io/github/stars/KubeHat/kubectl-knit?label=github%20stars)

Import, delete, merge and export kubeconfig files. Only needs bash and kubectl.

kubectl knit is a maintained fork of [konfig](https://github.com/corneliusweig/konfig) by Cornelius Weig,
see [doc/releases](doc/releases) for the changes.

## Install

With [krew](https://krew.sigs.k8s.io):
```bash
kubectl krew install knit
```

Or download the script into your `PATH`, kubectl picks it up as `kubectl knit`:
```bash
curl -Lo kubectl-knit https://github.com/KubeHat/kubectl-knit/releases/latest/download/kubectl-knit
chmod +x kubectl-knit && sudo mv kubectl-knit /usr/local/bin/
```

## Usage

| Command                           | Does                                                   |
|-----------------------------------|--------------------------------------------------------|
| `kubectl knit import <CONFIG>..`  | adds configs to your kubeconfig                        |
| `kubectl knit delete <CONTEXT>..` | removes contexts, with their unused clusters and users |
| `kubectl knit merge <CONFIG>..`   | prints several configs merged into one                 |
| `kubectl knit export <CONTEXT>..` | prints a minimal config with only these contexts       |

Your kubeconfig is the first file in `KUBECONFIG`, or `~/.kube/config`.
`import` and `delete` only change it with `--save`; without it they just show what would happen.
Run `kubectl knit help` for all flags.

### Import
```bash
kubectl knit import --save new-cluster.yaml
cat new-cluster.yaml | kubectl knit import --save -
```
```
imported 1 kubeconfig(s) into /home/me/.kube/config ✅
```
- Entries that already exist with the same name are kept, with a ⚠️ warning. `--force` replaces them.
- Your current context is not changed.
- Certificate files are embedded into your kubeconfig. `--preserve-structure` keeps them as file paths.

Never redirect into your kubeconfig, the shell empties it before it can be read:
```bash
kubectl knit import new-cluster.yaml > ~/.kube/config   # WRONG, use --save
```

### Delete
```bash
kubectl knit delete --save old-cluster
```
```
deleted context "old-cluster" ✅
deleted cluster "old-cluster" ✅
deleted user "old-cluster" ✅
```
The cluster and user are only deleted when no other context uses them. `--context-only` keeps them.

### Merge
```bash
kubectl knit merge config1 config2 > merged.yaml
```

### Export
```bash
kubectl knit export dev > dev.yaml
kubectl knit export dev prod -k ~/.kube/config,other.yaml > dev-prod.yaml
```

### Shell completion
Completes `kubectl-knit` when you run the script directly:
```bash
source <(kubectl knit completion bash)   # or: zsh
```
