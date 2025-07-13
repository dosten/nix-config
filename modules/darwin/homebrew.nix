{ config, lib, ... }:
let
  cfg = config.customHomebrew;
in
{
  options.customHomebrew = {
    enable = lib.mkEnableOption "Homebrew";

    cleanup = lib.mkOption {
      type = lib.types.enum [
        "none"
        "uninstall"
        "zap"
      ];
      default = "zap";
      description = ''
        Cleanup behavior on activation:
        - none: Keep all packages
        - uninstall: Remove packages not in config
        - zap: Remove packages and all associated files (caches, logs, etc.)
      '';
    };

    autoUpdate = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Automatically update Homebrew itself during activation";
    };

    autoUpgrade = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Automatically upgrade installed packages to latest versions";
    };
  };

  config = lib.mkIf cfg.enable {
    # Enable Homebrew package management via nix-darwin.
    # Allows declarative management of Homebrew casks and formulae.
    homebrew = {
      enable = true;

      # Activation behavior: cleanup, updates, and upgrades
      onActivation = {
        cleanup = cfg.cleanup;
        autoUpdate = cfg.autoUpdate;
        upgrade = cfg.autoUpgrade;
      };
    };
  };
}
