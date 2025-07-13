{ pkgs, ... }:

{
  # Used for backwards compatibility, please read the changelog before changing.
  system.stateVersion = 6;

  # Automatically hide and show the dock.
  system.defaults.dock.autohide = true;

  # Do not show recent applications in the dock.
  system.defaults.dock.show-recents = false;

  # Always show file extensions.
  system.defaults.finder.AppleShowAllExtensions = true;

  # Do not show hidden files.
  system.defaults.finder.AppleShowAllFiles = false;

  # Do not show icons on the desktop.
  system.defaults.finder.CreateDesktop = false;

  # Set the default folder shown in Finder windows.
  system.defaults.finder.NewWindowTarget = "Computer";

  # Show path breadcrumbs in finder windows.
  system.defaults.finder.ShowPathbar = true;

  # Show status bar at bottom of finder windows with item/disk space stats.
  system.defaults.finder.ShowStatusBar = true;

  # Show a 24-hour clock, instead of a 12-hour clock.
  system.defaults.menuExtraClock.Show24Hour = true;

  # Show the full date always.
  system.defaults.menuExtraClock.ShowDate = 1;

  # Show the clock with second precision, instead of minutes.
  system.defaults.menuExtraClock.ShowSeconds = true;

  # Prompt the user for password when the screen saver is unlocked or stopped.
  system.defaults.screensaver.askForPassword = true;

  # We use the determinate-nix installer which manages Nix for us,
  # so we don't want nix-darwin to do it.
  nix.enable = false;

  # We use proprietary software.
  nixpkgs.config.allowUnfree = true;

  # Install custom fonts
  fonts.packages = with pkgs; [ nerd-fonts.fira-code ];

  environment.shells = with pkgs; [ fish ];

  # Enable Touch ID for sudo
  security.pam.services.sudo_local = {
    touchIdAuth = true;
    reattach = true;
  };

  # Enable Homebrew management via nix-darwin.
  homebrew.enable = true;

  # Uninstall all formulae, casks and associated files.
  homebrew.onActivation.cleanup = "zap";

  homebrew.onActivation.autoUpdate = true;
  homebrew.onActivation.upgrade = true;
}
