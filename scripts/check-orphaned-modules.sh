#!/usr/bin/env bash
# Check for orphaned module files that are not imported anywhere

set -euo pipefail

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "Checking for orphaned modules..."

# Find all .nix files in modules/
modules=$(find modules -name "*.nix" -type f | sort)

orphaned=()
checked=0

for module in $modules; do
  checked=$((checked + 1))

  # Extract the basename without extension
  basename=$(basename "$module" .nix)

  # Get the module path relative to modules/ directory
  # e.g., modules/home/git.nix -> home/git or darwin/fonts
  rel_path="${module#modules/}"
  dir_name=$(dirname "$rel_path")

  # Check if this module is imported anywhere in the codebase
  # Look for patterns like:
  # - inputs.self.homeModules.git
  # - inputs.self.darwinModules.fonts
  # - ./git.nix or ../home/git.nix

  # Build search patterns
  module_ref1="${dir_name}Modules.${basename}"  # e.g., homeModules.git
  module_ref2="./${basename}.nix"                # e.g., ./git.nix
  module_ref3="${basename}.nix"                  # e.g., git.nix in imports

  # Search for any references to this module
  if ! grep -rq --include="*.nix" \
       -e "$module_ref1" \
       -e "$module_ref2" \
       -e "$module_ref3" \
       --exclude-dir=".git" \
       --exclude="$module" \
       . ; then
    orphaned+=("$module")
  fi
done

# Report results
echo ""
echo "Checked $checked module files"
echo ""

if [ ${#orphaned[@]} -eq 0 ]; then
  echo -e "${GREEN}✓ No orphaned modules found${NC}"
  exit 0
else
  echo -e "${RED}✗ Found ${#orphaned[@]} orphaned module(s):${NC}"
  echo ""
  for module in "${orphaned[@]}"; do
    echo -e "  ${YELLOW}$module${NC}"
  done
  echo ""
  echo "These modules are not imported anywhere in the codebase."
  echo "Consider importing them or removing them if they're no longer needed."
  exit 1
fi
