{...}: {
  imports = [
    ./ai-instructions.nix
    ./claude/claude-code.nix
    ./claude/agents.nix
    ./claude/slash-commands.nix
    ./docker.nix
    ./gemini-cli.nix
    ./mcp.nix
    ./npm.nix
    ./nvim
    ./opencode.nix
    ./opencode-nvim.nix
    ./python.nix
    ./tools.nix
  ];
}
