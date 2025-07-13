{ config, lib, ... }:
let
  cfg = config.awsTools;
in
{
  options.awsTools = {
    enable = lib.mkEnableOption "AWS CLI";
  };

  config = lib.mkIf cfg.enable {
    programs.awscli.enable = true;
  };
}
