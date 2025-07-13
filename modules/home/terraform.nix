{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.terraformTools;
in
{
  options.terraformTools = {
    enable = lib.mkEnableOption "Terraform";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [ terraform ];
  };
}
