{ pkgs, lib, ... }:

let
  shellAliases = {
    cat = "bat";
  }
  // lib.optionalAttrs pkgs.stdenv.isDarwin {
    copy = "pbcopy";
    paste = "pbpaste";
  }
  // lib.optionalAttrs pkgs.stdenv.isLinux {
    copy = "xclip -selection clipboard";
    paste = "xclip -selection clipboard -o";
  };
  shellAbbrs = {
    g = "git";
    k = "kubectl";
  };
in
{
  home.packages =
    with pkgs;
    [
      # keep-sorted start
      bat
      curl
      fastfetch
      htop
      parallel
      wget2
      # keep-sorted end
    ]
    ++ lib.optionals pkgs.stdenv.isLinux [
      xclip
    ];

  home.shell.enableFishIntegration = true;

  # Setup shell
  programs.fish = {
    enable = true;
    shellAliases = shellAliases;
    shellAbbrs = shellAbbrs;
    shellInit = "source ${./config.fish}";
  };

  programs.bat.enable = true;

  programs.eza = {
    enable = true;
    extraOptions = [ "--group-directories-first" ];
  };

  # Setup prompt
  programs.starship = {
    enable = true;
    settings = {
      battery.disabled = true;
      git_status.disabled = true;
      direnv.disabled = false;
    };
  };

  # Setup editor
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  # Setup direnv
  programs.direnv.enable = true;

  programs.fzf.enable = true;
}
