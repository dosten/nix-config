{ pkgs, ... }:

pkgs.mkShell {
  packages = [
    pkgs.sops
  ];
}
