_: {
  programs.lazygit = {
    enable = true;
    settings = {
      gui.showCommandLog = false;
      update.method = "never";
    };
  };

  catppuccin.lazygit.enable = true;
}
