{ inputs, ... }:
{
  imports = [
    inputs.self.homeModules.shared
  ];

  # Enable only the tools needed on this host
  dockerTools.enable = true;
  rcloneTools.enable = true;
  customZed.enable = true;

  # Git user configuration using customGit module
  customGit = {
    user = {
      name = "Diego Saint Esteben";
      email = "diego@saintesteben.me";
    };
    signing = {
      enable = true;
      format = "ssh";
      key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMzA5ht43tFoTcRHynNBYg0zi/qQi61AmMWqqzkAhFrh";
      signerPath = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
    };
  };
}
