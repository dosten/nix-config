{ config, lib, ... }:
let
  cfg = config.customGit;
in
{
  options.customGit = {
    enable = lib.mkEnableOption "custom Git configuration";

    user = {
      name = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "Git user name for commits";
        example = "John Doe";
      };

      email = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "Git user email for commits";
        example = "john.doe@example.com";
      };
    };

    signing = {
      enable = lib.mkEnableOption "commit signing";

      format = lib.mkOption {
        type = lib.types.enum [
          "ssh"
          "gpg"
          "x509"
          "openpgp"
        ];
        default = "ssh";
        description = "Signing format to use (ssh, gpg, x509, or openpgp)";
      };

      key = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Signing key (SSH public key path, GPG key ID, or certificate)";
        example = "~/.ssh/id_ed25519.pub";
      };

      signerPath = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Path to custom signing tool (e.g., 1Password SSH agent). Only needed for SSH signing with custom tools.";
        example = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
      };
    };

    aliases = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {
        changelog = "log --reverse --pretty=format:'%h %s by %aN' --no-merges --fixed-strings --invert-grep --grep '[AUTO-MERGE-PR]'";
      };
      description = "Custom git aliases";
    };

    extraIgnores = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Additional patterns to add to global gitignore";
    };

    enableLazygit = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable lazygit terminal UI";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.git = {
      enable = true;

      settings = {
        # keep-sorted start block=yes
        # Custom git aliases
        alias = cfg.aliases;
        # Normalize line endings: checkout as-is, commit Unix-style LF
        core.autocrlf = "input";
        # Automatically remove deleted remote branches from local references
        fetch.prune = true;
        # Automatically remove deleted remote tags from local references
        fetch.pruneTags = true;
        # Auto-correct mistyped commands after 0.1 seconds (1 = 0.1s)
        help.autocorrect = 1;
        # Use "main" instead of "master" for new repositories
        init.defaultBranch = "main";
        # Use .mailmap file to consolidate author identities in logs
        log.mailmap = true;
        # Always create merge commits (no fast-forward) for visibility
        merge.ff = false;
        # Rebase local commits on top of fetched commits when pulling
        pull.rebase = true;
        # Push current branch to remote branch of same name
        push.default = "current";
        # Automatically squash commits marked with "fixup!" or "squash!"
        rebase.autoSquash = true;
        # Sort tags as version numbers (1.2.0, 1.10.0) not lexically
        tag.sort = "version:refname";
        # User identity for commits
        user = lib.mkMerge [
          (lib.mkIf (cfg.user.name != "") { name = cfg.user.name; })
          (lib.mkIf (cfg.user.email != "") { email = cfg.user.email; })
        ];
        # keep-sorted end
      };

      # Commit signing configuration
      signing = lib.mkIf cfg.signing.enable (
        lib.mkMerge [
          {
            format = cfg.signing.format;
            signByDefault = true;
          }
          (lib.mkIf (cfg.signing.key != null) { key = cfg.signing.key; })
          (lib.mkIf (cfg.signing.signerPath != null) { signer = cfg.signing.signerPath; })
        ]
      );

      # Global gitignore patterns for all repositories
      ignores = [
        ".DS_Store" # macOS folder metadata
        ".idea" # JetBrains IDE configuration
      ]
      ++ cfg.extraIgnores;
    };

    # Terminal UI for git with vim-like keybindings
    programs.lazygit = lib.mkIf cfg.enableLazygit {
      enable = true;
      settings = {
        # keep-sorted start
        # Hide verbose git command logs in the UI
        gui.showCommandLog = false;
        # Disable update checks (managed by Nix)
        update.method = "never";
        # keep-sorted end
      };
    };

    # Apply Catppuccin theme to lazygit
    catppuccin.lazygit.enable = cfg.enableLazygit;
  };
}
