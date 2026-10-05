# konfig

![Latest GitHub release](https://img.shields.io/github/release/corneliusweig/konfig.svg)
![GitHub workflow status](https://img.shields.io/github/actions/workflow/status/corneliusweig/konfig/ci.yml)
![Written in Bash](https://img.shields.io/badge/written%20in-bash-19bb19.svg)
<!--![GitHub stars](https://img.shields.io/github/stars/corneliusweig/konfig.svg?label=github%20stars)-->

konfig helps to merge, split, import or delete kubeconfig files
 
## Usage

### Import a kubeconfig
```bash
konfig import --save new-cfg
```
Imports the config file `new-cfg` into your kubeconfig. This is the first file in the `KUBECONFIG`
environment variable, or `~/.kube/config` if `KUBECONFIG` is not set.
To show the result without changing your kubeconfig, do
```bash
konfig import new-cfg
```

A kubeconfig can also be read from stdin:
```bash
clusterctl get kubeconfig my-cluster | konfig import --save -
```

If a cluster, user or context with the same name already exists in your kubeconfig, the existing one is kept
and `konfig` prints a warning. Use `--force` to overwrite existing entries with the imported ones.
Your current context is never changed by an import.

By default, certificates are embedded into the result (flattened). Use `--preserve-structure` to keep
references to certificate files. Relative certificate paths are then rewritten to absolute paths, so that
they still work from your kubeconfig.

CAVEAT: due to how shells work, the following will lose your current `~/.kube/config`
```bash
# WRONG, don't do this!
konfig import new-cfg > ~/.kube/config
```

### Delete contexts
```bash
konfig delete --save my-context
```
Deletes the context `my-context` from your kubeconfig, together with its cluster and user,
unless they are still used by another context. Use `--context-only` to keep the cluster and user.
Without `--save`, the result is printed instead.

### Merge several kubeconfig files
```bash
konfig merge config1 config2 > merged-config
```
This variant creates a self-contained kubeconfig where all credentials are stored inline in the kubeconfig.
If you want to preserve the structure and keep credentials separate, use `--preserve-structure`.

### Extract a minimal kubeconfig for one or several contexts
This will extract a minimal kubeconfig with a single context `minikube`:
```bash
# extract context minikube from the default kubeconfig
konfig export minikube > minikube.config

# extract context minikube and docker-for-desktop from two input configs
konfig export minikube docker-for-desktop -k ~/.kube/other,~/dockercfg > local
```

### Shell completion
```bash
# bash, add to ~/.bashrc
source <(konfig completion bash)
# zsh, add to ~/.zshrc
source <(konfig completion zsh)
```

## Installation
There are several ways to install `konfig`.
The recommended installation method is via `krew`.

### Via krew
Krew is the `kubectl` plugin manager. If you have not yet installed `krew`, get it at
[https://github.com/kubernetes-sigs/krew](https://github.com/kubernetes-sigs/krew).
Then installation is as simple as
```bash
kubectl krew install konfig
```
The plugin will be available as `kubectl konfig`, see [doc/USAGE](doc/USAGE.md) for further details. You could also define an alias as well: `alias konfig = 'kubectl konfig'`

### Manual
When using the binaries for installation, also have a look at [USAGE](#Usage).

#### OSX & Linux
```bash
curl -Lo konfig https://github.com/corneliusweig/konfig/raw/v0.2.6/konfig \
  && chmod +x konfig \
  && sudo mv -i konfig /usr/local/bin
```
Feel free to change the `sudo mv` to put `konfig` in some other location from your `$PATH` variable.

#### Windows
> If you figure out how to run `konfig` on Windows, please send a PR with instructions.
