{ inputs, ... }:

{
  imports = [
    # keep-sorted start
    inputs.catppuccin.homeModules.catppuccin
    # keep-sorted end
  ];

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  home.stateVersion = "25.11";

  # Enable management of XDG base directories.
  xdg.enable = true;

  # Enable Catppuccin globally
  catppuccin.enable = true;

  # Set desired Catpuccin flavor.
  catppuccin.flavor = "mocha";

  home.packages = with pkgs; [
    # keep-sorted start
    bazelisk
    dive
    kubectl
    kubernetes-helm
    rustup
    skopeo
    syft
    terraform
    # keep-sorted end
  ];
}
