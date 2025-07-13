# Secrets Management

This document describes how to manage encrypted secrets using sops-nix in this repository.

## Overview

Secrets are encrypted using [sops-nix](https://github.com/Mic92/sops-nix) with age encryption. Each host/user has their own secrets file that is encrypted with their age key.

## Initial Setup

### 1. Generate an Age Key

If you don't already have an age key:

```bash
mkdir -p ~/.config/sops/age
nix develop --command age-keygen -o ~/.config/sops/age/keys.txt
```

### 2. Get Your Age Public Key

```bash
nix develop --command age -y ~/.config/sops/age/keys.txt
```

Example output:
```
age1ql3z7hjy54pw3hyww5ayyfg7zqgvc7w3j2elw8zmrj2kg5sfn9aqmcac8p
```

### 3. Configure .sops.yaml

Add your age public key to `.sops.yaml` for your host:

```yaml
keys:
  - &user_dosten age1ql3z7hjy54pw3hyww5ayyfg7zqgvc7w3j2elw8zmrj2kg5sfn9aqmcac8p

creation_rules:
  - path_regex: hosts/personal/users/dosten/secrets/.*\.yaml$
    key_groups:
      - age:
          - *user_dosten
```

## Creating Secrets

Secrets are stored in `hosts/<hostname>/users/<username>/secrets/default.yaml`.

### 1. Create the Secrets Directory

```bash
mkdir -p hosts/personal/users/dosten/secrets
```

### 2. Create and Edit Secrets File

```bash
nix develop --command sops hosts/personal/users/dosten/secrets/default.yaml
```

This opens your editor with a decrypted view. Add secrets in YAML format:

```yaml
claude-code-token: "your-token-here"
claude-code-bedrock-url: "https://your-url-here"
github-token: "ghp_..."
```

### 3. Save and Exit

The file will be automatically encrypted when you save and exit your editor.

## Using Secrets in Configuration

In your `home-configuration.nix`:

```nix
{ inputs, config, ... }:
{
  imports = [ inputs.self.homeModules.shared ];

  # Point to your secrets file
  sops.defaultSopsFile = ./secrets/default.yaml;

  # Configure age key location
  sops.age.keyFile = "/Users/dosten/.config/sops/age/keys.txt";

  # Define secrets to decrypt
  sops.secrets.claude-code-token = { };
  sops.secrets.claude-code-bedrock-url = { };

  # Use secrets in module configuration
  claudeCode = {
    enable = true;
    authTokenPath = config.sops.secrets.claude-code-token.path;
    bedrockUrlPath = config.sops.secrets.claude-code-bedrock-url.path;
  };
}
```

Secrets are decrypted at activation time and made available at `/run/secrets/<secret-name>`.

## Editing Existing Secrets

```bash
nix develop --command sops hosts/personal/users/dosten/secrets/default.yaml
```

This decrypts the file, opens your editor, and re-encrypts on save.

## How It Works

1. **Encryption**: Secrets are encrypted with your age public key
2. **Storage**: Encrypted files are committed to the repository
3. **Decryption**: At activation time, sops-nix decrypts secrets using your age private key
4. **Access**: Decrypted secrets are placed in `/run/secrets/` with restricted permissions

## File Structure

```
hosts/
└── personal/
    └── users/
        └── dosten/
            ├── home-configuration.nix
            └── secrets/
                └── default.yaml          # Encrypted secrets file
```

## Best Practices

### Security

- **Never commit unencrypted secrets** - Always use sops
- **Keep age keys secure** - Store in `~/.config/sops/age/keys.txt` with restrictive permissions
- **One key per user** - Don't share age keys between users
- **Backup your age key** - Store securely in a password manager

### Organization

- **One secrets file per user** - `secrets/default.yaml` in each user directory
- **Descriptive secret names** - Use clear names like `github-token` not `token1`
- **Group related secrets** - Use YAML structure for organization

Example with groups:
```yaml
github:
  token: "ghp_..."
  username: "myuser"

aws:
  access_key_id: "AKIA..."
  secret_access_key: "..."
```

### Configuration

- **Use relative paths** - `sops.defaultSopsFile = ./secrets/default.yaml`
- **Reference secrets by path** - Use `config.sops.secrets.<name>.path`
- **Don't hardcode values** - Always use sops for sensitive data

## Multiple Secrets Files

You can have multiple secrets files per user:

```nix
sops.secrets.github-token = {
  sopsFile = ./secrets/github.yaml;
};

sops.secrets.aws-key = {
  sopsFile = ./secrets/aws.yaml;
};
```

Update `.sops.yaml` with appropriate path patterns:

```yaml
creation_rules:
  - path_regex: hosts/personal/users/dosten/secrets/.*\.yaml$
    key_groups:
      - age:
          - *user_dosten
```

## Troubleshooting

### Failed to Decrypt

**Problem:** `error: Failed to decrypt`

**Solutions:**
1. Verify your age key location matches `sops.age.keyFile`
2. Check that your public key is in `.sops.yaml` for the secrets file
3. Ensure the secrets file was encrypted with your key

### Editor Not Opening

**Problem:** `sops` doesn't open an editor

**Solutions:**
1. Set `EDITOR` environment variable: `export EDITOR=vim`
2. Use explicit editor: `EDITOR=vim nix develop --command sops ...`

### Permission Denied

**Problem:** Can't read `/run/secrets/<name>`

**Solutions:**
1. Check that the secret is defined in your configuration
2. Verify you've activated the configuration: `make`
3. Check file permissions in `/run/secrets/`

### Wrong Age Key

**Problem:** Secrets file encrypted with different key

**Solutions:**
1. Re-encrypt with correct key: Update `.sops.yaml` and run `sops updatekeys file.yaml`
2. Or recreate secrets file with correct key

## Common Patterns

### SSH Keys

```yaml
ssh:
  github_key: |
    -----BEGIN OPENSSH PRIVATE KEY-----
    ...
    -----END OPENSSH PRIVATE KEY-----
```

Usage:
```nix
sops.secrets.ssh-github-key = {
  mode = "0600";
  path = "/Users/dosten/.ssh/github";
};
```

### Environment Variables

```nix
home.sessionVariables = {
  GITHUB_TOKEN = config.sops.secrets.github-token.path;
};
```

Note: This exposes the *path* to the secret file, not the secret itself.

### Configuration Files

```nix
xdg.configFile."app/config.json".text = builtins.toJSON {
  api_key = builtins.readFile config.sops.secrets.api-key.path;
  endpoint = "https://api.example.com";
};
```

## Reference

- [sops-nix Documentation](https://github.com/Mic92/sops-nix)
- [age Encryption](https://github.com/FiloSottile/age)
- [sops](https://github.com/mozilla/sops)

## Summary

Secrets management with sops-nix:

1. Generate age key: `nix develop --command age-keygen -o ~/.config/sops/age/keys.txt`
2. Get public key: `nix develop --command age -y ~/.config/sops/age/keys.txt`
3. Add to `.sops.yaml`
4. Create secrets: `nix develop --command sops hosts/.../secrets/default.yaml`
5. Use in config: `config.sops.secrets.<name>.path`

Secrets are encrypted in the repository and decrypted at activation time to `/run/secrets/`.
