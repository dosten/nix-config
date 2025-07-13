{ config, lib, ... }:
let
  cfg = config.rcloneTools;
in
{
  options.rcloneTools = {
    enable = lib.mkEnableOption "Rclone";
  };

  config = lib.mkIf cfg.enable {
    programs.rclone.enable = true;
  };
}
