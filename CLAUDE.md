# Claude Guide for nix-config

This document provides guidance for Claude (or any AI assistant) when working on this Nix configuration repository.

## Project Overview

This is a declarative system configuration using:
- **nix-darwin** for macOS system configuration
- **home-manager** for user environment management
- **sops-nix** for secrets management
- **Blueprint** for modular configuration structure
- **Catppuccin** theming across all applications

## Architecture

### Module System

All modules use the **NixOS module system** with enable/disable options:

```nix
{ config, lib, pkgs, ... }:
let
  cfg = config.moduleName;
in
{
  options.moduleName = {
    enable = lib.mkEnableOption "description";
    # Additional options...
  };

  config = lib.mkIf cfg.enable {
    # Configuration here
  };
}
```

**Key principle:** All modules are imported in their respective `shared.nix` files:
- Home Manager modules in `modules/home/shared.nix`
- Darwin system modules in `modules/darwin/shared.nix`

Users enable/disable per host, not via selective imports.

### Directory Structure

```
.
├── flake.nix              # Main flake with inputs
├── hosts/                 # Per-host configurations
│   ├── personal/
│   │   ├── darwin-configuration.nix    # macOS system config
│   │   └── users/
│   │       └── dosten/
│   │           └── home-configuration.nix  # User config
│   └── work/
│       ├── darwin-configuration.nix
│       └── users/
│           └── dsaintesteben/
│               └── home-configuration.nix
├── modules/
│   ├── darwin/            # macOS system modules
│   │   ├── fonts.nix
│   │   ├── homebrew.nix
│   │   ├── macos-defaults.nix
│   │   ├── security.nix
│   │   ├── shared.nix     # Imports all darwin modules
│   │   └── sops.nix
│   └── home/              # Home-manager modules
│       ├── shared.nix     # Imports ALL home modules
│       ├── git.nix        # customGit module
│       ├── fish.nix       # customFish module
│       ├── docker.nix     # dockerTools module
│       └── ...            # 17 more modules
├── docs/
│   ├── MODULE_OPTIONS.md  # Complete module reference
│   ├── REFACTORING_SUMMARY.md
│   └── VALIDATION.md      # Validation guide
├── scripts/
│   ├── check-orphaned-modules.sh
│   ├── validate-modules.sh
│   └── validate-config.sh
├── .github/workflows/     # CI validation
├── secrets/               # Encrypted secrets (sops)
│   └── default.yaml       # Default secrets file (encrypted with sops)
├── formatter.nix          # Treefmt configuration
├── treefmt.toml           # Formatter settings
├── devshell.nix           # Development shell
├── Makefile               # Common operations
└── CLAUDE.md              # This file - AI assistant guide
```

## Module Naming Conventions

### Home Manager Modules

| Module File | Option Name | Category |
|------------|-------------|----------|
| git.nix | `customGit` | Common (enabled by default) |
| fish.nix | `customFish` | Common |
| docker.nix | `dockerTools` | Development (disabled by default) |
| kubernetes.nix | `kubernetesTools` | Development |
| neovim.nix | `customNeovim` | Common |

**Pattern:**
- Tools with "Tools" suffix: `dockerTools`, `kubernetesTools`, `jqTools`
- Apps with "custom" prefix: `customGit`, `customFish`, `customZed`

### Darwin (macOS) System Modules

| Module File | Option Name | Category |
|------------|-------------|----------|
| fonts.nix | `customFonts` | System (enabled by default) |
| homebrew.nix | `customHomebrew` | System (enabled by default) |
| macos-defaults.nix | `macosDefaults` | System (enabled by default) |
| security.nix | `macosSecurity` | System (enabled by default) |
| sops.nix | `darwinSops` | System (disabled by default) |

**Pattern:**
- System with "custom" or "macos" prefix
- All darwin modules in `modules/darwin/`

## Common Workflows

### Making Changes

1. **Edit module files** in `modules/home/` or `modules/darwin/`
2. **Test build**: `make build`
3. **Apply changes**: `make`
4. **Format code**: `nix fmt` (run once at the end to avoid duplicated work)
5. **Update documentation**: If your changes are significant, update `CLAUDE.md` to reflect new patterns or workflows

