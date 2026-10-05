# kubeknit

![Latest GitHub release](https://img.shields.io/github/release/OWNER/kubeknit.svg)
![GitHub workflow status](https://img.shields.io/github/actions/workflow/status/OWNER/kubeknit/ci.yml)
![Written in Bash](https://img.shields.io/badge/written%20in-bash-19bb19.svg)
<!--![GitHub stars](https://img.shields.io/github/stars/OWNER/kubeknit.svg?label=github%20stars)-->

kubeknit helps to merge, split, import or delete kubeconfig files

kubeknit is a maintained fork of [konfig](https://github.com/corneliusweig/konfig) by Cornelius Weig,
which is no longer maintained. See [doc/releases](doc/releases) for what changed since konfig v0.2.6.

## Usage

### Import a kubeconfig
```bash
kubeknit import --save new-cfg
```
Imports the config file `new-cfg` into your kubeconfig. This is the first file in the `KUBECONFIG`
environment variable, or `~/.kube/config` if `KUBECONFIG` is not set.
To show the result without changing your kubeconfig, do
```bash
kubeknit import new-cfg
```

A kubeconfig can also be read from stdin:
```bash
clusterctl get kubeconfig my-cluster | kubeknit import --save -
```

If a cluster, user or context with the same name already exists in your kubeconfig, the existing one is kept
and `kubeknit` prints a warning. Use `--force` to overwrite existing entries with the imported ones.
Your current context is never changed by an import.

By default, certificates are embedded into the result (flattened). Use `--preserve-structure` to keep
references to certificate files. Relative certificate paths are then rewritten to absolute paths, so that
they still work from your kubeconfig.

CAVEAT: due to how shells work, the following will lose your current `~/.kube/config`
```bash
# WRONG, don't do this!
kubeknit import new-cfg > ~/.kube/config
```

### Delete contexts
```bash
kubeknit delete --save my-context
```
Deletes the context `my-context` from your kubeconfig, together with its cluster and user,
unless they are still used by another context. Use `--context-only` to keep the cluster and user.
Without `--save`, the result is printed instead.

### Merge several kubeconfig files
```bash
kubeknit merge config1 config2 > merged-config
```
This variant creates a self-contained kubeconfig where all credentials are stored inline in the kubeconfig.
If you want to preserve the structure and keep credentials separate, use `--preserve-structure`.

### Extract a minimal kubeconfig for one or several contexts
This will extract a minimal kubeconfig with a single context `minikube`:
```bash
# extract context minikube from the default kubeconfig
kubeknit export minikube > minikube.config

# extract context minikube and docker-for-desktop from two input configs
kubeknit export minikube docker-for-desktop -k ~/.kube/other,~/dockercfg > local
```

### Shell completion
```bash
# bash, add to ~/.bashrc
source <(kubeknit completion bash)
# zsh, add to ~/.zshrc
source <(kubeknit completion zsh)
```

## Installation
There are several ways to install `kubeknit`.
The recommended installation method is via `krew`.

### Via krew
Krew is the `kubectl` plugin manager. If you have not yet installed `krew`, get it at
[https://github.com/kubernetes-sigs/krew](https://github.com/kubernetes-sigs/krew).
Then installation is as simple as
```bash
kubectl krew install kubeknit
```
The plugin will be available as `kubectl kubeknit`, see [doc/USAGE](doc/USAGE.md) for further details. You could also define an alias as well: `alias kubeknit = 'kubectl kubeknit'`

### Manual
When using the binaries for installation, also have a look at [USAGE](#Usage).

#### OSX & Linux
```bash
curl -Lo kubeknit https://github.com/OWNER/kubeknit/releases/latest/download/kubeknit \
  && chmod +x kubeknit \
  && sudo mv -i kubeknit /usr/local/bin
```
Feel free to change the `sudo mv` to put `kubeknit` in some other location from your `$PATH` variable.

#### Windows
> If you figure out how to run `kubeknit` on Windows, please send a PR with instructions.
