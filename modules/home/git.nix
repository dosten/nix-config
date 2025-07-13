_: {
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
