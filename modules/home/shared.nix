{
  inputs,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    # keep-sorted start
    # All modules are imported here. Enable/disable per host using options.
    inputs.catppuccin.homeModules.catppuccin
    inputs.self.homeModules.awscli
    inputs.self.homeModules.bazelisk
    inputs.self.homeModules.claude-code
    inputs.self.homeModules.docker
    inputs.self.homeModules.fish
    inputs.self.homeModules.ghostty
    inputs.self.homeModules.git
    inputs.self.homeModules.gnupg
    inputs.self.homeModules.jq
    inputs.self.homeModules.kubernetes
    inputs.self.homeModules.neovim
    inputs.self.homeModules.pyenv
    inputs.self.homeModules.rclone
    inputs.self.homeModules.rust
    inputs.self.homeModules.ssl
    inputs.self.homeModules.terraform
    inputs.self.homeModules.zed
    inputs.sops-nix.homeManagerModules.sops
    # keep-sorted end
  ];

  # Maintains compatibility with Home Manager state across updates.
  # This helps avoid breakage when a new Home Manager release introduces
  # backwards incompatible changes. Only change when upgrading major versions.
  # See: https://nix-community.github.io/home-manager/release-notes.xhtml
  home.stateVersion = "25.11";

  # Enable XDG Base Directory specification compliance.
  # This ensures applications store configs in ~/.config, data in ~/.local/share, etc.
  # See: https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html
  xdg.enable = true;

  # Set Catppuccin theme flavor for all supported applications.
  # "mocha" is the dark variant with warm colors.
  # Other options: latte (light), frappe (dark), macchiato (dark)
  catppuccin.flavor = "mocha";

  # Modules enabled by default
  # These are general-purpose tools useful on all machines
  # Use lib.mkDefault so these can be overridden in user configurations
  # keep-sorted start
  customFish.atuin.enable = lib.mkDefault true;
  customFish.bat.enable = lib.mkDefault true;
  customFish.direnv.enable = lib.mkDefault true;
  customFish.enable = lib.mkDefault true;
  customFish.eza.enable = lib.mkDefault true;
  customFish.starship.enable = lib.mkDefault true;
  customGhostty.enable = lib.mkDefault true;
  customGit.enable = lib.mkDefault true;
  customNeovim.enable = lib.mkDefault true;
  customSsl.enable = lib.mkDefault true;
  gnupgTools.enable = lib.mkDefault true;
  jqTools.enable = lib.mkDefault true;
  # keep-sorted end

  # Modules disabled by default
  # Enable these per-host based on what work you do
  # Use lib.mkDefault so these can be overridden in user configurations
  # keep-sorted start
  awsTools.enable = lib.mkDefault false;
  bazelTools.enable = lib.mkDefault false;
  claudeCode.enable = lib.mkDefault false;
  customZed.enable = lib.mkDefault false;
  dockerTools.enable = lib.mkDefault false;
  kubernetesTools.enable = lib.mkDefault false;
  pyenvTools.enable = lib.mkDefault false;
  rcloneTools.enable = lib.mkDefault false;
  rustTools.enable = lib.mkDefault false;
  terraformTools.enable = lib.mkDefault false;
  # keep-sorted end
}
