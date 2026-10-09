.PHONY: test deploy clean

test:
	cd test && bats kubeknit.bats

# out/bundle.tar.gz is the krew plugin: the script, with "kubectl kubeknit" in its help
deploy:
	mkdir -p out
	sed "/cat <<'EOF'/,/^EOF/s:kubeknit:kubectl kubeknit:" kubeknit > out/kubeknit-krew
	chmod +x out/kubeknit-krew
	cp LICENSE out/
	tar -czf out/bundle.tar.gz -C out kubeknit-krew LICENSE
	cd out && sha256sum bundle.tar.gz > bundle.tar.gz.sha256

clean:
	rm -rf out
