# Module Options

This document describes the configurable options available in custom modules.

## Overview

All modules have been refactored to use the NixOS module system with proper options. This allows:
- **Discoverability** - All modules imported by default, see what's available
- **Per-host configuration** - Enable only what you need on each machine
- **No import management** - Just toggle enable flags
- **Type-safe configuration** - Options are validated by Nix
- **Sensible defaults** - Common tools enabled, specialized tools opt-in

## Module Organization

### Home Manager Modules

**Common tools (enabled by default):**
- `customGit` - Git and lazygit
- `customFish` - Fish, Starship, direnv, CLI tools
- `customSsl` - SSL certificate configuration
- `customNeovim` - Neovim text editor
- `customGhostty` - Ghostty terminal
- `jqTools` - JSON processor
- `gnupgTools` - GnuPG encryption
- `sopsTools` - Secrets management

**Development tools (disabled by default, opt-in per host):**
- `dockerTools` - Docker analysis tools
- `kubernetesTools` - kubectl and Helm
- `terraformTools` - Infrastructure as code
- `awsTools` - AWS CLI
- `rustTools` - Rust development
- `bazelTools` - Bazel build system
- `pyenvTools` - Python version manager
- `rcloneTools` - Cloud storage sync
- `claudeCode` - Claude Code CLI
- `customZed` - Zed editor

### Darwin (macOS) System Modules

**System modules (enabled by default):**
- `customFonts` - Font packages (FiraCode Nerd Font)
- `customHomebrew` - Homebrew package management
- `macosDefaults` - macOS system defaults (Dock, Finder, menu bar)
- `macosSecurity` - Security settings (Touch ID for sudo)
- `darwinSops` - SOPS secrets (disabled by default)

## Available Modules

### Home Manager Modules

### customGit

Git configuration with user identity, commit signing, aliases, and lazygit.

**Location:** `modules/home/git.nix`

**Options:**

```nix
customGit = {
  enable = true;  # Enable custom Git configuration

  user = {
    name = "John Doe";  # Git user name for commits
    email = "john.doe@example.com";  # Git user email for commits
  };

  signing = {
    enable = false;  # Enable commit signing (default: false)
    format = "ssh";  # Signing format: ssh, gpg, x509, or openpgp (default: ssh)
    key = null;  # Optional: Signing key (SSH public key path, GPG key ID, or certificate)
    signerPath = null;  # Optional: Custom signing tool path (e.g., 1Password SSH agent)
  };

  aliases = {
    # Custom git aliases (default includes 'changelog')
    changelog = "log --reverse --pretty=format:'%h %s by %aN' --no-merges...";
  };

  extraIgnores = [
    # Additional patterns for global gitignore
    "*.swp"
    ".vscode"
  ];

  enableLazygit = true;  # Enable lazygit terminal UI
};
```

**Example - SSH signing with 1Password:**

```nix
customGit = {
  user = {
    name = "Jane Doe";
    email = "jane@example.com";
  };
  signing = {
    enable = true;
    format = "ssh";
    key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAA...";
    signerPath = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
  };
};
```

**Example - GPG signing:**

```nix
customGit = {
  user = {
    name = "Bob Smith";
    email = "bob@example.com";
  };
  signing = {
    enable = true;
    format = "gpg";
    key = "ABCD1234EF567890";  # Your GPG key ID
  };
};
```

### customFish

Fish shell with Starship prompt, direnv, and command-line tools.

**Location:** `modules/home/fish.nix`

**Options:**

```nix
customFish = {
  enable = true;  # Enable custom shell configuration

  extraAliases = {
    # Additional shell aliases
    ll = "ls -la";
    gs = "git status";
  };

  extraAbbrs = {
    # Additional Fish abbreviations (expand as you type)
    dc = "docker-compose";
    tf = "terraform";
  };

  extraPackages = with pkgs; [
    # Additional packages for shell usage
    ripgrep  # Fast grep alternative
    fd       # Fast find alternative
    tree     # Directory tree viewer
  ];

  bat = {
    enable = true;  # Enable bat (better cat with syntax highlighting) - default: true
  };

  eza = {
    enable = true;  # Enable eza (modern ls replacement) - default: true
  };

  direnv = {
    enable = true;  # Enable direnv for automatic environment loading - default: true
    whitelistPaths = [
      "$HOME/Code"
      "$HOME/Projects"
    ];
  };

  starship = {
    enable = true;  # Enable Starship prompt - default: true
  };

  atuin = {
    enable = true;  # Enable Atuin shell history - default: true
  };
};
```

