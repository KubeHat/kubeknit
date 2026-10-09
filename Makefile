.PHONY: test deploy clean

test:
	cd test && bats knit.bats

# out/bundle.tar.gz is the krew plugin
deploy:
	mkdir -p out
	cp kubectl-knit LICENSE out/
	tar -czf out/bundle.tar.gz -C out kubectl-knit LICENSE
	cd out && sha256sum bundle.tar.gz > bundle.tar.gz.sha256

clean:
	rm -rf out
