{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.dockerTools;
in
{
  options.dockerTools = {
    enable = lib.mkEnableOption "Docker container analysis and security tools";

    enableDive = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable dive - explore Docker image layers and analyze image size";
    };

    enableGrype = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable grype - vulnerability scanner for container images";
    };

    enableSkopeo = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable skopeo - work with container images without Docker daemon";
    };

    enableSyft = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable syft - generate SBOM (Software Bill of Materials) from container images";
    };
  };

  config = lib.mkIf cfg.enable {
    # Docker container analysis and security tools
    # Note: Docker Desktop itself is installed via Homebrew (see host config)
    home.packages =
      with pkgs;
      (lib.optional cfg.enableDive dive)
      ++ (lib.optional cfg.enableGrype grype)
      ++ (lib.optional cfg.enableSkopeo skopeo)
      ++ (lib.optional cfg.enableSyft syft);

    # Configure grype to disable update checks (managed by Nix)
    xdg.configFile."grype/config.yaml" = lib.mkIf cfg.enableGrype {
      text = ''
        check-for-app-update: false
      '';
    };

    # Configure syft to disable update checks (managed by Nix)
    xdg.configFile."syft/config.yaml" = lib.mkIf cfg.enableSyft {
      text = ''
        check-for-app-update: false
      '';
    };
  };
}
