{ pkgs, ... }:

{
  home.packages = with pkgs; [ grype ];
  xdg.configFile."grype/config.yaml".source = ./config.yaml;
}
