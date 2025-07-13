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
  users.users.dsaintesteben = {
    home = "/Users/dsaintesteben";
  };

  # Primary user for system-wide settings that apply to a specific user.
  # Used by homebrew and other modules to know which user to configure.
  system.primaryUser = "dsaintesteben";

  # GUI applications installed via Homebrew Cask.
  # These apps aren't available in nixpkgs or work better via Homebrew on macOS.
  homebrew.casks = [
    # keep-sorted start block=yes
    "1password" # Password manager with SSH/GPG agent
    "docker-desktop" # Docker with native macOS integration
    "ghostty" # GPU-accelerated terminal emulator
    "google-chrome" # Web browser
    "intellij-idea" # TODO: delete - evaluate if still needed
    "postman" # API development and testing
    "slack" # Team communication
    "the-unarchiver" # Archive extraction utility
    "tower" # Git GUI client
    "zed" # Modern code editor
    # keep-sorted end
  ];
}
