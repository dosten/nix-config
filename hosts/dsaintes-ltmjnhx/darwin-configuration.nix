{ inputs, ... }:

{
  imports = [
    inputs.self.darwinModules.shared
    inputs.self.darwinModules.development
  ];

  nixpkgs.hostPlatform = "aarch64-darwin";

  # The user should already exist, but we need to set this up so Nix knows
  # what our home directory is (https://github.com/nix-darwin/nix-darwin/issues/423)
  users.users.dsaintesteben = {
    home = "/Users/dsaintesteben";
  };

  # Required for some settings like homebrew to know what user to apply to.
  system.primaryUser = "dsaintesteben";

  homebrew.casks = [
    # keep-sorted start
    "1password"
    "google-chrome"
    "slack"
    "the-unarchiver"
    # keep-sorted end
  ];
}
