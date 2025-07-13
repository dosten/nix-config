{ config, lib, ... }:
let
  cfg = config.jqTools;
in
{
  options.jqTools = {
    enable = lib.mkEnableOption "jq";
  };

  config = lib.mkIf cfg.enable {
    programs.jq.enable = true;
  };
}
