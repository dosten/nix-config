{ inputs, ... }:

{
  imports = [ inputs.catppuccin.homeModules.catppuccin ];

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  home.stateVersion = "25.11";

  # Enable Catppuccin globally
  catppuccin.enable = true;

  # Set desired Catpuccin flavor.
  catppuccin.flavor = "mocha";
}
