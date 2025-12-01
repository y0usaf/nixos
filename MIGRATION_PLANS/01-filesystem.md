# 01: Filesystem Structure

## Target Structure

```
flake.nix                           # Minimal: inputs + mkFlake
modules/
├── flake/                          # Flake orchestration
│   ├── default.nix                 # Imports only
│   ├── nixos.nix                   # nixosConfigurations
│   ├── darwin.nix                  # darwinConfigurations
│   ├── overlays.nix
│   └── formatter.nix
├── dev/                            # Dev tools
│   ├── nvim.nix                    # Both platforms
│   ├── git.nix
│   └── claude-code.nix
├── shell/                          # Shell config
│   ├── zsh.nix
│   └── zellij.nix
├── system/                         # System-level
│   ├── nixos_boot.nix              # NixOS only
│   ├── nixos_nvidia.nix
│   ├── nixos_niri.nix
│   ├── darwin_raycast.nix          # Darwin only
│   └── darwin_aerospace.nix
├── user/                           # User-level
│   ├── nixos_gaming/               # NixOS only folder
│   └── browsers.nix                # Both platforms
├── services/
│   ├── nixos_docker.nix
│   └── syncthing.nix
└── hosts/
    ├── y0usaf-desktop.nix
    ├── y0usaf-laptop.nix
    ├── y0usaf-server.nix
    └── y0usaf-macbook.nix
```

## Conventions

### Naming

| Pattern | Meaning |
|---------|---------|
| `name.nix` | Cross-platform |
| `nixos_name.nix` | NixOS only |
| `darwin_name.nix` | Darwin only |

### Options: `cfg.*` namespace

```nix
# All custom options under config.cfg.*
options.cfg.programs.nvim.enable = ...;
options.cfg.hardware.nvidia.enable = ...;
```

### hjem alias: `my`

```nix
my.files.".config/foo" = { ... };
my.packages = [ pkgs.bar ];
```

Setup: `(lib.mkAliasOptionModule ["my"] ["hjem" "users" config.user.name])`

## Key Mappings

| Current | Target |
|---------|--------|
| `lib/*` | Merge into `modules/*/` |
| `nixos/system/*` | `modules/system/nixos_*` |
| `nixos/user/*` | `modules/*/nixos_*` or merge |
| `darwin/system/*` | `modules/system/darwin_*` |
| `darwin/user/*` | `modules/*/darwin_*` or merge |
| `configs/hosts/*` | `modules/hosts/*` |

## Delete

- `nixos/lib/` - orchestration moves to modules/flake/
- `lib/claude-code/{skills,agents,scripts}/` - empty
- Flake inputs: `flake-utils`, `zjstatus`, `zjstatus-hints`

## Migration Order

1. Set up flake-parts in flake.nix
2. Create modules/flake/ skeleton
3. Migrate cross-platform modules
4. Migrate platform-specific modules
5. Convert hosts to option toggles
6. Delete old structure
7. Test builds
