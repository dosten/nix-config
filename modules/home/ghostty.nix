{ config, lib, ... }:
let
  cfg = config.customGhostty;
in
{
  options.customGhostty = {
    enable = lib.mkEnableOption "Ghostty";

    fontFamily = lib.mkOption {
      type = lib.types.str;
      default = "FiraCode Nerd Font Mono";
      description = "Font family to use in Ghostty";
    };

    windowPadding = lib.mkOption {
      type = lib.types.int;
      default = 5;
      description = "Window padding in pixels (both X and Y)";
    };

    autoUpdate = lib.mkOption {
      type = lib.types.enum [
        "off"
        "check"
        "download"
      ];
      default = "download";
      description = "Auto-update behavior";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.ghostty = {
      enable = true;
      package = null; # Installed via Homebrew
      settings = {
        # keep-sorted start
        auto-update = cfg.autoUpdate;
        font-family = cfg.fontFamily;
        maximize = true;
        quit-after-last-window-closed = true;
        shell-integration-features = true;
        split-inherit-working-directory = true;
        tab-inherit-working-directory = true;
        window-inherit-working-directory = true;
        window-padding-balance = true;
        window-padding-x = cfg.windowPadding;
        window-padding-y = cfg.windowPadding;
        # keep-sorted end
      };
    };

    catppuccin.ghostty.enable = true;
  };
}