**Example - Work machine with different paths and extra tools:**

```nix
customFish = {
  enable = true;
  direnv.whitelistPaths = [
    "$HOME/work"
    "$HOME/personal"
  ];
  extraAbbrs = {
    vpn = "company-vpn-command";
  };
  extraPackages = with pkgs; [
    ripgrep  # Better search
    fd       # Better find
  ];
};
```

**Example - Minimal shell without fancy tools:**

```nix
customFish = {
  enable = true;
  bat.enable = false;      # Use standard cat
  eza.enable = false;      # Use standard ls
  starship.enable = false; # Use default Fish prompt
  atuin.enable = false;    # Use standard Fish history
};
```

### customSsl

SSL certificate bundle configuration for Nix and system tools.

**Location:** `modules/home/ssl.nix`

**Options:**

```nix
customSsl = {
  enable = true;  # Enable custom SSL certificate configuration
  certPath = "$HOME/.local/ssl/certs/ca-bundle.crt";
};
```

**Example - Use corporate CA bundle:**

```nix
# In host configuration
customSsl = {
  enable = true;
  certPath = "$HOME/.local/ssl/corporate-ca-bundle.crt";
};
```

### dockerTools

Docker container analysis and security tools.

**Location:** `modules/home/docker.nix`

**Options:**

```nix
dockerTools = {
  enable = true;  # Enable Docker tools

  enableDive = true;    # Image layer explorer
  enableGrype = true;   # Vulnerability scanner (auto-configures to disable updates)
  enableSkopeo = true;  # Image manipulation without daemon
  enableSyft = true;    # SBOM generator (auto-configures to disable updates)
};
```

**Note:** When `enableGrype` or `enableSyft` are enabled, their configuration files are automatically created with `check-for-app-update: false` since updates are managed by Nix.

**Example - Minimal Docker setup:**

```nix
# In host configuration
dockerTools = {
  enable = true;
  enableDive = true;
  enableGrype = false;  # Don't need security scanning
  enableSkopeo = false;
  enableSyft = false;
};
```

### kubernetesTools

Kubernetes CLI tools for container orchestration.

**Location:** `modules/home/kubernetes.nix`

**Options:**

```nix
kubernetesTools = {
  enable = false;  # Enable Kubernetes tools
  enableKubectl = true;  # Enable kubectl CLI
  enableHelm = true;     # Enable Helm package manager
};
```

### terraformTools

Infrastructure as code tool.

**Location:** `modules/home/terraform.nix`

**Options:**

```nix
terraformTools = {
  enable = false;  # Enable Terraform
};
```

### awsTools

AWS command-line interface.

**Location:** `modules/home/awscli.nix`

**Options:**

```nix
awsTools = {
  enable = false;  # Enable AWS CLI
};
```

### customNeovim

Neovim text editor with Catppuccin theme.

**Location:** `modules/home/neovim.nix`

**Options:**

```nix
customNeovim = {
  enable = true;  # Enable Neovim
  setAsDefaultEditor = true;  # Set as EDITOR environment variable
  enableViAlias = true;   # Create 'vi' alias
  enableVimAlias = true;  # Create 'vim' alias
};
```

### customGhostty

Ghostty terminal emulator configuration.

**Location:** `modules/home/ghostty.nix`

**Options:**

```nix
customGhostty = {
  enable = true;  # Enable Ghostty configuration
  fontFamily = "FiraCode Nerd Font Mono";
  windowPadding = 5;  # Padding in pixels
  autoUpdate = "download";  # "off", "check", or "download"
};
```

### gnupgTools

GnuPG encryption and signing tools.

**Location:** `modules/home/gnupg.nix`

**Options:**

```nix
gnupgTools = {
  enable = true;  # Enable GnuPG
};
```

### sopsTools

SOPS secrets management tool.

**Location:** `modules/home/sops.nix`

**Options:**

```nix
sopsTools = {
  enable = true;  # Enable SOPS
};
```

### jqTools

JSON processor for command-line.

**Location:** `modules/home/jq.nix`

**Options:**

```nix
jqTools = {
  enable = true;  # Enable jq
};
```

### rustTools

Rust development tools (rustup).

**Location:** `modules/home/rust.nix`

**Options:**

```nix
rustTools = {
  enable = false;  # Enable Rust toolchain
};
```

### bazelTools

