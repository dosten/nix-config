{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.kubernetesTools;
in
{
  options.kubernetesTools = {
    enable = lib.mkEnableOption "Kubernetes tools";

    enableKubectl = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable kubectl CLI";
    };

    enableHelm = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Helm package manager";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages =
      with pkgs;
      (lib.optional cfg.enableKubectl kubectl) ++ (lib.optional cfg.enableHelm kubernetes-helm);
  };
}
