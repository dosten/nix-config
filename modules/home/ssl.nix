{ config, lib, ... }:
let
  cfg = config.customSsl;
in
{
  options.customSsl = {
    enable = lib.mkEnableOption "custom SSL certificate bundle configuration";

    certPath = lib.mkOption {
      type = lib.types.str;
      default = "$HOME/.local/ssl/certs/ca-bundle.crt";
      description = ''
        Path to the SSL certificate bundle file.

        The ca-bundle.crt must be created manually during initial setup:
          mkdir -p ~/.local/ssl/certs
          security find-certificate -a -p /System/Library/Keychains/SystemRootCertificates.keychain > ~/.local/ssl/certs/ca-bundle.crt
          security find-certificate -a -p /Library/Keychains/System.keychain >> ~/.local/ssl/certs/ca-bundle.crt
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    # Configure SSL certificate bundle for Nix and system tools.
    #
    # Nix does not use the system truststore by default, which can cause SSL errors
    # when fetching packages or connecting to corporate networks with custom CAs.
    #
    # NIX_SSL_CERT_FILE: Used by Nix for package fetching and builds
    # SSL_CERT_FILE: Used by curl, wget, and other command-line tools
    home.sessionVariables = {
      NIX_SSL_CERT_FILE = cfg.certPath;
      SSL_CERT_FILE = cfg.certPath;
    };

    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      matchBlocks = {
        "*" = {
          identityAgent = "~/Library/Group\\ Containers/2BUA8C4S2C.com.1password/t/agent.sock";
        };
      };
    };
  };
}