### Adding a New Module

1. **Create module file** (e.g., `modules/home/newtool.nix`):
   ```nix
   { config, lib, pkgs, ... }:
   let
     cfg = config.newTool;
   in
   {
     options.newTool = {
       enable = lib.mkEnableOption "description of tool";
     };

     config = lib.mkIf cfg.enable {
       home.packages = with pkgs; [ newtool ];
     };
   }
   ```

2. **Import in shared.nix**:
   ```nix
   # modules/home/shared.nix
   imports = [
     # ... existing imports
     inputs.self.homeModules.newtool
   ];

   # Set default (enable or disable)
   newTool.enable = lib.mkDefault false;
   ```

3. **Document in MODULE_OPTIONS.md**

4. **Test build**

### Enabling Features Per Host

#### Home Manager Configuration

In user configuration (e.g., `hosts/work/users/dsaintesteben/home-configuration.nix`):

```nix
{ inputs, ... }:
{
  imports = [ inputs.self.homeModules.shared ];

  # Enable development tools
  dockerTools.enable = true;
  kubernetesTools.enable = true;

  # Customize behavior
  customGit.signing.enable = true;
  customFish.extraAbbrs = {
    k = "kubectl";
  };
}
```

#### Darwin System Configuration

In darwin configuration (e.g., `hosts/work/darwin-configuration.nix`):

```nix
{ inputs, ... }:
{
  imports = [ inputs.self.darwinModules.shared ];

  # All system modules enabled by default
  # Customize as needed
  macosDefaults.finder.showHiddenFiles = true;
  macosDefaults.dock.autohide = false;

  # Add more fonts
  customFonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
  ];
}
```

## Important Guidelines

### Formatting

- **ALWAYS run `nix fmt` once at the end after editing Nix files**
- Running it once at the end avoids duplicated work
- Formats with `nixfmt` and applies `keep-sorted` markers
- CI will fail if formatting is incorrect
- Do NOT use `make format` - always use `nix fmt` directly

### Keep-Sorted Blocks

Code between `# keep-sorted start` and `# keep-sorted end` is auto-sorted:

```nix
imports = [
  # keep-sorted start
  inputs.self.homeModules.awscli
  inputs.self.homeModules.docker
  inputs.self.homeModules.git
  # keep-sorted end
];
```

**Don't mention `nix fmt` or keep-sorted in inline comments** - these are implementation details.

### Module Defaults

- All enable options use `lib.mkEnableOption` (defaults to `false`)
- Set defaults in `shared.nix` using `lib.mkDefault`:
  ```nix
  # Top-level module
  customGit.enable = lib.mkDefault true;

  # Sub-options within a module
  customFish.bat.enable = lib.mkDefault true;
  customFish.eza.enable = lib.mkDefault true;
  ```
- This allows host configs to override without `lib.mkForce`
- Common tools default to `true`, development tools default to `false`

### Documentation

When adding features, update:
1. Inline comments explaining **why**, not just what
2. `docs/MODULE_OPTIONS.md` with complete option reference
3. `README.md` if it affects user-facing workflows

### Common Tools vs Development Tools

**Common tools (enabled by default):**
- Essential for all machines: git, shell, neovim, terminal
- Security tools: gnupg, sops, ssl

**Development tools (disabled by default, opt-in):**
- Specialized for development work: docker, kubernetes, terraform
- Language-specific: rust, pyenv, bazel
- IDE/editors: zed, claude-code

## Testing

### Local Build Test

```bash
# Test current host (recommended)
make build

# Test with trace for debugging
make build TRACE=1

# Test specific host manually
nix build ".#darwinConfigurations.work.system"
```

### Check for Issues

```bash
# Check formatting (run once at the end)
nix fmt

# Validate module structure
./scripts/validate-modules.sh

# Validate configuration files
./scripts/validate-config.sh

# Check for orphaned modules
./scripts/check-orphaned-modules.sh

# Lint Nix files (optional, for additional checks)
nix run nixpkgs#statix -- check .
nix run nixpkgs#deadnix -- .
```

