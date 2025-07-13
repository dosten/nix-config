# Darwin Modules Refactoring

## Overview

All darwin (macOS) system modules have been refactored to use the NixOS module system with enable/disable options, matching the pattern used for home-manager modules.

## Modules Converted

### customFonts (modules/darwin/fonts.nix)

**Before:**
```nix
{ pkgs, ... }:
{
  fonts.packages = with pkgs; [ nerd-fonts.fira-code ];
}
```

**After:**
```nix
{ config, lib, pkgs, ... }:
let
  cfg = config.customFonts;
in
{
  options.customFonts = {
    enable = lib.mkEnableOption "custom font packages";
    packages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = with pkgs; [ nerd-fonts.fira-code ];
      description = "Font packages to install";
    };
  };

  config = lib.mkIf cfg.enable {
    fonts.packages = cfg.packages;
  };
}
```

**Benefits:**
- Can disable font installation entirely
- Easy to add more fonts per host
- Configurable default font list

### customHomebrew (modules/darwin/homebrew.nix)

**Options added:**
- `enable` - Enable Homebrew management
- `cleanup` - Cleanup behavior ("none", "uninstall", "zap")
- `autoUpdate` - Auto-update Homebrew itself
- `autoUpgrade` - Auto-upgrade packages

**Benefits:**
- Can disable Homebrew management
- Configurable cleanup strategy per host
- Control update behavior

### macosDefaults (modules/darwin/macos-defaults.nix)

**Structured options for:**
- **Dock:** autohide, showRecents
- **Finder:** showExtensions, showHiddenFiles, showDesktopIcons, newWindowTarget, showPathbar, showStatusBar
- **Menu Bar:** show24HourClock, showDate, showSeconds
- **Screensaver:** askForPassword

**Benefits:**
- Granular control over each setting
- Clear documentation of what each option does
- Easy to override per host
- Type-safe configuration

### macosSecurity (modules/darwin/security.nix)

**Options added:**
- `enable` - Enable security configuration
- `touchIdForSudo` - Enable Touch ID for sudo
- `touchIdReattach` - Allow Touch ID in tmux/screen

**Benefits:**
- Can disable Touch ID per host
- Configurable reattach behavior
- Clear security settings

### darwinSops (modules/darwin/sops.nix)

**Options added:**
- `enable` - Enable SOPS for darwin

**Benefits:**
- Ready for future darwin secrets configuration
- Consistent with home-manager sops module
- Disabled by default (opt-in)

## Configuration Changes

### modules/darwin/shared.nix

**Before:**
```nix
{ inputs, ... }:
{
  imports = [
    inputs.self.darwinModules.fonts
    inputs.self.darwinModules.homebrew
    inputs.self.darwinModules.macos-defaults
    inputs.self.darwinModules.security
    inputs.sops-nix.darwinModules.sops
  ];

  # System configuration
  system.stateVersion = 6;
  nix.enable = false;
  nixpkgs.config.allowUnfree = true;
}
```

**After:**
```nix
{ inputs, lib, ... }:
{
  imports = [
    # All darwin modules imported here
    inputs.self.darwinModules.fonts
    inputs.self.darwinModules.homebrew
    inputs.self.darwinModules.macos-defaults
    inputs.self.darwinModules.security
    inputs.self.darwinModules.sops
    inputs.sops-nix.darwinModules.sops
  ];

  # System configuration
  system.stateVersion = 6;
  nix.enable = false;
  nixpkgs.config.allowUnfree = true;

  # Enable system modules by default
  customFonts.enable = lib.mkDefault true;
  customHomebrew.enable = lib.mkDefault true;
  macosDefaults.enable = lib.mkDefault true;
  macosSecurity.enable = lib.mkDefault true;
  darwinSops.enable = lib.mkDefault false;  # Opt-in
}
```

### Host Darwin Configurations

**Before:**
```nix
{ inputs, ... }:
{
  imports = [
    inputs.self.darwinModules.shared
  ];

  nixpkgs.hostPlatform = "aarch64-darwin";
  users.users.username = { home = "/Users/username"; };
  system.primaryUser = "username";

  homebrew.casks = [ "1password" "docker-desktop" ];
}
```

**After:**
```nix
{ inputs, ... }:
{
  imports = [ inputs.self.darwinModules.shared ];

  nixpkgs.hostPlatform = "aarch64-darwin";
  users.users.username = { home = "/Users/username"; };
  system.primaryUser = "username";

  # All system modules enabled by default
  # Override here if needed:
  # macosDefaults.dock.autohide = false;
  # customFonts.packages = [ ... ];

  homebrew.casks = [ "1password" "docker-desktop" ];
}
```

## Usage Examples

### Customize macOS Defaults

```nix
# Show hidden files in Finder
macosDefaults.finder.showHiddenFiles = true;

# Disable dock autohide
macosDefaults.dock.autohide = false;

# Show 12-hour clock instead of 24-hour
macosDefaults.menuBar.show24HourClock = false;
```

### Add More Fonts

```nix
customFonts.packages = with pkgs; [
  nerd-fonts.fira-code
  nerd-fonts.jetbrains-mono
  nerd-fonts.hack
];
```

### Change Homebrew Behavior

```nix
# Less aggressive cleanup (keep caches)
customHomebrew.cleanup = "uninstall";

# Disable auto-updates
customHomebrew.autoUpdate = false;
customHomebrew.autoUpgrade = false;
```

### Disable Touch ID for Sudo

```nix
macosSecurity.touchIdForSudo = false;
```

### Disable System Module

```nix
# Don't manage fonts via Nix
customFonts.enable = false;

# Disable Homebrew management
customHomebrew.enable = false;
```

## Benefits Achieved

1. **Consistency** - Darwin modules now match home-manager module pattern
2. **Discoverability** - All modules visible in shared.nix
3. **Granular Control** - Individual settings configurable per host
4. **Type Safety** - Options validated by module system
5. **Documentation** - Each option has description
6. **Flexibility** - Easy to override defaults
7. **Maintainability** - Clear structure and patterns

## Testing

Configuration successfully builds:

```bash
nix build ".#darwinConfigurations.dsaintes-ltmjnhx.system"
✓ Success
```

All system modules work with new options pattern.

## Migration Notes

Existing host configurations continue to work without changes because:
- All modules are imported in shared.nix with defaults
- Default behavior matches previous hardcoded behavior
- Options can be gradually adopted per host

## Future Improvements

1. **Add more macOS settings** to macosDefaults (trackpad, keyboard, etc.)
2. **Create option presets** for common configurations (developer, minimal, etc.)
3. **Add validation** for incompatible option combinations
4. **Generate docs** from module options automatically
5. **Add more security options** (firewall, FileVault, etc.)
