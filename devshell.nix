{ pkgs }:
pkgs.mkShell {
  packages = with pkgs; [
    # keep-sorted start
    age
    sops
    # keep-sorted end
  ];
}
