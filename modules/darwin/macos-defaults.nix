{ config, lib, ... }:
let
  cfg = config.macosDefaults;
in
{
  options.macosDefaults = {
    enable = lib.mkEnableOption "macOS system defaults configuration";

    dock = {
      autohide = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Automatically hide and show the dock";
      };

      showRecents = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Show recent applications in the dock";
      };
    };

    finder = {
      showExtensions = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Always show file extensions";
      };

      showHiddenFiles = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Show hidden files in Finder";
      };

      showDesktopIcons = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Show icons on the desktop";
      };

      newWindowTarget = lib.mkOption {
        type = lib.types.str;
        default = "Computer";
        description = "Default folder shown in new Finder windows";
      };

      showPathbar = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Show path breadcrumbs in Finder windows";
      };

      showStatusBar = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Show status bar at bottom of Finder windows with item/disk space stats";
      };
    };

    menuBar = {
      show24HourClock = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Show a 24-hour clock instead of 12-hour";
      };

      showDate = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Show the full date in menu bar";
      };

      showSeconds = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Show seconds in clock (instead of just minutes)";
      };
    };

    screensaver = {
      askForPassword = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Prompt for password when screensaver is unlocked or stopped";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    system.defaults = {
      # Dock: macOS dock behavior and appearance
      dock = {
        autohide = cfg.dock.autohide;
        show-recents = cfg.dock.showRecents;
      };

      # Finder: file browser settings and default behavior
      finder = {
        AppleShowAllExtensions = cfg.finder.showExtensions;
        AppleShowAllFiles = cfg.finder.showHiddenFiles;
        CreateDesktop = cfg.finder.showDesktopIcons;
        NewWindowTarget = cfg.finder.newWindowTarget;
        ShowPathbar = cfg.finder.showPathbar;
        ShowStatusBar = cfg.finder.showStatusBar;
      };

      # Menu bar clock: time and date display in menu bar
      menuExtraClock = {
        Show24Hour = cfg.menuBar.show24HourClock;
        ShowDate = if cfg.menuBar.showDate then 1 else 0;
        ShowSeconds = cfg.menuBar.showSeconds;
      };

      # Screensaver: lock screen security settings
      screensaver = {
        askForPassword = cfg.screensaver.askForPassword;
      };
    };
  };
}
