{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.rustTools;
in
{
  options.rustTools = {
    enable = lib.mkEnableOption "Rust development tools";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [ rustup ];
  };
}
