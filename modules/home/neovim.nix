{ config, lib, ... }:
let
  cfg = config.customNeovim;
in
{
  options.customNeovim = {
    enable = lib.mkEnableOption "Neovim";

    setAsDefaultEditor = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Set Neovim as default editor (EDITOR environment variable)";
    };

    enableViAlias = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Create 'vi' alias for nvim";
    };

    enableVimAlias = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Create 'vim' alias for nvim";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.neovim = {
      enable = true;
      defaultEditor = cfg.setAsDefaultEditor;
      viAlias = cfg.enableViAlias;
      vimAlias = cfg.enableVimAlias;
    };

    catppuccin.nvim.enable = true;
  };
}
