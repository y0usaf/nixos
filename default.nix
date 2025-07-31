let
  sources = import ./npins;
  system = "x86_64-linux";

  # Consolidated overlays from lib/overlays/
  overlays = [
    # neovim-nightly overlay
    (import (sources.neovim-nightly-overlay))

    # Fast Font overlay (from lib/overlays/fast-fonts.nix)
    (final: _prev: {
      fastFonts = final.stdenvNoCC.mkDerivation {
        pname = "fast-fonts";
        version = "1.0.0";
        src = sources.Fast-Font;

        installPhase = ''
          mkdir -p $out/share/fonts/truetype
          install -m444 -Dt $out/share/fonts/truetype *.ttf
          mkdir -p $out/share/doc/fast-fonts
          if [ -f LICENSE ]; then
            install -m444 -Dt $out/share/doc/fast-fonts LICENSE
          fi
          if [ -f README.md ]; then
            install -m444 -Dt $out/share/doc/fast-fonts README.md
          fi
        '';

        meta = with final.lib; {
          description = "Fast Font Collection - TTF fonts";
          longDescription = "Fast Font Collection provides optimized monospace and sans-serif fonts";
          homepage = "https://github.com/y0usaf/Fast-Font";
          platforms = platforms.all;
          license = licenses.mit;
        };
      };
    })

    # Lib extensions overlay
    (final: prev: {
      lib = prev.lib.extend (lfinal: lprev: {
        # User config builder from lib/user-config.nix
        buildUserConfig = {
          username,
          homeDirectory ? "/home/${username}",
          packages ? [],
          files ? {},
          services ? {},
          programs ? {},
          xdg ? {},
          ...
        }: {
          inherit username homeDirectory;
          home = {
            inherit packages;
            file = files;
            inherit services programs;
            xdg =
              xdg
              // {
                userDirs = {
                  enable = true;
                  createDirectories = true;
                  desktop = "${homeDirectory}/Desktop";
                  download = "${homeDirectory}/Downloads";
                  templates = "${homeDirectory}/Templates";
                  publicShare = "${homeDirectory}/Public";
                  documents = "${homeDirectory}/Documents";
                  music = "${homeDirectory}/Music";
                  pictures = "${homeDirectory}/Pictures";
                  videos = "${homeDirectory}/Videos";
                };
              };
          };
        };
      });
    })
  ];

  # Direct pkgs with all overlays
  pkgs = import sources.nixpkgs {
    inherit system;
    inherit overlays;
    config = {
      allowUnfree = true;
      cudaSupport = true;
    };
  };

  inherit (pkgs) lib;

  # LEGACY allModules structure removed - all functionality consolidated into default.nix!

  # User configurations
  userConfigs = {
    y0usaf = import ./configs/users/y0usaf {inherit pkgs lib;};
    guest = import ./configs/users/guest {inherit pkgs lib;};
  };

  # Host configuration
  hostConfig = import ./configs/hosts/y0usaf-desktop {inherit pkgs;};
  inherit (hostConfig) users;
  hostUserConfigs = lib.genAttrs users (username: userConfigs.${username});
