{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.customFish;

  # Command aliases that expand on enter
  shellAliases =
    lib.optionalAttrs cfg.bat.enable {
      # Use bat (better cat) for syntax highlighting and paging
      cat = "bat";
    }
    # Platform-specific clipboard aliases
    // lib.optionalAttrs pkgs.stdenv.isDarwin {
      copy = "pbcopy"; # macOS clipboard
      paste = "pbpaste";
    }
    // lib.optionalAttrs pkgs.stdenv.isLinux {
      copy = "xclip -selection clipboard"; # X11 clipboard
      paste = "xclip -selection clipboard -o";
    }
    // cfg.extraAliases;

  # Shell abbreviations that expand as you type (Fish-specific)
  shellAbbrs = {
    g = "git";
    k = "kubectl";
  }
  // cfg.extraAbbrs;
in
{
  options.customFish = {
    enable = lib.mkEnableOption "custom shell configuration with Fish, Starship, and tools";

    extraAliases = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      description = "Additional shell aliases to add";
      example = {
        ll = "ls -la";
      };
    };

    extraAbbrs = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      description = "Additional Fish shell abbreviations to add";
      example = {
        dc = "docker-compose";
      };
    };

    extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [ ];
      description = "Additional packages to install for shell usage";
      example = lib.literalExpression ''
        with pkgs; [
          ripgrep
          fd
          tree
        ]
      '';
    };

    bat = {
      enable = lib.mkEnableOption "bat (better cat with syntax highlighting)";
    };

    eza = {
      enable = lib.mkEnableOption "eza (modern ls replacement)";
    };

    direnv = {
      enable = lib.mkEnableOption "direnv for automatic environment loading";

      whitelistPaths = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ "$HOME/Code" ];
        description = ''
          Directories where .envrc files are automatically loaded without manual approval.
          Files outside these directories require manual approval for security.
        '';
      };
    };

    starship = {
      enable = lib.mkEnableOption "Starship prompt";
    };

    atuin = {
      enable = lib.mkEnableOption "Atuin shell history with SQLite storage";
    };
  };

  config = lib.mkIf cfg.enable {
    # Add custom binary directory to PATH for user-installed tools
    home.sessionPath = [ "$HOME/.local/bin" ];

    # Core command-line utilities
    home.packages =
      with pkgs;
      [
        # keep-sorted start
        curl # HTTP client
        fastfetch # System information tool (neofetch alternative)
        htop # Interactive process viewer
        parallel # GNU parallel for running commands in parallel
        shellcheck # Shell script linter
        wget2 # HTTP/FTP file downloader (wget successor)
        # keep-sorted end
      ]
      # Linux-specific packages
      ++ lib.optionals pkgs.stdenv.isLinux [
        xclip # X11 clipboard tool
      ]
      # User-defined additional packages
      ++ cfg.extraPackages;

    home.shell.enableFishIntegration = true;

    # Fish shell: Modern shell with autosuggestions and syntax highlighting
    programs.fish = {
      enable = true;
      shellAliases = shellAliases;
      shellAbbrs = shellAbbrs;
      shellInit = ''
        # Disable the default greeting message for cleaner shell startup
        set -U fish_greeting
      '';
    };

    # bat: Syntax highlighting for file viewing
    programs.bat = lib.mkIf cfg.bat.enable {
      enable = true;
    };

    # eza: Modern replacement for ls with colors and git integration
    programs.eza = lib.mkIf cfg.eza.enable {
      enable = true;
      # Show directories first, then files (easier to navigate)
      extraOptions = [ "--group-directories-first" ];
    };

    # Starship: Fast, customizable shell prompt
    programs.starship = lib.mkIf cfg.starship.enable {
      enable = true;
      settings = {
        # Disable battery indicator (not useful on desktops or always-plugged laptops)
        battery.disabled = true;
        # Disable git status (improves performance on large repos, use lazygit instead)
        git_status.disabled = true;
        # Show direnv status (important for Nix dev shells)
        direnv.disabled = false;
      };
    };

    # direnv: Automatically load/unload environment variables per directory
    programs.direnv = lib.mkIf cfg.direnv.enable {
      enable = true;
      config = {
        # Only auto-load .envrc files in specified paths for security
        # Files outside these directories require manual approval
        whitelist.prefix = cfg.direnv.whitelistPaths;
      };
    };

    # Atuin: Shell history in SQLite with sync capability
    programs.atuin = lib.mkIf cfg.atuin.enable {
      enable = true;
      settings = {
        # keep-sorted start block=yes
        # Only search history from current host (not synced history from other machines)
        filter_mode = "host";
        # Available filters when searching history
        search.filters = [
          "host" # Filter by hostname
          "session" # Filter by shell session
          "directory" # Filter by working directory
          "workspace" # Filter by git workspace
        ];
        # Hide help text in search UI for more compact display
        show_help = false;
        # Hide command preview pane (shows full command details)
        show_preview = false;
        # Hide filter tabs at top of search UI
        show_tabs = false;
        # Only show command column in search results (hide timestamp, duration, etc.)
        ui.columns = [ "command" ];
        # Disable update checks (managed by Nix)
        update_check = false;
        # keep-sorted end
      };
    };

    # Apply Catppuccin theme to all shell tools
    catppuccin = {
      fish.enable = true;
      bat.enable = cfg.bat.enable;
      eza.enable = cfg.eza.enable;
      starship.enable = cfg.starship.enable;
      atuin.enable = cfg.atuin.enable;
    };
  };
}
