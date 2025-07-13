{ pkgs, ... }:

{
  # Prepend custom paths to PATH
  home.sessionPath = [ "$HOME/.local/bin" ];

  home.packages = with pkgs; [
    # keep-sorted start
    bazelisk
    dive
    grype
    kubectl
    kubernetes-helm
    rustup
    skopeo
    syft
    terraform
    # keep-sorted end
  ];

  # Enable management of XDG base directories.
  xdg.enable = true;

  xdg.configFile."ghostty/config.ghostty".source = ./config.ghostty;
  xdg.configFile."grype/config.yaml".source = ./grype.yaml;

  programs.rclone.enable = true;
  programs.jq.enable = true;
  programs.pyenv.enable = true;
  programs.awscli.enable = true;

  programs.lazygit = {
    enable = true;
    settings = {
      gui.showCommandLog = false;
      update.method = "never";
    };
  };

  programs.git = {
    enable = true;
    settings = {
      # keep-sorted start
      core.autocrlf = "input";
      fetch.prune = true;
      fetch.pruneTags = true;
      help.autocorrect = 1;
      init.defaultBranch = "main";
      log.mailmap = true;
      merge.ff = false;
      pull.rebase = true;
      push.default = "current";
      rebase.autoSquash = true;
      tag.sort = "version:refname";
      # keep-sorted end
    };
    ignores = [
      ".DS_Store"
      ".idea"
    ];
  };
}