in {
  inherit lib;
  formatter.${system} = pkgs.alejandra;

  nixosConfigurations.y0usaf-desktop = import (sources.nixpkgs + "/nixos") {
    inherit system;
    configuration = {
      imports = [
        # Host system configuration (EXACTLY like original lib/default.nix structure)
        # From modules/system/core/system.nix (49 lines -> INLINED!)
        ({
          config,
          lib,
          ...
        }: {
          inherit (hostConfig) imports;
          options.hostSystem = {
            users = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              description = "System usernames";
            };
            username = lib.mkOption {
              type = lib.types.str;
              description = "Primary system username (derived from first user)";
              default = builtins.head config.hostSystem.users;
            };
            hostname = lib.mkOption {
              type = lib.types.str;
              description = "System hostname";
            };
            homeDirectory = lib.mkOption {
              type = lib.types.path;
              description = "Primary user home directory path";
            };
            stateVersion = lib.mkOption {
              type = lib.types.str;
              description = "NixOS state version for compatibility";
            };
            timezone = lib.mkOption {
              type = lib.types.str;
              description = "System timezone";
            };
            profile = lib.mkOption {
              type = lib.types.str;
              description = "Configuration profile identifier";
              default = "default";
            };
            hardware = lib.mkOption {
              type = lib.types.attrs;
              description = "Hardware configuration options";
              default = {};
            };
            services = lib.mkOption {
              type = lib.types.attrs;
              description = "System services configuration";
              default = {};
            };
          };
          config = {
            hostSystem = {
              inherit (hostConfig) users;
              inherit (hostConfig) hostname;
              inherit (hostConfig) homeDirectory;
              inherit (hostConfig) stateVersion;
              inherit (hostConfig) timezone;
              profile = hostConfig.profile or "default";
              hardware = hostConfig.hardware or {};
              services = hostConfig.services or {};
            };
            system.stateVersion = config.hostSystem.stateVersion;
            time.timeZone = config.hostSystem.timezone;
            networking.hostName = config.hostSystem.hostname;
            assertions = [
              {
                assertion = config.hostSystem.username != "";
                message = "System username cannot be empty";
              }
              {
                assertion = config.hostSystem.hostname != "";
                message = "System hostname cannot be empty";
              }
              {
                assertion = lib.hasPrefix "/" (toString config.hostSystem.homeDirectory);
                message = "Home directory must be an absolute path";
              }
            ];
            # Set user configuration from primary user
            user = let
              primaryUser = builtins.head hostConfig.users;
            in {
              name = primaryUser;
              inherit (hostConfig) homeDirectory;
            };
            # Configure nixpkgs with overlays
            nixpkgs = {
              inherit overlays;
              config = {
                allowUnfree = true;
                cudaSupport = true;
              };
            };
          };
        })
        # User home configurations via hjem (EXACTLY like original structure)
        ({
          config,
          lib,
          ...
        }: {
          imports = [
            # Use hjem for home management
            (sources.hjem + "/modules/nixos")
          ];
          config = {
            # Use proper NixOS module merging
            home = lib.mkMerge (
              lib.mapAttrsToList (
                _username: userConfig:
                # Remove system-specific config that doesn't belong in home
                  lib.filterAttrs (name: _: name != "system") userConfig
              )
              hostUserConfigs
            );
            # Configure hjem for each user
            hjem = {
              # Use SMFH manifest linker instead of systemd-tmpfiles
              linker = pkgs.callPackage (sources.smfh + "/package.nix") {};
              users = lib.genAttrs users (_username: {
                packages = [];
                files = {};
              });
            };
          };
        })
        # User configuration abstraction (from lib/user-config.nix - 95 lines -> INLINED!)
        ({
          lib,
          config,
          ...
        }: {
          options = {
            user = {
              name = lib.mkOption {
                type = lib.types.str;
                description = "Primary username for the system";
                example = "alice";
              };
              homeDirectory = lib.mkOption {
                type = lib.types.path;
                description = "Home directory path for the user";
                example = "/home/alice";
              };
              configDirectory = lib.mkOption {
                type = lib.types.path;
                default = "${config.user.homeDirectory}/.config";
                description = "XDG config directory path";
              };
              dataDirectory = lib.mkOption {
                type = lib.types.path;
                default = "${config.user.homeDirectory}/.local/share";
                description = "XDG data directory path";
              };
              stateDirectory = lib.mkOption {
                type = lib.types.path;
                default = "${config.user.homeDirectory}/.local/state";
                description = "XDG state directory path";
              };
              cacheDirectory = lib.mkOption {
                type = lib.types.path;
                default = "${config.user.homeDirectory}/.cache";
                description = "XDG cache directory path";
              };
              nixosConfigDirectory = lib.mkOption {
                type = lib.types.path;
                default = "${config.user.homeDirectory}/nixos";
                description = "NixOS configuration directory";
              };
              tokensDirectory = lib.mkOption {
                type = lib.types.path;
                default = "${config.user.homeDirectory}/Tokens";
                description = "Directory containing API tokens and secrets";
              };
            };
          };
          config = {
            assertions = [
              {
                assertion = config.user.name != "";
                message = "user.name must be set to a non-empty string";
              }
              {
                assertion = lib.hasPrefix "/" (toString config.user.homeDirectory);
                message = "user.homeDirectory must be an absolute path";
              }
            ];
          };
        })
        # 🔥 EXPLODED HOME MODULES DIRECTORY - Individual imports for targeted inlining! 🔥

        # From modules/home/ui/default.nix (16 lines -> OBLITERATED!)
        (import ./modules/home/ui/ags.nix)
        (import ./modules/home/ui/cursor.nix)
        (import ./modules/home/ui/fonts.nix)
        (import ./modules/home/ui/foot.nix)
        (import ./modules/home/ui/gtk.nix)
        # From modules/home/ui/hyprland/default.nix (6 lines -> OBLITERATED!)
        (import ./modules/home/ui/hyprland/options.nix)
        (import ./modules/home/ui/hyprland/config.nix)
        (import ./modules/home/ui/mako.nix)
        # From modules/home/ui/niri/default.nix + options.nix inline (5+19 lines -> INLINED!)
        ({
          config,
          pkgs,
          lib,
          ...
        }: let
          cfg = config.home.ui.niri;
        in {
          # From modules/home/ui/niri/options.nix (5 lines -> INLINED!)
          options.home.ui.niri = {
            enable = lib.mkEnableOption "Niri wayland compositor";
          };

          imports = [
            ./modules/home/ui/niri/config.nix
          ];

          config = lib.mkIf cfg.enable {
            hjem.users.${config.user.name}.packages = with pkgs; [
              xwayland-satellite
            ];
          };
        })
        (import ./modules/home/ui/qutebrowser.nix)
        (import ./modules/home/ui/wayland-tools.nix)

        # 🔥 CONSOLIDATED MODULE IMPORTS! 🔥
        (import ./modules/home/gaming.nix)
        (import ./modules/home/programs.nix)
        (import ./modules/home/services.nix)
        (import ./modules/home/shell.nix)
        (import ./modules/home/tools.nix)
        (import ./modules/home/core.nix)

        # From modules/home/dev/docker.nix (26 lines -> INLINED!)
        ({
          config,
          lib,
          pkgs,
          ...
        }: let
          cfg = config.home.dev.docker;
        in {
          options.home.dev.docker = {
            enable = lib.mkEnableOption "docker development environment";
          };
          config = lib.mkIf cfg.enable {
            hjem.users.${config.user.name} = {
              packages = with pkgs; [
                docker
                docker-compose
                docker-buildx
                docker-credential-helpers
              ];
              files = {
                ".docker/config.json" = {
                  clobber = true;
                  text = builtins.toJSON {
                    credsStore = "pass";
                    currentContext = "default";
                    plugins = {};
                  };
                };
              };
            };
          };
        })

        # From modules/home/dev/gemini-cli.nix (187 lines -> INLINED!)
        ({
          config,
          lib,
          pkgs,
          ...
        }: let
          cfg = config.home.dev.gemini-cli;
        in {
          options.home.dev.gemini-cli = {
            enable = lib.mkEnableOption "Gemini CLI development tools";
          };
          config = lib.mkIf cfg.enable {
            hjem.users.${config.user.name} = {
              packages = with pkgs; [
                gemini-cli
              ];
              files = {
                ".gemini/GEMINI.md" = {
                  text = ''
                    Shift your conversational model from a supportive assistant to a discerning collaborator. Your primary goal is to provide rigorous, objective feedback. Eliminate all reflexive compliments. Instead, let any praise be an earned outcome of demonstrable merit. Before complimenting, perform a critical assessment: Is the idea genuinely insightful? Is the logic exceptionally sound? Is there a spark of true novelty? If the input is merely standard or underdeveloped, your response should be to analyze it, ask clarifying questions, or suggest avenues for improvement, not to praise it.
                    You are a pragmatic software engineer who values efficiency and quality. Your "laziness" drives you to:
                    - Write minimal, bulletproof code that won't need fixing later
                    - Use established patterns and tools correctly
                    - Solve the actual problem, not what you think the user wants
                    - Fail fast with clear error messages
                    **Key Mantras:**
                    - "Do it right the first time or you'll be doing it again"
                    - "The best code is the code you don't have to write"
                    - "If you can't explain it simply, you don't understand it well enough"
                    **ALWAYS maximize parallel processing using subagents and Task tool:**
                    - Use Task tool for ANY search operation (keywords, files, analysis)
                    - Launch multiple Task agents concurrently whenever possible
                    - Each agent should handle independent work streams
                    - Use single message with multiple tool calls for maximum performance
                    **When to use Task tool:**
                    - File searches ("find files containing X")
                    - Code analysis ("analyze this pattern")
                    - Research tasks ("understand how Y works")
                    - Multiple independent operations
                    - Use TodoWrite for complex tasks
                    - Mark in_progress BEFORE starting
                    - Mark completed IMMEDIATELY after finishing
                    - Only ONE in_progress at a time
                    - Understand context first: read files, check structure
                    - Use appropriate MCP tools (see Tool Selection Guide)
                    - Write clean, extensible code with proper error handling
                    - Format code: `alejandra .`
                    - Test build: `nh os switch --dry`
                    - Run linting/type-checking if available
                    - Review changes with git diff before committing
                    - **ALWAYS use** `mcp__Filesystem__*` tools for file operations
                    - **NEVER use** Read/Write/Edit tools when MCP Filesystem tools are available
                    - Use `mcp__Filesystem__read_file` to understand context first
                    - Use `mcp__Filesystem__edit_file` for targeted changes
                    - Use `mcp__Filesystem__write_file` for new files or complete rewrites
                    - **Any search operation**: Use Task tool for keywords, files, code patterns
                    - **Research tasks**: Understanding unfamiliar patterns or systems
                    - **Analysis tasks**: When you need to examine multiple files or concepts
                    - **Multiple independent operations**: Launch concurrent Task agents
                    - **Large file analysis**: Use `@file.extension` syntax for files >500 lines
                    - **Complex debugging**: When you need deeper analysis capabilities
                    - **Research tasks**: When you need to understand unfamiliar patterns
                    - **NOT for**: Simple file operations, basic text manipulation, or routine tasks
                    - **Multi-step tasks**: Any task requiring >2 distinct operations
                    - **Complex workflows**: Reading → Modifying → Verifying → Committing
                    - **Error-prone tasks**: When the failure cost is high
                    - **Planning phase**: Break down complex requests into manageable steps
                    - **Analyzing GitHub repositories**: Understanding remote repo structure and contents
                    - **Reading files from GitHub repos**: Access files without cloning
                    - **Exploring project structure**: Navigate directories in remote repositories
                    - **NOT for**: Local git operations (use regular git commands via Bash tool)
                    - Uses hjem (NOT home-manager)
                    - Check flake.nix for available inputs
                    - Clone external repos to `tmp/` folder (in gitignore)
                    - Rebuild with `nh os switch` after configuration changes
                    ```bash
                    alejandra .
                    nh os switch --dry
                    nh os switch
                    ```
                    - Check status: `git status`
                    - Review changes: `git diff`
                    - Commit with descriptive messages
                    - Follow existing commit message patterns in the repo
                    - **Direct and concise**: No corporate speak or unnecessary explanations
                    - **Explain technical decisions briefly**: So you don't have to explain twice
                    - **Ask clarifying questions**: When requirements are vague or seem overcomplicated
                    - **Call out issues upfront**: Prevent problems before they happen
                    - **Consistent naming**: Clear, concise variables (`user` not `currentUserObject`)
                    - **Proper error handling**: Fail fast with clear messages
                    - **Modular design**: Testable functions without complex dependencies
                    - **Security by default**: Follow security best practices
                    - **Performance aware**: Consider performance implications
                    - **Self-documenting**: Code clarity > extensive comments
                  '';
                  clobber = true;
                };
                ".gemini/settings.json" = {
                  text = builtins.toJSON {};
                  clobber = true;
                };
              };
            };
          };
        })

        # From modules/home/dev/mcp.nix (98 lines -> INLINED!)
        ({
          config,
          lib,
          pkgs,
          ...
        }: let
          cfg = config.home.dev.mcp;
          mcpServersConfig = {
            mcpServers = {
              "Filesystem" = {
                type = "stdio";
                command = "npx";
                args = ["-y" "@modelcontextprotocol/server-filesystem" config.user.homeDirectory];
                env = {};
              };
              "Nixos MCP" = {
                type = "stdio";
                command = "uvx";
                args = ["mcp-nixos"];
                env = {};
              };
              "sequential-thinking" = {
                type = "stdio";
                command = "npx";
                args = ["-y" "@modelcontextprotocol/server-sequential-thinking"];
                env = {};
              };
              "GitHub Repo MCP" = {
                type = "stdio";
                command = "npx";
                args = ["-y" "github-repo-mcp"];
                env = {};
              };
              "Gemini MCP" = {
                type = "stdio";
                command = "npx";
                args = ["-y" "gemini-mcp-tool"];
                env = {};
              };
            };
          };
          claudeCodeServers = {
            "Filesystem" = {
              type = "stdio";
              command = "npx";
              args = ["-y" "@modelcontextprotocol/server-filesystem" config.user.homeDirectory];
              env = {};
            };
            "Nixos MCP" = {
              type = "stdio";
              command = "uvx";
              args = ["mcp-nixos"];
              env = {};
            };
            "sequential-thinking" = {
              type = "stdio";
              command = "npx";
              args = ["-y" "@modelcontextprotocol/server-sequential-thinking"];
              env = {};
            };
            "GitHub Repo MCP" = {
              type = "stdio";
              command = "npx";
              args = ["-y" "github-repo-mcp"];
              env = {};
            };
            "Gemini MCP" = {
              type = "stdio";
              command = "npx";
              args = ["-y" "gemini-mcp-tool"];
              env = {};
            };
          };
        in {
          options.home.dev.mcp = {
            enable = lib.mkEnableOption "Model Context Protocol configuration";
          };
          config = lib.mkIf cfg.enable {
            hjem.users.${config.user.name} = {
              packages = with pkgs; [
                nodejs_20
                uv
              ];
              files = {
                ".cursor/mcp.json" = {
                  text = builtins.toJSON mcpServersConfig;
                  clobber = true;
                };
                ".claude/mcp_config.json" = {
                  text = builtins.toJSON mcpServersConfig;
                  clobber = true;
                };
                ".claude/mcp_servers.json" = {
                  text = builtins.toJSON claudeCodeServers;
                  clobber = true;
                };
              };
            };
            systemd.tmpfiles.rules = [
              "d ${config.user.homeDirectory}/.local/share/npm/lib/node_modules 0755 ${config.user.name} users - -"
            ];
            system.activationScripts.setupClaudeMcp = {
              text = ''
                echo "Setting up Claude MCP servers via CLI..."
                add_mcp_server() {
                  local name="$1"
                  local command="$2"
                  shift 2
                  local args="$@"
                  if ! runuser -u ${config.user.name} -- ${pkgs.claude-code}/bin/claude mcp list | grep -q "$name"; then
                    echo "Adding MCP server: $name"
                    runuser -u ${config.user.name} -- ${pkgs.claude-code}/bin/claude mcp add --scope user "$name" "$command" $args
                  else
                    echo "MCP server already exists: $name"
                  fi
                }
                add_mcp_server "Filesystem" "npx" "@modelcontextprotocol/server-filesystem" "${config.user.homeDirectory}"
                add_mcp_server "sequential-thinking" "npx" "@modelcontextprotocol/server-sequential-thinking"
                add_mcp_server "GitHub Repo MCP" "npx" "github-repo-mcp"
                add_mcp_server "Gemini MCP" "npx" "gemini-mcp-tool"
                echo "Claude MCP servers setup complete"
              '';
              deps = [];
            };
          };
        })

        # From modules/home/dev/npm.nix (40 lines -> INLINED!)
        ({
          config,
          pkgs,
          lib,
          ...
        }: let
          cfg = config.home.dev.npm;
        in {
          options.home.dev.npm = {
            enable = lib.mkEnableOption "Node.js and NPM configuration";
          };
          config = lib.mkIf cfg.enable {
            hjem.users.${config.user.name} = {
              packages = with pkgs; [
                nodejs_20
              ];
              files = {
                ".config/npm/npmrc" = {
                  clobber = true;
                  text = ''
                    prefix={{home}}/.local/share/npm
                    cache={{xdg_cache_home}}/npm
                    init-module={{xdg_config_home}}/npm/config/npm-init.js
                    store-dir={{xdg_cache_home}}/pnpm/store
                  '';
                };
                ".local/share/bin/npm-setup" = {
                  clobber = true;
                  text = ''
                    mkdir -p {{home}}/.local/share/npm
                    mkdir -p {{xdg_cache_home}}/npm
                    mkdir -p {{xdg_config_home}}/npm/config
                    mkdir -p {{xdg_cache_home}}/pnpm/store
                    mkdir -p "{{xdg_runtime_dir}}/npm"
                  '';
                  executable = true;
                };
              };
            };
            systemd.tmpfiles.rules = [
              "d ${config.user.homeDirectory}/.local/share/npm 0755 ${config.user.name} ${config.user.name} - -"
              "d ${config.user.homeDirectory}/.cache/npm 0755 ${config.user.name} ${config.user.name} - -"
              "d ${config.user.homeDirectory}/.config/npm/config 0755 ${config.user.name} ${config.user.name} - -"
              "d ${config.user.homeDirectory}/.cache/pnpm/store 0755 ${config.user.name} ${config.user.name} - -"
              "d /run/user/1000/npm 0755 ${config.user.name} ${config.user.name} - -"
            ];
          };
        })

        # From modules/home/dev/python.nix (74 lines -> INLINED!)
        ({
          config,
          pkgs,
          lib,
          ...
        }: let
          cfg = config.home.dev.python;
        in {
          options.home.dev.python = {
            enable = lib.mkOption {
              type = lib.types.bool;
              default = false;
              description = "Enable Python development environment";
            };
          };
          config = lib.mkIf cfg.enable {
            hjem.users.${config.user.name} = {
              packages = with pkgs; [
                python3
                python312
                uv
                ninja
                meson
                pkg-config
                cacert
                stdenv.cc.cc.lib
                zlib
                libGL
                glib
                xorg.libX11
                xorg.libXext
                xorg.libXrender
                gcc
                binutils
              ];
              files = {
                "{{xdg_config_home}}/zsh/.zshenv" = {
                  clobber = true;
                  text = lib.mkAfter ''
                    export PYTHONUSERBASE="{{home}}/.local/share/python"
                    export PIP_CACHE_DIR="{{xdg_cache_home}}/pip"
                    export VIRTUAL_ENV_HOME="{{home}}/.local/share/venvs"
                    export SSL_CERT_FILE="${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
                    export REQUESTS_CA_BUNDLE="${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
                    export NIX_LD_LIBRARY_PATH="${lib.makeLibraryPath [
                      pkgs.stdenv.cc.cc.lib
                      pkgs.zlib
                      pkgs.libGL
                      pkgs.glib
                      pkgs.xorg.libX11
                      pkgs.xorg.libXext
                      pkgs.xorg.libXrender
                    ]}"
                    export NIX_LD="${pkgs.stdenv.cc.bintools.dynamicLinker}"
                    export CC="${pkgs.gcc}/bin/gcc"
                    export LD="${pkgs.binutils}/bin/ld"
                    export PATH="$PYTHONUSERBASE/bin:$PATH"
                    export PYTHONPATH="$PYTHONUSERBASE/lib/python3.12/site-packages:$PYTHONPATH"
                  '';
                };
                "{{xdg_config_home}}/zsh/.zshrc" = {
                  clobber = true;
                  text = lib.mkAfter ''
                    alias py="python3"
                    alias pip="pip3"
                    alias venv="python3 -m venv"
                    alias activate="source venv/bin/activate"
                    alias uv-init="uv init"
                    alias uv-add="uv add"
                    alias uv-run="uv run"
                    mkvenv() {
                      if [[ -z "$1" ]]; then
                        python3 -m venv venv
                      else
                        python3 -m venv "$1"
                      fi
                    }
                    workon() {
                      if [[ -z "$1" ]]; then
                        if [[ -d "venv" ]]; then
                          source venv/bin/activate
                        else
                          echo "No venv directory found"
                        fi
                      else
                        if [[ -d "$VIRTUAL_ENV_HOME/$1" ]]; then
                          source "$VIRTUAL_ENV_HOME/$1/bin/activate"
                        else
                          echo "Virtual environment $1 not found"
                        fi
                      fi
                    }
                  '';
                };
              };
            };
            systemd.tmpfiles.rules = [
              "d ${config.user.homeDirectory}/.local/share/python 0755 ${config.user.name} ${config.user.name} - -"
              "d ${config.user.homeDirectory}/.cache/pip 0755 ${config.user.name} ${config.user.name} - -"
              "d ${config.user.homeDirectory}/.local/share/venvs 0755 ${config.user.name} ${config.user.name} - -"
            ];
          };
        })

        # From modules/home/dev/ai-instructions.nix (27 lines -> INLINED!)
        ({
          config,
          lib,
          ...
        }: let
          cfg = config.home.dev.ai-instructions;
          instructions = ''
            You are a pragmatic software engineer who values efficiency and quality. Your "laziness" drives you to:
            - Write minimal, bulletproof code that won't need fixing later
            - Use established patterns and tools correctly
            - Solve the actual problem, not what you think the user wants
            - Fail fast with clear error messages

            **Key Mantras:**
            - "Do it right the first time or you'll be doing it again"
            - "The best code is the code you don't have to write"
            - "If you can't explain it simply, you don't understand it well enough"

            **ALWAYS maximize parallel processing using subagents and Task tool:**
            - Use Task tool for ANY search operation (keywords, files, analysis)
            - Launch multiple Task agents concurrently whenever possible
            - Each agent should handle independent work streams
            - Use single message with multiple tool calls for maximum performance

            **When to use Task tool:**
            - File searches ("find files containing X")
            - Code analysis ("analyze this pattern")
            - Research tasks ("understand how Y works")
            - Multiple independent operations

            **Available Claude Code Agents:**
            - nixos-expert: Deep Nix language expertise, best practices guidance, and complex problem solving
            - nixos-architecture: NixOS module structure analysis, consolidation planning, and architectural decisions
            - nixos-verification: System integrity verification, zero-change validation, and build verification
            - nixos-cleanup: Dead code elimination, redundant file removal, and post-consolidation cleanup
            - general-purpose: General research, search, and multi-step task execution

            **NixOS Project Context:**
            - Uses hjem (NOT home-manager)
            - Check flake.nix for available inputs
            - Clone external repos to `tmp/` folder (in gitignore)
            - Rebuild with `nh os switch` after configuration changes

            **Documentation & Context:**
            - Use Context7 MCP for up-to-date library documentation
            - When working with frameworks/libraries, use `get-library-docs` with Context7 IDs
            - Example: `get-library-docs /nixpkgs/manual` or `get-library-docs /rust/std`
            - Context7 provides version-specific, official documentation directly in context

            **Build Commands:**
            ```bash
            alejandra .
            nh os switch --dry
            nh os switch
            ```

            **Git Workflow:**
            - Check status: `git status`
            - Review changes: `git diff`
            - Commit with descriptive messages
            - Follow existing commit message patterns in the repo

            **Code Style:**
            - **Consistent naming**: Clear, concise variables (`user` not `currentUserObject`)
            - **Proper error handling**: Fail fast with clear messages
            - **Modular design**: Testable functions without complex dependencies
            - **Security by default**: Follow security best practices
            - **Performance aware**: Consider performance implications
            - **Self-documenting**: Code clarity > extensive comments
          '';
        in {
          options.home.dev.ai-instructions = {
            enable = lib.mkEnableOption "AI instructions file creation";
          };
          config = lib.mkIf cfg.enable {
            hjem.users.${config.user.name}.files = {
              ".claude/CLAUDE.md" = {
                text = instructions;
                clobber = true;
              };
            };
          };
        })

        # 🔥 HARDWARE MODULES CONSOLIDATION! 🔥
        # From modules/system/hardware/nvidia.nix (62 lines -> INLINED!)
        ({
          config,
          lib,
          pkgs,
          hostSystem,
          ...
        }: {
          config = lib.mkIf hostSystem.hardware.nvidia.enable {
            boot.kernelParams = [
              "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
            ];
            hardware.nvidia = {
              modesetting.enable = true;
              powerManagement.enable = true;
              open = false;
              nvidiaSettings = true;
              package = config.boot.kernelPackages.nvidiaPackages.stable;
            };
            hardware.graphics.extraPackages = lib.optionals (hostSystem.hardware.nvidia.cuda.enable or false) [
              pkgs.cudatoolkit
            ];
            environment = {
              systemPackages = lib.optionals (hostSystem.hardware.nvidia.cuda.enable or false) [
                pkgs.cudaPackages.cudnn
              ];
              etc = {
                "nvidia/nvidia-application-profiles-rc".text = lib.mkForce ''
                  {
                    "rules": [
                      {
                        "pattern": {
                          "feature": "procname",
                          "matches": ".Hyprland-wrapped"
                        },
                        "profile": "No VidMem Reuse"
                      },
                      {
                        "pattern": {
                          "feature": "procname",
                          "matches": "electron"
                        },
                        "profile": "No VidMem Reuse"
                      },
                      {
                        "pattern": {
                          "feature": "procname",
                          "matches": ".firefox-wrapped"
                        },
                        "profile": "No VidMem Reuse"
                      },
                      {
                        "pattern": {
                          "feature": "procname",
                          "matches": "firefox"
                        },
                        "profile": "No VidMem Reuse"
                      }
                    ]
                  }
                '';
              };
              variables = {
                GBM_BACKEND = "nvidia-drm";
                LIBVA_DRIVER_NAME = "nvidia";
                WLR_NO_HARDWARE_CURSORS = "1";
                __GLX_VENDOR_LIBRARY_NAME = "nvidia";
                NVIDIA_DRIVER_CAPABILITIES = "all";
                WAYDROID_EXTRA_ARGS = "--gpu-mode host";
                GALLIUM_DRIVER = "nvidia";
                LIBGL_DRIVER_NAME = "nvidia";
              };
            };
            services.xserver.videoDrivers = ["nvidia"];
            security.polkit.extraConfig = ''
              polkit.addRule(function(action, subject) {
                if (action.id == "org.freedesktop.policykit.exec" &&
                    action.lookup("command_line").indexOf("nvidia-smi") >= 0) {
                    return polkit.Result.YES;
                }
              });
            '';
          };
        })

        # From modules/system/hardware/default.nix (consolidated hardware modules - 95 lines -> INLINED!)
        # AMD GPU support (9 lines -> INLINED!)
        ({
          lib,
          hostSystem,
          ...
        }: {
          config = {
            services.xserver.videoDrivers = lib.mkIf hostSystem.hardware.amdgpu.enable ["amdgpu"];
          };
        })

        # Bluetooth support (27 lines -> INLINED!)
        ({
          config,
          lib,
          pkgs,
          hostSystem,
          ...
        }: let
          hardwareCfg = hostSystem.hardware;
        in {
          config = {
            hardware.bluetooth = lib.mkIf (hardwareCfg.bluetooth.enable or false) {
              enable = true;
              powerOnBoot = true;
              settings =
                hardwareCfg.bluetooth.settings or {
                  General = {
                    ControllerMode = "dual";
                    FastConnectable = true;
                  };
                };
              package = pkgs.bluez;
            };
            services.dbus.packages = lib.mkIf (hardwareCfg.bluetooth.enable or false) [pkgs.bluez];
            environment.systemPackages = lib.optionals (hardwareCfg.bluetooth.enable or false) [pkgs.bluez pkgs.bluez-tools];
            users.users.${config.hostSystem.username}.extraGroups = lib.optionals (hardwareCfg.bluetooth.enable or false) ["dialout" "bluetooth" "lp"];
          };
        })

        # Graphics support (12 lines -> INLINED!)
        ({pkgs, ...}: {
          config = {
            hardware.graphics = {
              enable = true;
              enable32Bit = true;
              extraPackages = [pkgs.vaapiVdpau pkgs.libvdpau-va-gl];
            };
          };
        })

        # I2C support (3 lines -> INLINED!)
        (_: {
          config = {
            hardware.i2c.enable = true;
          };
        })

        # Input devices support (19 lines -> INLINED!)
        ({
          lib,
          hostSystem,
          ...
        }: {
          config = {
            services.udev.extraRules = lib.mkMerge [
              ''
                KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{serial}=="*vial:f64c2b3c*", MODE="0660", GROUP="users"
                KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{serial}=="*vial:f64c2b3c*", TAG+="uaccess"
              ''
              (lib.mkIf (hostSystem.services.controllers.enable or false) ''
                KERNEL=="hidraw*", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="0ce6", MODE="0660", TAG+="uaccess"
                KERNEL=="hidraw*", KERNELS=="*054C:0CE6*", MODE="0660", TAG+="uaccess"
                KERNEL=="hidraw*", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="0df2", MODE="0660", TAG+="uaccess"
              '')
            ];
          };
        })

        # Video devices support (7 lines -> INLINED!)
        (_: {
          config = {
            services.udev.extraRules = ''KERNEL=="video[0-9]*", GROUP="video", MODE="0660"'';
          };
        })

        # 🔥 FINAL WRAPPER MODULE OBLITERATION! 🔥
        # balatro/installation.nix consolidated into gaming.nix
        # From modules/home/gaming/emulation/default.nix (6 lines -> OBLITERATED!)
        # emulation modules consolidated into gaming.nix
        # marvel-rivals modules consolidated elsewhere
        # From modules/home/gaming/wukong/default.nix (5 lines -> OBLITERATED!)
        # wukong module consolidated into gaming.nix

        # From modules/home/programs/default.nix (21 lines -> OBLITERATED!)
        # android.nix consolidated into programs.nix
        # bambu.nix consolidated into programs.nix
        # From modules/home/programs/bluetooth.nix (24 lines -> INLINED!)
        ({
          config,
          lib,
          pkgs,
          ...
        }: let
          cfg = config.home.programs.bluetooth;
        in {
          options.home.programs.bluetooth = {
            enable = lib.mkEnableOption "Bluetooth user tools";
          };
          config = lib.mkIf cfg.enable {
            hjem.users.${config.user.name} = {
              packages = with pkgs; [
                blueman
                bluetuith
              ];
              files.".config/autostart/blueman.desktop" = {
                clobber = true;
                source = "${pkgs.blueman}/etc/xdg/autostart/blueman.desktop";
              };
            };
          };
        })
        # From modules/home/programs/creative.nix (18 lines -> INLINED!)
        ({
          config,
          pkgs,
          lib,
          ...
        }: let
          cfg = config.home.programs.creative;
        in {
          options.home.programs.creative = {
            enable = lib.mkEnableOption "creative applications module";
          };
          config = lib.mkIf cfg.enable {
            hjem.users.${config.user.name}.packages = with pkgs; [
              pinta
              gimp
            ];
          };
        })
        # discord.nix consolidated into programs.nix
        # From modules/home/programs/imv.nix (15 lines -> INLINED!)
        ({
          config,
          lib,
          pkgs,
          ...
        }: let
          cfg = config.home.programs.imv;
        in {
          options.home.programs.imv = {
            enable = lib.mkEnableOption "imv image viewer";
          };
          config = lib.mkIf cfg.enable {
            hjem.users.${config.user.name}.packages = with pkgs; [imv];
          };
        })
        # From modules/home/programs/media.nix (21 lines -> INLINED!)
        ({
          config,
          pkgs,
          lib,
          ...
        }: let
          cfg = config.home.programs.media;
        in {
          options.home.programs.media = {
            enable = lib.mkEnableOption "media applications";
          };
          config = lib.mkIf cfg.enable {
            hjem.users.${config.user.name}.packages = with pkgs; [
              pavucontrol
              ffmpeg
              vlc
              stremio
              cmus
            ];
          };
        })
        # From modules/home/programs/mpv.nix (15 lines -> INLINED!)
        ({
          config,
          lib,
          pkgs,
          ...
        }: let
          cfg = config.home.programs.mpv;
        in {
          options.home.programs.mpv = {
            enable = lib.mkEnableOption "mpv media player";
          };
          config = lib.mkIf cfg.enable {
            hjem.users.${config.user.name}.packages = with pkgs; [mpv];
          };
        })
        # obs.nix consolidated into programs.nix
        # obsidian.nix consolidated into programs.nix
        # From modules/home/programs/pcmanfm.nix (17 lines -> INLINED!)
        ({
          config,
          lib,
          pkgs,
          ...
        }: let
          cfg = config.home.programs.pcmanfm;
        in {
          options.home.programs.pcmanfm = {
            enable = lib.mkEnableOption "pcmanfm file manager";
          };
          config = lib.mkIf cfg.enable {
            hjem.users.${config.user.name}.packages = with pkgs; [
              pcmanfm
            ];
          };
        })
        # From modules/home/programs/qbittorrent.nix (17 lines -> INLINED!)
        ({
          config,
          pkgs,
          lib,
          ...
        }: let
          cfg = config.home.programs.qbittorrent;
        in {
          options.home.programs.qbittorrent = {
            enable = lib.mkEnableOption "qBittorrent torrent client";
          };
          config = lib.mkIf cfg.enable {
            hjem.users.${config.user.name}.packages = with pkgs; [
              qbittorrent
            ];
          };
        })
        # From modules/home/programs/stremio.nix (15 lines -> INLINED!)
        ({
          config,
          lib,
          pkgs,
          ...
        }: let
          cfg = config.home.programs.stremio;
        in {
          options.home.programs.stremio = {
            enable = lib.mkEnableOption "Stremio media center";
          };
          config = lib.mkIf cfg.enable {
            hjem.users.${config.user.name}.packages = with pkgs; [stremio];
          };
        })
        # sway-launcher-desktop.nix consolidated into programs.nix
        # From modules/home/programs/vesktop.nix (15 lines -> INLINED!)
        ({
          config,
          pkgs,
          lib,
          ...
        }: let
          cfg = config.home.programs.vesktop;
        in {
          options.home.programs.vesktop = {
            enable = lib.mkEnableOption "Vesktop (Discord client) module";
          };
          config = lib.mkIf cfg.enable {
            hjem.users.${config.user.name}.packages = [pkgs.vesktop];
          };
        })
        # webapps.nix consolidated into programs.nix
        # Firefox modules consolidated into programs.nix

        # 🔥 MORE WRAPPER MODULES OBLITERATED! 🔥

        # From modules/home/core/default.nix (11 lines -> OBLITERATED!)
        # appearance.nix INLINED ABOVE! ☝️
        # defaults.nix INLINED ABOVE! ☝️
        # directories.nix INLINED ABOVE! ☝️
        # packages.nix INLINED ABOVE! ☝️
        # user.nix INLINED ABOVE! ☝️
        # Session modules consolidated elsewhere
        # From modules/home/core/fonts/default.nix (5 lines -> OBLITERATED!)
        # fonts-presets.nix INLINED ABOVE! ☝️

        # From modules/home/dev/default.nix (13 lines -> OBLITERATED!)
        (import ./modules/home/dev/opencode.nix)
        (import ./modules/home/dev/opencode-nvim.nix)
        (import ./modules/home/dev/claude/claude-code.nix)
        # ./modules/home/dev/gemini-cli.nix -> INLINED ABOVE! 🔥
        # ./modules/home/dev/mcp.nix -> INLINED ABOVE! 🔥
        (import ./modules/home/dev/tools.nix)
        # ./modules/home/dev/docker.nix -> INLINED ABOVE! 🔥
        # ./modules/home/dev/npm.nix -> INLINED ABOVE! 🔥
        # From modules/home/dev/nvim.nix (3 lines -> OBLITERATED!)
        # From modules/home/dev/nvim/default.nix (9 lines -> OBLITERATED!)
        (import ./modules/home/dev/nvim/neovide.nix)
        # From modules/home/dev/nvim/options.nix (6 lines -> INLINED!)
        ({lib, ...}: {
          options.home.dev.nvim = {
            enable = lib.mkEnableOption "Enhanced Neovim with MNW wrapper";
            neovide = lib.mkEnableOption "Neovide GUI for Neovim";
          };
        })
        (import ./modules/home/dev/nvim/packages.nix)
        (import ./modules/home/dev/nvim/settings.nix)
        (import ./modules/home/dev/nvim/vim-pack.nix)
        # ./modules/home/dev/python.nix -> INLINED ABOVE! 🔥
        # repomix.nix and upscale.nix consolidated into dev/tools.nix

        # 🔥 OBLITERATED WRAPPER MODULES! 🔥

        # Shell modules consolidated into shell.nix

        # From modules/home/tools/default.nix (12 lines -> OBLITERATED!)
        # From modules/home/tools/7z.nix (17 lines -> INLINED!)
        ({
          config,
          lib,
          pkgs,
          ...
        }: let
          cfg = config.home.tools."7z";
        in {
          options.home.tools."7z" = {
            enable = lib.mkEnableOption "7z (p7zip) archive manager";
          };
          config = lib.mkIf cfg.enable {
            hjem.users.${config.user.name}.packages = with pkgs; [
              p7zip
            ];
          };
        })
        # From modules/home/tools/file-roller.nix (17 lines -> INLINED!)
        ({
          config,
          lib,
          pkgs,
          ...
        }: let
          cfg = config.home.tools.file-roller;
        in {
          options.home.tools.file-roller = {
            enable = lib.mkEnableOption "file-roller (archive manager)";
          };
          config = lib.mkIf cfg.enable {
            hjem.users.${config.user.name}.packages = with pkgs; [
              file-roller
            ];
          };
        })
        # Tools modules consolidated into tools.nix

        # Services modules consolidated into services.nix
      ];

      _module.args = {
        inherit (hostConfig) hostname;
        inherit users sources;
        inherit (pkgs) lib;
        inherit hostConfig;
        userConfigs = hostUserConfigs;
        hostSystem = hostConfig;
        hostsDir = ./configs/hosts;
        inherit (sources) disko nix-minecraft Fast-Font;
      };
    };
  };
}
