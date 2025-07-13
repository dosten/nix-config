{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.customFonts;
in
{
  options.customFonts = {
    enable = lib.mkEnableOption "custom font packages";

    packages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = with pkgs; [ nerd-fonts.fira-code ];
      description = ''
        Font packages to install.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    fonts.packages = cfg.packages;
  };
}
