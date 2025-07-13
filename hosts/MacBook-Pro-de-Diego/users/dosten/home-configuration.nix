{ inputs, ... }:

{
  imports = [
    inputs.self.homeModules.shared
    inputs.self.homeModules.shell
    inputs.self.homeModules.development
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
