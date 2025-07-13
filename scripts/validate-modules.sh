#!/usr/bin/env bash
# Validate all modules have proper structure, documentation, and options

set -euo pipefail

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Module Validation Suite ===${NC}"
echo ""

ERRORS=0
WARNINGS=0

# Check 1: All modules have enable options
echo -e "${BLUE}Check 1: Verifying all modules have enable options${NC}"
for module in modules/{home,darwin}/*.nix; do
  # Skip shared.nix files
  if [[ "$module" == *"shared.nix"* ]]; then
    continue
  fi

  basename=$(basename "$module" .nix)

  # Check for mkEnableOption
  if ! grep -q "mkEnableOption" "$module"; then
    echo -e "${RED}  ✗ $module: Missing mkEnableOption${NC}"
    ERRORS=$((ERRORS + 1))
  else
    echo -e "${GREEN}  ✓ $module: Has enable option${NC}"
  fi
done
echo ""

# Check 2: All modules have proper option types
echo -e "${BLUE}Check 2: Verifying options have proper types${NC}"
for module in modules/{home,darwin}/*.nix; do
  if [[ "$module" == *"shared.nix"* ]]; then
    continue
  fi

  basename=$(basename "$module" .nix)

  # Check for mkOption without type
  if grep -q "mkOption" "$module"; then
    # Count mkOptions and types, allowing for multiline definitions
    option_lines=$(grep -n "mkOption" "$module" | wc -l | tr -d ' ')
    type_lines=$(grep -n "type = " "$module" | wc -l | tr -d ' ')

    if [[ "$type_lines" -lt "$option_lines" ]]; then
      echo -e "${YELLOW}  ⚠ $module: Has $option_lines mkOptions but only $type_lines type declarations${NC}"
      WARNINGS=$((WARNINGS + 1))
    else
      echo -e "${GREEN}  ✓ $module: Options have types${NC}"
    fi
  fi
done
echo ""

# Check 3: Modules are documented in MODULE_OPTIONS.md
echo -e "${BLUE}Check 3: Verifying modules are documented${NC}"
for module in modules/home/*.nix; do
  if [[ "$module" == *"shared.nix"* ]]; then
    continue
  fi

  basename=$(basename "$module" .nix)

  # Extract module name from the file
  module_name=$(grep -E "config\.[a-zA-Z]+" "$module" | head -1 | sed -E 's/.*config\.([a-zA-Z]+).*/\1/' || echo "")

  if [[ -n "$module_name" ]]; then
    if grep -q "$module_name" docs/MODULE_OPTIONS.md; then
      echo -e "${GREEN}  ✓ $module ($module_name): Documented${NC}"
    else
      echo -e "${YELLOW}  ⚠ $module ($module_name): Not found in MODULE_OPTIONS.md${NC}"
      WARNINGS=$((WARNINGS + 1))
    fi
  fi
done
echo ""

# Check 4: Modules have descriptions
echo -e "${BLUE}Check 4: Verifying options have descriptions${NC}"
for module in modules/{home,darwin}/*.nix; do
  if [[ "$module" == *"shared.nix"* ]]; then
    continue
  fi

  basename=$(basename "$module" .nix)

  # Count mkOption occurrences
  option_count=$(grep -c "mkOption" "$module" || echo "0")

  if [[ "$option_count" -gt 0 ]]; then
    # Count description occurrences
    desc_count=$(grep -c "description = " "$module" || echo "0")

    if [[ "$desc_count" -lt "$option_count" ]]; then
      echo -e "${YELLOW}  ⚠ $module: Has $option_count options but only $desc_count descriptions${NC}"
      WARNINGS=$((WARNINGS + 1))
    else
      echo -e "${GREEN}  ✓ $module: All options have descriptions${NC}"
    fi
  fi
done
echo ""

# Check 5: Modules use lib.mkIf for conditional config
echo -e "${BLUE}Check 5: Verifying modules use lib.mkIf for conditional configuration${NC}"
for module in modules/{home,darwin}/*.nix; do
  if [[ "$module" == *"shared.nix"* ]]; then
    continue
  fi

  basename=$(basename "$module" .nix)

  # Check for config section with mkIf
  if grep -q "config = lib.mkIf" "$module"; then
    echo -e "${GREEN}  ✓ $module: Uses lib.mkIf for conditional config${NC}"
  elif grep -q "config = {" "$module" || grep -q "config =" "$module"; then
    echo -e "${RED}  ✗ $module: Has config but missing lib.mkIf (always active)${NC}"
    ERRORS=$((ERRORS + 1))
  fi
done
echo ""

# Check 6: Module names follow conventions
echo -e "${BLUE}Check 6: Verifying module naming conventions${NC}"
for module in modules/home/*.nix; do
  if [[ "$module" == *"shared.nix"* ]]; then
    continue
  fi

  basename=$(basename "$module" .nix)

  # Extract config name from module
  config_name=$(grep -oE "config\.[a-zA-Z]+" "$module" | head -1 | cut -d'.' -f2 || echo "")

  if [[ -n "$config_name" ]]; then
    # Check naming pattern: customX or XTools
    if [[ "$config_name" =~ ^custom[A-Z] ]] || [[ "$config_name" =~ Tools$ ]]; then
      echo -e "${GREEN}  ✓ $module ($config_name): Follows naming convention${NC}"
    else
      echo -e "${YELLOW}  ⚠ $module ($config_name): Doesn't follow 'customX' or 'XTools' pattern${NC}"
      WARNINGS=$((WARNINGS + 1))
    fi
  fi
done
echo ""

# Summary
echo -e "${BLUE}=== Validation Summary ===${NC}"
if [[ $ERRORS -eq 0 ]] && [[ $WARNINGS -eq 0 ]]; then
  echo -e "${GREEN}✓ All checks passed!${NC}"
  exit 0
elif [[ $ERRORS -eq 0 ]]; then
  echo -e "${YELLOW}⚠ Validation passed with $WARNINGS warning(s)${NC}"
  exit 0
else
  echo -e "${RED}✗ Validation failed with $ERRORS error(s) and $WARNINGS warning(s)${NC}"
  exit 1
fi
