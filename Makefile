UNAME := $(shell uname)

ifeq ($(UNAME), Darwin)
HOSTNAME ?= $(shell scutil --get LocalHostName)
else
HOSTNAME ?= $(shell hostname)
endif

.DEFAULT_GOAL := switch

.PHONY: switch
switch:
ifeq ($(UNAME), Darwin)
	nix build ".#darwinConfigurations.$(HOSTNAME).system"
	sudo ./result/sw/bin/darwin-rebuild switch --flake "$(CURDIR)#$(HOSTNAME)"
else
	sudo nixos-rebuild switch --flake $(CURDIR)
endif

.PHONY: build
build:
ifeq ($(UNAME), Darwin)
ifdef TRACE
	nix build ".#darwinConfigurations.$(HOSTNAME).system" --show-trace
else
	nix build ".#darwinConfigurations.$(HOSTNAME).system"
endif
else
	nixos-rebuild build --flake $(CURDIR)
endif

.PHONY: format
format:
	nix fmt

.PHONY: update
update:
	nix flake update

.PHONY: clean
clean:
	rm -rf result
