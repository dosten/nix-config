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
      user.email = "diego@saintesteben.me";
    };

    signing = {
      format = "ssh";
      key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMzA5ht43tFoTcRHynNBYg0zi/qQi61AmMWqqzkAhFrh";
      signByDefault = true;
      signer = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
    };
  };
}