Bazel/Bazelisk build system.

**Location:** `modules/home/bazelisk.nix`

**Options:**

```nix
bazelTools = {
  enable = false;  # Enable Bazelisk
};
```

### pyenvTools

Python version manager.

**Location:** `modules/home/pyenv.nix`

**Options:**

```nix
pyenvTools = {
  enable = false;  # Enable Pyenv
};
```

### rcloneTools

Cloud storage synchronization tool.

**Location:** `modules/home/rclone.nix`

**Options:**

```nix
rcloneTools = {
  enable = false;  # Enable Rclone
};
```

### claudeCode

Claude Code CLI with optional Bedrock configuration using file-based credentials.

**Location:** `modules/home/claude-code.nix`

**Options:**

```nix
claudeCode = {
  enable = false;           # Enable Claude Code
  bedrockUrlPath = null;    # Path to file containing Bedrock base URL
  authTokenPath = null;     # Path to file containing auth token
};
```

**Important:** Credentials are read from files at shell initialization. This allows:
- Using SOPS secrets securely
- Dynamic credential updates without rebuilding
- Keeping sensitive values out of the Nix store

When `bedrockUrlPath` is set, the following environment variables are configured:
- `ANTHROPIC_BEDROCK_BASE_URL` - Read from the file
- `CLAUDE_CODE_USE_BEDROCK=1` - Enables Bedrock integration mode
- `CLAUDE_CODE_SKIP_BEDROCK_AUTH=1` - Skips Bedrock authentication

**Example - Using SOPS secrets:**

```nix
claudeCode = {
  enable = true;
  bedrockUrlPath = config.sops.secrets.claude-code-bedrock-url.path;
  authTokenPath = config.sops.secrets.claude-code-token.path;
};

# Define the secrets
sops.secrets.claude-code-bedrock-url = {};
sops.secrets.claude-code-token = {};
```

**Example - Using plain files:**

```nix
claudeCode = {
  enable = true;
  bedrockUrlPath = /run/secrets/bedrock-url;
  authTokenPath = /run/secrets/auth-token;
};
```

**Example - Standard configuration (no Bedrock):**

```nix
claudeCode = {
  enable = true;
  authTokenPath = config.sops.secrets.claude-code-token.path;
  # No bedrockUrlPath = standard Claude API mode
};
```

### customZed

Zed editor configuration.

**Location:** `modules/home/zed.nix`

**Options:**

```nix
customZed = {
  enable = false;  # Enable Zed editor
  fontFamily = "FiraCode Nerd Font Mono";
  fontSize = 13;      # Buffer font size
  uiFontSize = 15;    # UI font size
  extraExtensions = [];  # Additional extensions
  enableInlineBlame = false;  # Show git blame inline
};
```

**Example - Add extensions:**

```nix
customZed = {
  enable = true;
  extraExtensions = [ "python" "sql" ];
  enableInlineBlame = true;
};
```

### Darwin System Modules

#### customFonts

Font package management for development and terminal use.

**Location:** `modules/darwin/fonts.nix`

**Options:**

```nix
customFonts = {
  enable = true;  # Enable font packages
  packages = [    # Font packages to install
    pkgs.nerd-fonts.fira-code
  ];
};
```

**Example - Add more fonts:**

```nix
customFonts.packages = with pkgs; [
  nerd-fonts.fira-code
  nerd-fonts.jetbrains-mono
  nerd-fonts.hack
];
```

#### customHomebrew

Homebrew package management configuration.

**Location:** `modules/darwin/homebrew.nix`

**Options:**

```nix
customHomebrew = {
  enable = true;  # Enable Homebrew management
  cleanup = "zap";  # "none", "uninstall", or "zap"
  autoUpdate = true;   # Auto-update Homebrew
  autoUpgrade = true;  # Auto-upgrade packages
};
```

**Example - Less aggressive cleanup:**

```nix
customHomebrew.cleanup = "uninstall";  # Don't remove caches/logs
```

#### macosDefaults

macOS system defaults and preferences.

**Location:** `modules/darwin/macos-defaults.nix`

**Options:**

