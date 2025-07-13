rebuild:
	darwin-rebuild switch --flake $(CURDIR)

fmt:
	nix fmt

update:
	nix flake update
