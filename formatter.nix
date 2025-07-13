{ pkgs }:
pkgs.treefmt.withConfig {
  runtimeInputs = with pkgs; [
    nixfmt
    deadnix
    keep-sorted
  ];
  settings = pkgs.lib.importTOML ./treefmt.toml;
}
