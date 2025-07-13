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
      user.email = "dsaintesteben@salesforce.com";
    };
  };
}
