# Nix Configuration

[![License: Unlicense](https://img.shields.io/badge/License-Unlicense-blue.svg)](LICENSE)
[![Nix](https://img.shields.io/badge/Built%20with-Nix-5277C3.svg?logo=nixos&logoColor=white)](https://nixos.org)

A declarative system configuration using [nix-darwin](https://github.com/LnL7/nix-darwin) for macOS, NixOS for Linux, and [home-manager](https://github.com/nix-community/home-manager) for user environments. This repository manages system settings, packages, and user environments across multiple machines.

## Features

- Declarative macOS system configuration with nix-darwin
- User environment management with home-manager
- Secrets management using [sops-nix](https://github.com/Mic92/sops-nix)
- Catppuccin theming support
- Modular configuration structure using [Blueprint](https://github.com/numtide/blueprint)
- Comprehensive development tooling (Git, Docker, Kubernetes, Terraform, AWS CLI, etc.)

## Requirements

- Git (available through Xcode Command Line Tools on macOS)
- [Determinate Nix](https://docs.determinate.systems/determinate-nix/) (macOS only for now)
- [Homebrew](https://brew.sh/) (macOS only)

## Project Structure

```
.
├── flake.nix                # Main flake configuration
├── hosts/                   # Per-host configurations
│   ├── personal/
│   │   ├── darwin-configuration.nix
│   │   └── users/dosten/
│   │       ├── home-configuration.nix
│   │       └── secrets/     # Host-specific secrets
│   └── work/
│       ├── darwin-configuration.nix
│       └── users/dsaintesteben/
│           ├── home-configuration.nix
│           └── secrets/     # Host-specific secrets
├── modules/
│   ├── darwin/              # macOS system modules
│   │   ├── fonts.nix
│   │   ├── homebrew.nix
│   │   ├── macos-defaults.nix
│   │   ├── security.nix
│   │   └── shared.nix
│   └── home/                # Home-manager modules
│       ├── git.nix
│       ├── fish.nix
│       ├── docker.nix
│       ├── kubernetes.nix
│       └── shared.nix       # Imports all modules
├── docs/                    # Documentation
│   ├── MODULE_OPTIONS.md    # Auto-generated module reference
│   ├── SECRETS.md           # Secrets management guide
│   ├── BUILD_CACHING.md     # CI/CD caching guide
│   └── VALIDATION.md        # Testing and validation
├── scripts/                 # Automation scripts
│   ├── generate-module-docs.sh
│   ├── validate-modules.sh
│   ├── validate-config.sh
│   └── check-orphaned-modules.sh
├── .github/workflows/       # CI/CD pipelines
├── .sops.yaml              # Sops configuration
└── Makefile                # Helper commands
```

## Initial Setup

### 1. Export CA Certificates

Nix does not use the system truststore, so you need to create a bundle of trusted certificates at `~/.local/ssl/certs/ca-bundle.crt`:

```bash
mkdir -p ~/.local/ssl/certs
security find-certificate -a -p /System/Library/Keychains/SystemRootCertificates.keychain > ~/.local/ssl/certs/ca-bundle.crt
security find-certificate -a -p /Library/Keychains/System.keychain >> ~/.local/ssl/certs/ca-bundle.crt
```

### 2. Clone This Repository

```bash
git clone <repository-url> ~/nix-config
cd ~/nix-config
```

## Usage

After initial setup, use the Makefile commands to manage your configuration:

### Switch to Latest Configuration

```bash
make  # or: make switch
```

### Update Flake Inputs

Update all flake dependencies to their latest versions:

```bash
make update
```

### Format Nix Files

Format all Nix files according to the project style:

```bash
make format
```

### Clean Build Artifacts

Remove build results:

```bash
make clean
```

## Managing Secrets

This repository uses [sops-nix](https://github.com/Mic92/sops-nix) to manage encrypted secrets. See [Secrets Management Guide](docs/SECRETS.md) for detailed instructions.

## Adding a New Host

WIP

## Customization

Modules are organized by function in `modules/darwin/` and `modules/home/`. Many modules support customization through options rather than requiring direct edits.

### Module Options

Several modules have been refactored to use configurable options:

For detailed documentation on available options and usage examples, see [Module Options Documentation](docs/MODULE_OPTIONS.md).

### Quick Example

```nix
# hosts/my-host/users/username/home-configuration.nix
{
  imports = [ inputs.self.homeModules.shared ];

  # Enable specific tools
  dockerTools.enable = true;
  kubernetesTools.enable = true;

  # Configure Git
  customGit = {
    user = {
      name = "Your Name";
      email = "you@example.com";
    };
    signing.enable = true;
  };

  # Customize module options
  customFish.extraAliases = {
    deploy = "make switch";
  };
}
```

## Documentation

- **[Module Options](docs/MODULE_OPTIONS.md)** - Complete reference for all configurable modules (auto-generated)
- **[Secrets Management](docs/SECRETS.md)** - Guide for managing encrypted secrets with sops-nix
- **[Build Caching](docs/BUILD_CACHING.md)** - CI/CD caching setup and optimization
- **[Validation](docs/VALIDATION.md)** - Automated validation and testing guide
- **[Refactoring Summary](docs/REFACTORING_SUMMARY.md)** - Architecture and migration guide
- **[Claude Guide](CLAUDE.md)** - Guide for AI assistants working on this repository

## License

This is free and unencumbered software released into the public domain.

Anyone is free to copy, modify, publish, use, compile, sell, or distribute this software, either in source code form or as a compiled binary, for any purpose, commercial or non-commercial, and by any means.

See the [LICENSE](LICENSE) file for full details or visit <https://unlicense.org>

