{ inputs, ... }:

{
  imports = [
    # keep-sorted start
    inputs.self.homeModules.awscli
    inputs.self.homeModules.ghostty
    inputs.self.homeModules.git
    inputs.self.homeModules.grype
    inputs.self.homeModules.jq
    inputs.self.homeModules.lazygit
    inputs.self.homeModules.neovim
    inputs.self.homeModules.pyenv
    inputs.self.homeModules.rclone
    inputs.self.homeModules.shared
    inputs.self.homeModules.shell
    # keep-sorted end
  ];

  programs.git = {
    settings = {
      user.name = "Diego Saint Esteben";
      user.email = "dsaintesteben@salesforce.com";
    };
  };
}