### CI Validation

GitHub Actions run on every PR:
- Format checking
- Build all host configurations
- Lint with statix/deadnix
- Check for orphaned modules
- Validate module structure
- Validate configuration files

See [docs/VALIDATION.md](docs/VALIDATION.md) for detailed validation documentation.

## Common Patterns

### Conditional Configuration

```nix
# Platform-specific
home.packages = lib.optionals pkgs.stdenv.isDarwin [
  darwin-specific-package
];

# Option-based
programs.lazygit = lib.mkIf cfg.enableLazygit {
  enable = true;
};
```

### Merging Options

```nix
# Merge with defaults
shellAliases = {
  cat = "bat";
} // cfg.extraAliases;

# Concatenate lists
home.packages = basePackages
  ++ lib.optional cfg.enableExtra extraPackage;
```

### Environment Variables

```nix
home.sessionVariables = {
  EDITOR = "nvim";
  SSL_CERT_FILE = cfg.certPath;
};
```

## Troubleshooting

### Build Errors

1. **Check syntax**: `nix flake check`
2. **Show trace**: Add `--show-trace` to build command
3. **Option conflicts**: Use `lib.mkDefault` in shared.nix
4. **Missing imports**: Ensure module is in shared.nix imports

### Module Not Found

Check `modules/home/shared.nix` has the import:
```nix
inputs.self.homeModules.yourmodule
```

### Options Don't Override

In `shared.nix`, use `lib.mkDefault`:
```nix
# Good
customGit.enable = lib.mkDefault true;

# Bad - can't be overridden
customGit.enable = true;
```

## Reference Documentation

- **Module Options**: See `docs/MODULE_OPTIONS.md`
- **Refactoring Guide**: See `docs/REFACTORING_SUMMARY.md`
- **Validation Guide**: See `docs/VALIDATION.md`
- **User Guide**: See `README.md`
- **Nix Language**: https://nix.dev/manual/nix/2.18/language/
- **Home Manager Options**: https://nix-community.github.io/home-manager/options.xhtml
- **nix-darwin Options**: https://daiderd.com/nix-darwin/manual/index.html

## Quick Reference

### Makefile Commands

```bash
make                  # Build and activate configuration (default)
make build            # Test build without activating
make update           # Update all flake inputs
make clean            # Remove build artifacts
```

**Note:** Use `nix fmt` directly for formatting (not `make format`).

### Flake Structure

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-25.11";
    home-manager.url = "github:nix-community/home-manager/release-25.11";
    sops-nix.url = "github:Mic92/sops-nix";
    catppuccin.url = "github:catppuccin/nix/release-25.11";
    blueprint.url = "github:numtide/blueprint";
  };

  outputs = inputs: inputs.blueprint { inherit inputs; };
}
```

## Best Practices

1. ✅ **Always format once at the end**: `nix fmt` (not `make format`)
2. ✅ **Test builds before committing**: `make build`
3. ✅ **Run validation scripts**: `./scripts/validate-modules.sh && ./scripts/validate-config.sh`
4. ✅ **Use lib.mkDefault** for defaults in shared.nix
5. ✅ **Document inline** with comments explaining why
6. ✅ **Update docs** when adding features (including `CLAUDE.md` for workflow changes)
7. ✅ **Keep modules small** and focused on one tool/feature
8. ✅ **Use options** for configurability, not hardcoded values
9. ✅ **Follow naming conventions** (customX, XTools)

## Don'ts

1. ❌ Don't mention `nix fmt` or keep-sorted in inline code comments
2. ❌ Don't use selective imports (use enable flags)
3. ❌ Don't hardcode paths (make them configurable)
4. ❌ Don't commit without formatting: `nix fmt`
5. ❌ Don't create modules without options
6. ❌ Don't skip documentation updates (including `CLAUDE.md`)
7. ❌ Don't use `lib.mkForce` in shared.nix (use `lib.mkDefault`)
8. ❌ Don't use `make format` (use `nix fmt` directly)

---

**Last Updated**: After major refactoring implementing enable/disable pattern for all modules.
