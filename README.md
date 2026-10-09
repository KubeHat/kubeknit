# kubeknit

![Latest GitHub release](https://img.shields.io/github/release/KubeHat/kubeknit.svg)
![GitHub workflow status](https://img.shields.io/github/actions/workflow/status/KubeHat/kubeknit/ci.yml)

kubeknit helps to merge, split, import or delete kubeconfig files.

It is a maintained fork of [konfig](https://github.com/corneliusweig/konfig) by Cornelius Weig.
See [doc/releases](doc/releases) for what changed since konfig v0.2.6.

## Installation

Via [krew](https://krew.sigs.k8s.io), as `kubectl kubeknit`:
```bash
kubectl krew install kubeknit
```

Manually:
```bash
curl -Lo kubeknit https://github.com/KubeHat/kubeknit/releases/latest/download/kubeknit
chmod +x kubeknit && sudo mv kubeknit /usr/local/bin/
```

## Usage

Your kubeconfig is the first file in `KUBECONFIG`, or `~/.kube/config`.
`import` and `delete` only change it with `--save`.

### Import
```bash
kubeknit import --save new-cfg
clusterctl get kubeconfig my-cluster | kubeknit import --save -
```
Existing clusters, users and contexts with the same name are kept, with a warning; `--force` overwrites
them. Certificates are embedded, unless you pass `--preserve-structure`. The current context is not changed.

Do not redirect into your kubeconfig, the shell empties it before kubeknit reads it:
```bash
kubeknit import new-cfg > ~/.kube/config   # WRONG
```

### Delete
```bash
kubeknit delete --save my-context
```
Also deletes the context's cluster and user, unless another context still uses them.
`--context-only` keeps them.

### Merge
```bash
kubeknit merge config1 config2 > merged
```
Credentials are embedded, unless you pass `--preserve-structure`.

### Export
```bash
kubeknit export minikube > minikube.config
kubeknit export minikube docker-desktop -k ~/.kube/other,~/dockercfg > local
```

### Shell completion
```bash
source <(kubeknit completion bash)   # or zsh
```