```nix
macosDefaults = {
  enable = true;

  dock = {
    autohide = true;       # Auto-hide dock
    showRecents = false;   # Hide recent apps
  };

  finder = {
    showExtensions = true;      # Show file extensions
    showHiddenFiles = false;    # Hide hidden files
    showDesktopIcons = false;   # No desktop icons
    newWindowTarget = "Computer";  # Default folder
    showPathbar = true;         # Show path breadcrumbs
    showStatusBar = true;       # Show status bar
  };

  menuBar = {
    show24HourClock = true;  # 24-hour format
    showDate = true;         # Show date
    showSeconds = true;      # Show seconds
  };

  screensaver = {
    askForPassword = true;   # Require password after screensaver
  };
};
```

**Example - Show hidden files:**

```nix
macosDefaults.finder.showHiddenFiles = true;
```

#### macosSecurity

macOS security configuration.

**Location:** `modules/darwin/security.nix`

**Options:**

```nix
macosSecurity = {
  enable = true;  # Enable security settings
  touchIdForSudo = true;    # Use Touch ID for sudo
  touchIdReattach = true;   # Work in tmux/screen
};
```

**Example - Disable Touch ID:**

```nix
macosSecurity.touchIdForSudo = false;
```

#### darwinSops

SOPS secrets management for darwin.

**Location:** `modules/darwin/sops.nix`

**Options:**

```nix
darwinSops = {
  enable = false;  # Enable SOPS for darwin
};
```

## Usage Patterns

### Default Configuration

All modules are imported in `modules/home/shared.nix` with sensible defaults:

**Common tools (enabled):**
```nix
customGit.enable = lib.mkDefault true;
customFish.enable = lib.mkDefault true;
customSsl.enable = lib.mkDefault true;
customNeovim.enable = lib.mkDefault true;
customGhostty.enable = lib.mkDefault true;
jqTools.enable = lib.mkDefault true;
gnupgTools.enable = lib.mkDefault true;
sopsTools.enable = lib.mkDefault true;
```

**Development tools (disabled, opt-in):**
```nix
dockerTools.enable = lib.mkDefault false;
kubernetesTools.enable = lib.mkDefault false;
terraformTools.enable = lib.mkDefault false;
awsTools.enable = lib.mkDefault false;
# ... etc
```

### Host-Specific Configuration

#### Home Manager Configuration

Simply enable what you need in your home configuration:

```nix
# hosts/my-laptop/users/username/home-configuration.nix
{ inputs, ... }:
{
  imports = [ inputs.self.homeModules.shared ];

  # Enable development tools for this host
  dockerTools.enable = true;
  kubernetesTools.enable = true;
  terraformTools.enable = true;

  # Customize module behavior
  customGit.signing.enable = false;  # No 1Password on this machine
  customFish.extraAliases = {
    deploy = "make switch";
  };
}
```

#### Darwin System Configuration

Customize macOS system settings in your darwin configuration:

```nix
# hosts/my-laptop/darwin-configuration.nix
{ inputs, ... }:
{
  imports = [ inputs.self.darwinModules.shared ];

  # All system modules enabled by default
  # Customize as needed:
  macosDefaults.finder.showHiddenFiles = true;
  macosDefaults.dock.autohide = false;

  customFonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
  ];

  # Homebrew casks for GUI applications
  homebrew.casks = [
    "1password"
    "docker-desktop"
    "visual-studio-code"
  ];
}
```

### Disabling Default Modules

Override default-enabled modules on specific hosts:

```nix
# Disable Neovim on this machine (prefer VSCode)
customNeovim.enable = false;

# Disable Ghostty (use iTerm2 instead)
customGhostty.enable = false;
```

### Mixing Stable and Unstable Packages

All packages come from the stable nixpkgs channel (nixos-25.11) for consistency and reliability.

## Best Practices

1. **Don't Edit Module Files:** Override options in host configurations instead
2. **Use Defaults:** Only override what you need to change
3. **Document Overrides:** Add comments explaining why you're overriding defaults
4. **Test Changes:** Run `nix build` before `make switch` to catch errors early

## Adding New Options

When adding new options to modules:

1. Use `lib.mkEnableOption` for boolean enable flags
2. Use `lib.mkOption` with proper types for other values
3. Provide sensible defaults that match current behavior
4. Add description strings for documentation
5. Wrap config in `lib.mkIf cfg.enable { ... }`

Example:

```nix
{ config, lib, ... }:
let
  cfg = config.myModule;
in
{
  options.myModule = {
    enable = lib.mkEnableOption "my custom module";

    myOption = lib.mkOption {
      type = lib.types.str;
      default = "default-value";
      description = "What this option does";
    };
  };

  config = lib.mkIf cfg.enable {
    # Module configuration here
  };
}
```
