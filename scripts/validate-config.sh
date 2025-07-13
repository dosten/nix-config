#!/usr/bin/env bash
# Validate configuration files for common issues and best practices

set -euo pipefail

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Configuration Validation Suite ===${NC}"
echo ""

ERRORS=0
WARNINGS=0

# Check 1: Validate required options are set in host configs
echo -e "${BLUE}Check 1: Checking for required options in host configs${NC}"

for host_config in hosts/*/users/*/home-configuration.nix; do
  # Check if customGit configuration exists (git is enabled by default)
  if grep -q "customGit" "$host_config"; then
    # Check if user name/email is set (match "user = {" or "user.name")
    if grep -A 3 "customGit" "$host_config" | grep -q "user\s*=\|user\.name\|user\.email"; then
      echo -e "${GREEN}  ✓ $host_config: Git user configured${NC}"
    else
      echo -e "${YELLOW}  ⚠ $host_config: Git configured but user.name/email may not be set${NC}"
      echo -e "${YELLOW}    → Configure customGit.user.name and customGit.user.email${NC}"
      WARNINGS=$((WARNINGS + 1))
    fi
  else
    echo -e "${YELLOW}  ⚠ $host_config: Using default Git config (no customGit block)${NC}"
    echo -e "${YELLOW}    → Consider adding customGit.user.name and customGit.user.email${NC}"
    WARNINGS=$((WARNINGS + 1))
  fi

  # Check if commit signing is enabled without a key
  if grep -q "signing\.enable = true" "$host_config"; then
    if grep -A 10 "signing" "$host_config" | grep -q "key\s*="; then
      echo -e "${GREEN}  ✓ $host_config: Git signing configured with key${NC}"
    else
      echo -e "${YELLOW}  ⚠ $host_config: Git signing enabled but no key specified${NC}"
      WARNINGS=$((WARNINGS + 1))
    fi
  fi
done
echo ""

# Check 2: Validate no conflicting options
echo -e "${BLUE}Check 2: Checking for potentially conflicting options${NC}"

for host_config in hosts/*/users/*/home-configuration.nix hosts/*/darwin-configuration.nix; do
  # Check for lib.mkForce usage (usually indicates conflict)
  if grep -q "lib\.mkForce" "$host_config"; then
    echo -e "${YELLOW}  ⚠ $host_config: Uses lib.mkForce (may indicate option conflict)${NC}"
    WARNINGS=$((WARNINGS + 1))
  fi
done
echo ""

# Check 3: Validate shared.nix uses lib.mkDefault
echo -e "${BLUE}Check 3: Checking shared.nix uses lib.mkDefault for defaults${NC}"

for shared_config in modules/{home,darwin}/shared.nix; do
  echo -e "Checking $shared_config..."

  # Check for direct enable = true/false without lib.mkDefault
  # Exclude known exceptions: xdg.enable, nix.enable (system options)
  problematic_lines=$(grep -E "\.enable = (true|false);" "$shared_config" | grep -v "lib.mkDefault" | grep -v "xdg.enable" | grep -v "nix.enable" || true)

  if [[ -n "$problematic_lines" ]]; then
    echo -e "${RED}  ✗ $shared_config: Has enable options without lib.mkDefault${NC}"
    echo -e "${RED}    → Use lib.mkDefault to allow host configs to override${NC}"
    echo "$problematic_lines" | sed 's/^/    /'
    ERRORS=$((ERRORS + 1))
  else
    echo -e "${GREEN}  ✓ $shared_config: Uses lib.mkDefault for all module enables${NC}"
  fi
done
echo ""

# Check 4: Validate modules are imported in shared.nix
echo -e "${BLUE}Check 4: Checking all modules are imported in shared.nix${NC}"

for module in modules/home/*.nix; do
  if [[ "$module" == *"shared.nix"* ]]; then
    continue
  fi

  basename=$(basename "$module" .nix)

  if ! grep -q "homeModules\.$basename" modules/home/shared.nix; then
    echo -e "${RED}  ✗ $module: Not imported in modules/home/shared.nix${NC}"
    ERRORS=$((ERRORS + 1))
  fi
done

for module in modules/darwin/*.nix; do
  if [[ "$module" == *"shared.nix"* ]]; then
    continue
  fi

  basename=$(basename "$module" .nix)

  if ! grep -q "darwinModules\.$basename" modules/darwin/shared.nix; then
    echo -e "${RED}  ✗ $module: Not imported in modules/darwin/shared.nix${NC}"
    ERRORS=$((ERRORS + 1))
  fi
done
echo ""

# Check 5: Validate host configs import shared modules
echo -e "${BLUE}Check 5: Checking host configs import shared modules${NC}"

for host_config in hosts/*/users/*/home-configuration.nix; do
  if ! grep -q "homeModules\.shared" "$host_config"; then
    echo -e "${RED}  ✗ $host_config: Doesn't import homeModules.shared${NC}"
    ERRORS=$((ERRORS + 1))
  fi
done

for darwin_config in hosts/*/darwin-configuration.nix; do
  if ! grep -q "darwinModules\.shared" "$darwin_config"; then
    echo -e "${RED}  ✗ $darwin_config: Doesn't import darwinModules.shared${NC}"
    ERRORS=$((ERRORS + 1))
  fi
done
echo ""

# Check 6: Validate sops configuration when secrets are used
echo -e "${BLUE}Check 6: Checking sops configuration${NC}"

for host_config in hosts/*/users/*/home-configuration.nix; do
  if grep -q "sops\.secrets\." "$host_config"; then
    echo -e "Found secrets in $host_config..."

    # Check for sops.age.keyFile
    if ! grep -q "sops\.age\.keyFile" "$host_config"; then
      echo -e "${YELLOW}  ⚠ Uses secrets but sops.age.keyFile not set${NC}"
      WARNINGS=$((WARNINGS + 1))
    fi

    # Check for defaultSopsFile
    if ! grep -q "sops\.defaultSopsFile" "$host_config"; then
      echo -e "${YELLOW}  ⚠ Uses secrets but sops.defaultSopsFile not set${NC}"
      WARNINGS=$((WARNINGS + 1))
    fi
  fi
done
echo ""

# Check 7: Validate module dependencies
echo -e "${BLUE}Check 7: Checking module dependencies${NC}"

# Example: If claudeCode is enabled, sops should be configured
for host_config in hosts/*/users/*/home-configuration.nix; do
  if grep -q "claudeCode\.enable = true" "$host_config"; then
    if ! grep -q "sops\.secrets\." "$host_config"; then
      echo -e "${YELLOW}  ⚠ $host_config: claudeCode enabled but no sops secrets configured${NC}"
      echo -e "${YELLOW}    → Claude Code typically needs auth tokens from secrets${NC}"
      WARNINGS=$((WARNINGS + 1))
    fi
  fi
done
echo ""

# Summary
echo -e "${BLUE}=== Validation Summary ===${NC}"
if [[ $ERRORS -eq 0 ]] && [[ $WARNINGS -eq 0 ]]; then
  echo -e "${GREEN}✓ All configuration checks passed!${NC}"
  exit 0
elif [[ $ERRORS -eq 0 ]]; then
  echo -e "${YELLOW}⚠ Validation passed with $WARNINGS warning(s)${NC}"
  exit 0
else
  echo -e "${RED}✗ Validation failed with $ERRORS error(s) and $WARNINGS warning(s)${NC}"
  exit 1
fi
