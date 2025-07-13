{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.gnupgTools;
in
{
  options.gnupgTools = {
    enable = lib.mkEnableOption "GnuPG";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [ gnupg ];
  };
}
