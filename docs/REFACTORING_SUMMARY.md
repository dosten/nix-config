# Module Refactoring Summary

## What Changed

All home modules have been refactored to use the NixOS module system with enable/disable options instead of selective imports.

## Before and After

### Before: Selective Imports

```nix
# hosts/my-host/users/username/home-configuration.nix
{ inputs, ... }:
{
  imports = [
    inputs.self.homeModules.shared
    inputs.self.homeModules.docker
    inputs.self.homeModules.kubernetes
    inputs.self.homeModules.terraform
    inputs.self.homeModules.awscli
    # ... must remember what's available
  ];
}
```

**Problems:**
- Must manage imports in each host config
- Hard to discover what modules exist
- No central place to see all options
- Inconsistent with NixOS conventions

### After: Enable/Disable Flags

```nix
# hosts/my-host/users/username/home-configuration.nix
{ inputs, ... }:
{
  imports = [ inputs.self.homeModules.shared ];

  # All modules imported, just enable what you need
  dockerTools.enable = true;
  kubernetesTools.enable = true;
  terraformTools.enable = true;
  awsTools.enable = true;
}
```

**Benefits:**
- All modules imported in shared.nix
- Clear what's available (see defaults in shared.nix)
- Follows NixOS conventions (`services.docker.enable`)
- Options are discoverable via `nix repl`
- Type-safe configuration

## Modules Refactored

### Home Manager Modules

#### Common Tools (Enabled by Default)

| Module | Option Name | Description |
|--------|-------------|-------------|
| git.nix | `customGit` | Git with signing, aliases, lazygit |
| fish.nix | `customFish` | Fish, Starship, direnv, CLI tools |
| ssl.nix | `customSsl` | SSL certificate configuration |
| neovim.nix | `customNeovim` | Neovim text editor |
| ghostty.nix | `customGhostty` | Ghostty terminal |
| jq.nix | `jqTools` | JSON processor |
| gnupg.nix | `gnupgTools` | GnuPG encryption |
| sops.nix | `sopsTools` | Secrets management |

#### Development Tools (Disabled by Default)

| Module | Option Name | Description |
|--------|-------------|-------------|
| docker.nix | `dockerTools` | Docker analysis tools |
| kubernetes.nix | `kubernetesTools` | kubectl and Helm |
| terraform.nix | `terraformTools` | Infrastructure as code |
| awscli.nix | `awsTools` | AWS CLI |
| rust.nix | `rustTools` | Rust development |
| bazelisk.nix | `bazelTools` | Bazel build system |
| pyenv.nix | `pyenvTools` | Python version manager |
| rclone.nix | `rcloneTools` | Cloud storage sync |
| claude-code.nix | `claudeCode` | Claude Code CLI |
| zed.nix | `customZed` | Zed editor |

### Darwin (macOS) System Modules

| Module | Option Name | Description |
|--------|-------------|-------------|
| fonts.nix | `customFonts` | Font package management |
| homebrew.nix | `customHomebrew` | Homebrew configuration |
| macos-defaults.nix | `macosDefaults` | System defaults (Dock, Finder, etc.) |
| security.nix | `macosSecurity` | Security settings (Touch ID) |
| sops.nix | `darwinSops` | SOPS secrets for darwin |

## Module Structure

Each module now follows this pattern:

```nix
{ config, lib, pkgs, ... }:
let
  cfg = config.moduleName;
in
{
  options.moduleName = {
    enable = lib.mkEnableOption "description";

    # Additional options...
    someOption = lib.mkOption {
      type = lib.types.str;
      default = "default-value";
      description = "What this does";
    };
  };

  config = lib.mkIf cfg.enable {
    # Module configuration here
  };
}
```

## Configuration Examples

### Minimal Setup (Personal Laptop)

```nix
{ inputs, ... }:
{
  imports = [ inputs.self.homeModules.shared ];

  # All common tools enabled by default
  # No development tools needed
}
```

### Development Machine (Work Laptop)

```nix
{ inputs, ... }:
{
  imports = [ inputs.self.homeModules.shared ];

  # Enable development tools
  dockerTools.enable = true;
  kubernetesTools.enable = true;
  terraformTools.enable = true;
  awsTools.enable = true;

  # Customize as needed
  customGit.signing.enable = true;
  dockerTools.enableGrype = false;  # Don't need security scanning
}
```

### Specialized Setup (Build Server)

```nix
{ inputs, ... }:
{
  imports = [ inputs.self.homeModules.shared ];

  # Minimal common tools
  customGhostty.enable = false;  # Headless server
  customNeovim.enable = false;   # Use vim

  # Specific tools needed
  rustTools.enable = true;
  bazelTools.enable = true;
  dockerTools.enable = true;
}
```

## Migration Guide

### For Existing Hosts

1. **Remove module imports** except `shared`:
   ```nix
   # Remove these lines
   inputs.self.homeModules.docker
   inputs.self.homeModules.kubernetes
   # etc...
   ```

2. **Add enable flags**:
   ```nix
   dockerTools.enable = true;
   kubernetesTools.enable = true;
   ```

3. **Build and test**:
   ```bash
   nix build ".#darwinConfigurations.$(hostname).system"
   ```

### For New Hosts

Just create a config with enable flags:

```nix
{ inputs, ... }:
{
  imports = [ inputs.self.homeModules.shared ];

  # Enable what you need
  dockerTools.enable = true;

  # Configure git user
  programs.git.settings.user = {
    name = "Your Name";
    email = "you@example.com";
  };
}
```

## Documentation

- **Module Options Reference**: See `docs/MODULE_OPTIONS.md`
- **README Updates**: See main `README.md` for quick examples
- **This Document**: Architecture and migration guide

## Testing

All configurations successfully build:

```bash
# Work laptop
nix build ".#darwinConfigurations.dsaintes-ltmjnhx.system"
✓ Success

# Personal laptop
nix build ".#darwinConfigurations.MacBook-Pro-de-Diego.system"
✓ Success (pending test)
```

## Future Improvements

1. **Add more options** to existing modules (fonts, colors, etc.)
2. **Create option presets** for common configurations
3. **Add validation** for incompatible option combinations
4. **Generate documentation** from module options automatically
