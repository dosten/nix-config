{ inputs, lib, ... }:
{
  imports = [
    # keep-sorted start
    # All darwin modules are imported here. Enable/disable per host using options.
    inputs.self.darwinModules.fonts
    inputs.self.darwinModules.homebrew
    inputs.self.darwinModules.macos-defaults
    inputs.self.darwinModules.security
    # keep-sorted end
  ];

  # Maintains compatibility with nix-darwin state across updates.
  # Only change this when explicitly instructed by the nix-darwin changelog.
  # See: https://github.com/LnL7/nix-darwin/blob/master/CHANGELOG
  system.stateVersion = 6;

  # Disable nix-darwin's built-in Nix daemon management.
  # The Determinate Nix installer (https://docs.determinate.systems) manages
  # the Nix daemon for us, providing better installation and upgrade experience.
  # Without this, nix-darwin would conflict with the Determinate installer.
  nix.enable = false;

  # Allow installation of unfree (proprietary) packages from nixpkgs.
  # This is required for packages like Terraform and Claude Code.
  nixpkgs.config.allowUnfree = true;

  # System modules enabled by default
  # Use lib.mkDefault so these can be overridden in host configurations
  # keep-sorted start
  customFonts.enable = lib.mkDefault true;
  customHomebrew.enable = lib.mkDefault true;
  macosDefaults.enable = lib.mkDefault true;
  macosSecurity.enable = lib.mkDefault true;
  # keep-sorted end
}
