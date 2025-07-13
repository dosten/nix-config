{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.customZed;
in
{
  options.customZed = {
    enable = lib.mkEnableOption "Zed";

    fontFamily = lib.mkOption {
      type = lib.types.str;
      default = "FiraCode Nerd Font Mono";
      description = "Font family to use in Zed";
    };

    fontSize = lib.mkOption {
      type = lib.types.int;
      default = 13;
      description = "Buffer font size";
    };

    uiFontSize = lib.mkOption {
      type = lib.types.int;
      default = 15;
      description = "UI font size";
    };

    extraExtensions = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Additional Zed extensions to install";
    };

    enableInlineBlame = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable inline git blame in editor";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.zed-editor = {
      enable = true;
      package = null; # Installed via Homebrew
      extensions = [
        # keep-sorted start
        "bash"
        "docker-compose"
        "dockerfile"
        "fish"
        "git-firefly"
        "groovy"
        "helm"
        "make"
        "nix"
        "rst"
        "terraform"
        "toml"
        "xml"
        # keep-sorted end
      ]
      ++ cfg.extraExtensions;
      mutableUserSettings = false;
      mutableUserKeymaps = false;
      mutableUserTasks = false;
      userSettings = {
        # keep-sorted start block=yes
        autosave = "on_window_change";
        buffer_font_family = cfg.fontFamily;
        buffer_font_size = cfg.fontSize;
        git.inline_blame.enabled = cfg.enableInlineBlame;
        languages = {
          Nix = {
            language_servers = [
              "nixd"
              "!nil"
            ];
            formatter = {
              external = {
                command = "${pkgs.nixfmt}/bin/nixfmt";
              };
            };
          };
        };
        on_last_window_closed = "quit_app";
        scroll_beyond_last_line = "off";
        tabs.activate_on_close = "neighbour";
        telemetry.diagnostics = false;
        telemetry.metrics = false;
        title_bar.show_sign_in = false;
        ui_font_size = cfg.uiFontSize;
        # keep-sorted end
      };
    };
  };
}
