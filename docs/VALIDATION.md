# Configuration Validation

This document describes the validation tools and checks used to ensure the quality and correctness of the nix-config repository.

## Overview

The repository includes automated validation to catch common issues:

1. **Module Structure Validation** - Ensures modules follow conventions
2. **Configuration Validation** - Checks configuration files for issues
3. **Orphaned Module Detection** - Finds modules not imported anywhere
4. **Linting** - Static analysis with statix and deadnix
5. **Build Validation** - Ensures all host configurations build successfully

## Validation Scripts

### Module Validation (`scripts/validate-modules.sh`)

Validates that all modules follow the project's structure and conventions.

**Checks performed:**

1. **Enable options** - All modules have `mkEnableOption`
2. **Option types** - All `mkOption` declarations include type specifications
3. **Documentation** - All modules are documented in `MODULE_OPTIONS.md`
4. **Descriptions** - All options have description strings
5. **Conditional config** - Modules use `lib.mkIf` for conditional configuration
6. **Naming conventions** - Module names follow `customX` or `XTools` patterns

**Usage:**

```bash
./scripts/validate-modules.sh
```

**Example output:**

```
=== Module Validation Suite ===

Check 1: Verifying all modules have enable options
  ✓ modules/home/git.nix: Has enable option
  ✓ modules/home/docker.nix: Has enable option
  ...

=== Validation Summary ===
✓ All checks passed!
```

### Configuration Validation (`scripts/validate-config.sh`)

Validates configuration files for common issues and best practices.

**Checks performed:**

1. **Required options** - Git user identity configured in host configs
2. **Conflicting options** - Detects use of `lib.mkForce` (indicates conflicts)
3. **lib.mkDefault usage** - Ensures shared.nix uses `lib.mkDefault` for defaults
4. **Module imports** - Verifies all modules imported in shared.nix
5. **Shared module imports** - Host configs import shared modules
6. **Sops configuration** - Validates secrets configuration when used
7. **Module dependencies** - Checks dependencies between modules

**Usage:**

```bash
./scripts/validate-config.sh
```

**Example output:**

```
=== Configuration Validation Suite ===

Check 1: Checking for required options in host configs
  ✓ hosts/work/users/dsaintesteben/home-configuration.nix: Git user configured
  ✓ hosts/work/users/dsaintesteben/home-configuration.nix: Git signing configured with key

=== Validation Summary ===
✓ All configuration checks passed!
```

### Orphaned Module Detection (`scripts/check-orphaned-modules.sh`)

Finds module files that are not imported anywhere in the codebase.

**Usage:**

```bash
./scripts/check-orphaned-modules.sh
```

## Running All Validations Locally

Before committing changes, run all validation checks:

```bash
# Check formatting
nix fmt

# Validate modules
./scripts/validate-modules.sh

# Validate configuration
./scripts/validate-config.sh

# Check for orphaned modules
./scripts/check-orphaned-modules.sh

# Lint Nix files
nix run nixpkgs#statix -- check .
nix run nixpkgs#deadnix -- --fail .

# Test build
make build
```

Or run a comprehensive check:

```bash
# Format, validate, and test build
nix fmt && \
  ./scripts/validate-modules.sh && \
  ./scripts/validate-config.sh && \
  ./scripts/check-orphaned-modules.sh && \
  make build
```

## CI/CD Validation

All validation checks run automatically on:
- Pull requests
- Pushes to main branch
- Manual workflow dispatch

**GitHub Actions workflows:**

- `.github/workflows/validate.yaml` - Main validation workflow
  - Build all host configurations
  - Run linting (statix, deadnix)
  - Check for orphaned modules
  - Validate module structure
  - Validate configuration files
- `.github/workflows/check-format.yaml` - Formatting validation

## Adding New Validation Checks

### To add a check to an existing script:

1. Add a new check section in the script
2. Use consistent color codes (GREEN, YELLOW, RED, BLUE)
3. Increment ERRORS or WARNINGS counters appropriately
4. Add documentation about the new check below

### To create a new validation script:

1. Create the script in `scripts/`
2. Make it executable: `chmod +x scripts/your-script.sh`
3. Add to CI workflow in `.github/workflows/validate.yaml`
4. Document in this file

## Validation Best Practices

### For Module Authors

- Always include `mkEnableOption` in new modules
- Specify types for all `mkOption` declarations
- Add descriptions to all options
- Use `lib.mkIf cfg.enable` for conditional config
- Document new modules in `MODULE_OPTIONS.md`
- Follow naming conventions: `customX` or `XTools`

### For Configuration Authors

- Use `lib.mkDefault` in shared.nix for all defaults
- Avoid `lib.mkForce` unless absolutely necessary
- Configure Git user identity in host configs
- Set up sops properly when using secrets
- Import shared modules in all host configs

## Troubleshooting

### Module validation fails with "Missing mkEnableOption"

**Problem:** Module doesn't have an enable option.

**Solution:** Add to your module:

```nix
options.yourModule = {
  enable = lib.mkEnableOption "description of your module";
};

config = lib.mkIf cfg.enable {
  # Your configuration here
};
```

### Configuration validation fails with "Uses lib.mkForce"

**Problem:** Your configuration uses `lib.mkForce`, which may indicate an option conflict.

**Solution:**
1. Check if you can remove `lib.mkForce` by changing the default in shared.nix to use `lib.mkDefault`
2. If truly needed, document why in a comment

### Module not found in MODULE_OPTIONS.md

**Problem:** New module isn't documented.

**Solution:** Add documentation for your module in `docs/MODULE_OPTIONS.md` following the existing format.

### Orphaned module detected

**Problem:** Module file exists but isn't imported.

**Solution:**
1. Add to appropriate shared.nix: `inputs.self.{home,darwin}Modules.yourmodule`
2. Set default enable state: `yourModule.enable = lib.mkDefault false;`

## Exit Codes

All validation scripts use standard exit codes:

- `0` - All checks passed
- `1` - Validation failed (errors found)

Warnings alone don't cause failures (exit code 0).

## Extending Validation

To add more sophisticated validation, consider:

1. **Type-level validation** - Add assertions in module definitions using `lib.mkAssert`
2. **Integration tests** - Test that enabled modules actually work
3. **Security scanning** - Add tools like vulnix for vulnerability scanning
4. **Automated fixes** - Scripts that can auto-fix common issues

See the main [CLAUDE.md](../CLAUDE.md) guide for more improvement ideas.
