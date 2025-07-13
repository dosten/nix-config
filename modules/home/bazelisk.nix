{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.bazelTools;
in
{
  options.bazelTools = {
    enable = lib.mkEnableOption "Bazelisk";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [ bazelisk ];
  };
}
