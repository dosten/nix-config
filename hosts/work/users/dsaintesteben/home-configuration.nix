{ inputs, config, ... }:
{
  imports = [
    inputs.self.homeModules.shared
  ];

  # Default encrypted file to read secrets from when not explicitly specified
  # All secrets defined below will be read from this file unless they specify their own sopsFile
  sops.defaultSopsFile = ./secrets/default.yaml;

  # Age encryption key configuration
  sops.age.keyFile = "/Users/dsaintesteben/.config/sops/age/keys.txt";
  sops.age.sshKeyPaths = [ ]; # Don't use SSH keys for decryption, use Age key only

  # Define secrets to decrypt and make available to the system
  # Each secret becomes available at /run/secrets/<name>
  sops.secrets.claude-code-token = { };
  sops.secrets.claude-code-bedrock-url = { };

  # Enable only the tools needed on this host
  dockerTools.enable = true;
  kubernetesTools.enable = true;
  terraformTools.enable = true;
  awsTools.enable = true;
  rustTools.enable = true;
  bazelTools.enable = true;
  pyenvTools.enable = true;
  rcloneTools.enable = true;
  customZed.enable = true;

  # Configure Claude Code with credentials from SOPS secrets
  claudeCode = {
    enable = true;
    bedrockUrlPath = config.sops.secrets.claude-code-bedrock-url.path;
    authTokenPath = config.sops.secrets.claude-code-token.path;
  };

  # Git user configuration using customGit module
  customGit = {
    user = {
      name = "Diego Saint Esteben";
      email = "dsaintesteben@salesforce.com";
    };
    signing = {
      enable = true;
      format = "ssh";
      key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHov54FMsuUnu7hyqxZtWEupl4PAReLAKY+wFA2VehMx";
      signerPath = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
    };
  };
}
