# Contributing

Pull requests are welcome. Add tests for fixed bugs and new features, and sign off your commits
(`git commit --signoff`, see [DCO](https://developercertificate.org/)).

## Testing

Install [bats](https://github.com/bats-core/bats-core) and kubectl, then run `make test`.
See [test/testdata](test/testdata/README.md) for the fixtures.

## Releasing

1. Add release notes in `doc/releases` and set the version in `kubeknit`.
2. Push a tag, e.g. `git tag v0.1.0 && git push origin v0.1.0`.
   CI runs `make deploy` and creates the GitHub release.
3. Test the release, then submit it to [krew-index](https://github.com/kubernetes-sigs/krew-index).
   After the first submission is merged, set the repository variable `KREW_INDEX_LISTED=true`,
   so that CI opens krew-index PRs for later tags.
