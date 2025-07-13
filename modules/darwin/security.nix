{ config, lib, ... }:
let
  cfg = config.macosSecurity;
in
{
  options.macosSecurity = {
    enable = lib.mkEnableOption "macOS security configuration";

    touchIdForSudo = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Enable Touch ID authentication for sudo commands.
        Provides convenient and secure authentication without typing passwords.
      '';
    };

    touchIdReattach = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Allow Touch ID to work in tmux sessions and other contexts";
    };
  };

  config = lib.mkIf cfg.enable {
    # Enable Touch ID for sudo
    # sudo_local: Local-only configuration that won't be overwritten by system updates
    security.pam.services.sudo_local = lib.mkIf cfg.touchIdForSudo {
      touchIdAuth = true;
      reattach = cfg.touchIdReattach;
    };
  };
}
