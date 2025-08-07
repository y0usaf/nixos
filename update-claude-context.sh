#!/usr/bin/env bash
set -euo pipefail

# Update CLAUDE.md with current default.nix contents
# This script embeds the full default.nix file contents into CLAUDE.md

NIXOS_DIR="/home/y0usaf/nixos"
CLAUDE_MD="$NIXOS_DIR/CLAUDE.md"
DEFAULT_NIX="$NIXOS_DIR/default.nix"

# Backup existing CLAUDE.md
if [[ -f "$CLAUDE_MD" ]]; then
    cp "$CLAUDE_MD" "$CLAUDE_MD.backup.$(date +%s)"
fi

# Create/update CLAUDE.md with embedded default.nix
cat > "$CLAUDE_MD" << 'EOF'
# NixOS System Configuration Context

This file contains the complete NixOS system configuration for immediate Claude context.
Auto-generated during system builds to ensure Claude always has current config.

## Current System Configuration

The complete `default.nix` file contents:

```nix
EOF

# Embed the actual default.nix contents
cat "$DEFAULT_NIX" >> "$CLAUDE_MD"

# Close the code block and add footer
echo '```' >> "$CLAUDE_MD"
echo '' >> "$CLAUDE_MD"
echo '## Usage Instructions' >> "$CLAUDE_MD"
echo '' >> "$CLAUDE_MD"
echo 'Claude now has the complete system configuration in context. Use this information to:' >> "$CLAUDE_MD"
echo '- Understand current system setup' >> "$CLAUDE_MD"
echo '- Make informed configuration changes' >> "$CLAUDE_MD"
echo '- Suggest improvements and optimizations' >> "$CLAUDE_MD"
echo '- Debug configuration issues' >> "$CLAUDE_MD"
echo '' >> "$CLAUDE_MD"
echo "Generated: $(date)" >> "$CLAUDE_MD"
echo "Configuration file: default.nix" >> "$CLAUDE_MD"
echo "Total lines: $(wc -l < "$DEFAULT_NIX")" >> "$CLAUDE_MD"

echo "✅ CLAUDE.md updated with current default.nix contents ($(wc -l < "$DEFAULT_NIX") lines)"