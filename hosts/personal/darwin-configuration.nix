{ inputs, ... }:
{
  imports = [
    inputs.self.darwinModules.shared
  ];

  # Set platform architecture for M1/M2/M3 Macs (Apple Silicon)
  nixpkgs.hostPlatform = "aarch64-darwin";

  # Define user for nix-darwin to manage.
  # The user must already exist on the system (created during macOS setup).
  # This tells nix-darwin where the home directory is located.
  # See: https://github.com/nix-darwin/nix-darwin/issues/423
  users.users.dosten = {
    home = "/Users/dosten";
  };

  # Primary user for system-wide settings that apply to a specific user.
  # Used by homebrew and other modules to know which user to configure.
  system.primaryUser = "dosten";

  # SOPS secrets management configuration
  # defaultSopsFile: Default encrypted file to read secrets from when not explicitly specified
  # All secrets defined below will be read from this file unless they specify their own sopsFile
  sops.defaultSopsFile = ./secrets/default.yaml;

  # Age encryption key configuration
  sops.age.keyFile = "/Users/dsaintesteben/.config/sops/age/keys.txt";
  sops.age.sshKeyPaths = [ ]; # Don't use SSH keys for decryption, use Age key only

  # GUI applications installed via Homebrew Cask.
  # These apps aren't available in nixpkgs or work better via Homebrew on macOS.
  homebrew.casks = [
    # keep-sorted start block=yes
    "1password"
    "docker-desktop"
    "ghostty"
    "google-chrome"
    "intellij-idea"
    "nordvpn"
    "spotify"
    "tailscale-app"
    "telegram"
    "the-unarchiver"
    "whatsapp"
    "zed"
    {
      name = "raspberry-pi-imager";
      greedy = true;
    }
    {
      name = "sparrow";
      greedy = true;
    }
    # keep-sorted end
  ];
}
