{ config, lib, ... }:
let
  cfg = config.pyenvTools;
in
{
  options.pyenvTools = {
    enable = lib.mkEnableOption "Pyenv";
  };

  config = lib.mkIf cfg.enable {
    programs.pyenv.enable = true;
  };
}
