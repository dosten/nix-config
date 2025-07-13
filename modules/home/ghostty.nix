_: {
  programs.ghostty = {
    enable = true;
    package = null;
    settings = {
      # keep-sorted start
      auto-update = "download";
      font-family = "FiraCode Nerd Font Mono";
      maximize = true;
      quit-after-last-window-closed = true;
      shell-integration-features = true;
      split-inherit-working-directory = true;
      tab-inherit-working-directory = true;
      window-inherit-working-directory = true;
      window-padding-balance = true;
      window-padding-x = 5;
      window-padding-y = 5;
      # keep-sorted end
    };
  };
}
