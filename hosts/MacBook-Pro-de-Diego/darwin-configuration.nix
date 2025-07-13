{ inputs, ... }:

{
  imports = [
    inputs.self.darwinModules.shared
    inputs.self.darwinModules.development
  ];

  nixpkgs.hostPlatform = "aarch64-darwin";

  # The user should already exist, but we need to set this up so Nix knows
  # what our home directory is (https://github.com/nix-darwin/nix-darwin/issues/423)
  users.users.dosten = {
    home = "/Users/dosten";
  };

  # Required for some settings like homebrew to know what user to apply to.
  system.primaryUser = "dosten";

  homebrew.casks = [
    "1password"
    "google-chrome"
    "nordvpn"
    {
      name = "sparrow";
      greedy = true;
    }
    "spotify"
    "tailscale-app"
    "telegram"
    "the-unarchiver"
    "whatsapp"
  ];
}
