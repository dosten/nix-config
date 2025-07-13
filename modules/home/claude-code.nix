{ config, lib, ... }:
let
  cfg = config.claudeCode;
in
{
  options.claudeCode = {
    enable = lib.mkEnableOption "Claude Code CLI";

    bedrockUrlPath = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = ''
        Path to file containing Bedrock base URL for Claude Code.
        When set, the URL is read from this file and used to configure Bedrock integration.
        Automatically enables Bedrock mode and skips Bedrock auth.
        Sets: ANTHROPIC_BEDROCK_BASE_URL, CLAUDE_CODE_USE_BEDROCK=1, CLAUDE_CODE_SKIP_BEDROCK_AUTH=1
      '';
      example = "config.sops.secrets.claude-code-bedrock-url.path";
    };

    authTokenPath = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = ''
        Path to file containing authentication token for Claude Code.
        The token is read from this file and used to set ANTHROPIC_AUTH_TOKEN.
      '';
      example = "config.sops.secrets.claude-code-token.path";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.claude-code = {
      enable = true;
    };

    # Load credentials from files in shell init
    # This allows using SOPS secrets or other secure file sources
    programs.fish = {
      shellInit = lib.concatStringsSep "\n" (
        lib.optional (cfg.bedrockUrlPath != null) ''
          export ANTHROPIC_BEDROCK_BASE_URL=$(cat ${cfg.bedrockUrlPath})
          export CLAUDE_CODE_USE_BEDROCK=1
          export CLAUDE_CODE_SKIP_BEDROCK_AUTH=1
        ''
        ++ lib.optional (cfg.authTokenPath != null) ''
          export ANTHROPIC_AUTH_TOKEN=$(cat ${cfg.authTokenPath})
        ''
      );
    };
  };
}
