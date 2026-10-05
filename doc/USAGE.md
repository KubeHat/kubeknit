<!-- DO NOT MOVE THIS FILE, BECAUSE IT NEEDS A PERMANENT ADDRESS -->

# kubeknit
kubeknit helps to merge, split, import or delete kubeconfig files

## Usage

The following assumes that you have installed `kubeknit` via
```bash
kubectl krew install kubeknit
```

### Import a kubeconfig
```bash
kubectl kubeknit import --save new-cfg
```
Imports the config file `new-cfg` into your kubeconfig. This is the first file in the `KUBECONFIG`
environment variable, or `~/.kube/config` if `KUBECONFIG` is not set.
To show the result without changing your kubeconfig, do
```bash
kubectl kubeknit import new-cfg
```

A kubeconfig can also be read from stdin:
```bash
clusterctl get kubeconfig my-cluster | kubectl kubeknit import --save -
```

If a cluster, user or context with the same name already exists in your kubeconfig, the existing one is kept
and `kubeknit` prints a warning. Use `--force` to overwrite existing entries with the imported ones.
Your current context is never changed by an import.

CAVEAT: due to how shells work, the following will lose your current `~/.kube/config`
```bash
# WRONG, don't do this!
kubectl kubeknit import new-cfg > ~/.kube/config
```

### Delete contexts
```bash
kubectl kubeknit delete --save my-context
```
Deletes the context `my-context` from your kubeconfig, together with its cluster and user,
unless they are still used by another context. Use `--context-only` to keep the cluster and user.
Without `--save`, the result is printed instead.

### Merge several kubeconfig files
```bash
kubectl kubeknit merge config1 config2 > merged-config
```
This variant creates a self-contained kubeconfig where all credentials are stored inline in the kubeconfig.
If you want to preserve the structure and keep credentials separate, use `--preserve-structure`.

### Extract a minimal kubeconfig for one or several contexts
This will extract a minimal kubeconfig with a single context `minikube`:
```bash
# extract context minikube from the default kubeconfig
kubectl kubeknit export minikube > minikube.config

# extract context minikube and docker-for-desktop from two input configs
kubectl kubeknit export minikube docker-for-desktop -k ~/.kube/other,~/dockercfg > local
```
