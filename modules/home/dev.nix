{
  config,
  lib,
  pkgs,
  ...
}: let
  # AI Instructions content
  aiInstructions = ''
    You are a pragmatic software engineer who values efficiency and quality. Your "laziness" drives you to:
    - Write minimal, bulletproof code that won't need fixing later
    - Use established patterns and tools correctly
    - Solve the actual problem, not what you think the user wants
    - Fail fast with clear error messages

    **Key Mantras:**
    - "Do it right the first time or you'll be doing it again"
    - "The best code is the code you don't have to write"
    - "If you can't explain it simply, you don't understand it well enough"

    **NixOS Project Context:**
    - Uses hjem (NOT home-manager)
    - Check flake.nix for available inputs
    - Clone external repos to `tmp/` folder (in gitignore)
    - Rebuild with `nh os switch` after configuration changes

    **Build Commands:**
    ```bash
    alejandra .
    nh os switch --dry
    nh os switch
    ```
  '';

  # MCP Servers configuration
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

  # OpenCode MCP servers configuration
  opencodeMcpServers = {
    "Filesystem" = {
      type = "local";
      command = ["npx" "-y" "@modelcontextprotocol/server-filesystem" config.user.homeDirectory];
      enabled = true;
      environment = {};
    };
    "Nixos-MCP" = {
      type = "local";
      command = ["uvx" "mcp-nixos"];
      enabled = true;
      environment = {};
    };
    "sequential-thinking" = {
      type = "local";
      command = ["npx" "-y" "@modelcontextprotocol/server-sequential-thinking"];
      enabled = true;
      environment = {};
    };
    "GitHub-Repo-MCP" = {
      type = "local";
      command = ["npx" "-y" "github-repo-mcp"];
      enabled = true;
      environment = {};
    };
    "Gemini-MCP" = {
      type = "local";
      command = ["npx" "-y" "gemini-mcp-tool"];
      enabled = true;
      environment = {};
    };
  };
in {
  options.home.dev = {
    # Core development tools
    docker.enable = lib.mkEnableOption "docker development environment";
    gemini-cli.enable = lib.mkEnableOption "Gemini CLI development tools";
    mcp.enable = lib.mkEnableOption "Model Context Protocol configuration";
    npm.enable = lib.mkEnableOption "Node.js and NPM configuration";
    python.enable = lib.mkEnableOption "Python development environment";

    # Claude configuration options
    claude-code.enable = lib.mkEnableOption "Claude Code development tools";
    claude.agents.enable = lib.mkEnableOption "Claude declarative agents";
    claude.slash-commands.enable = lib.mkEnableOption "Claude slash commands";

    # OpenCode configuration options
    opencode = {
      enable = lib.mkEnableOption "opencode AI coding agent";
      theme = lib.mkOption {
        type = lib.types.str;
        default = "opencode";
        description = "Theme to use for opencode";
      };
      model = lib.mkOption {
        type = lib.types.str;
        default = "anthropic/claude-sonnet-4-20250514";
        description = "Default model to use";
      };
      enableMcpServers = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable MCP servers for enhanced functionality";
      };
    };

    # Neovim configuration options
    nvim = {
      enable = lib.mkEnableOption "Neovim development environment";
      neovide = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable Neovide GUI";
      };
    };

    # Additional tools (inlined from tools.nix)
    cursor-ide.enable = lib.mkEnableOption "Cursor IDE";
    latex.enable = lib.mkEnableOption "LaTeX development environment";
    repomix.enable = lib.mkEnableOption "repomix tool for AI-friendly repository packing";
    upscale.enable = lib.mkEnableOption "realesrgan-ncnn-vulkan for upscaling";
  };

  config = lib.mkMerge [
    # Docker configuration
    (lib.mkIf config.home.dev.docker.enable {
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
    })

    # Gemini CLI configuration
    (lib.mkIf config.home.dev.gemini-cli.enable {
      hjem.users.${config.user.name} = {
        packages = with pkgs; [
          gemini-cli
        ];
        files = {
          ".gemini/GEMINI.md" = {
            text = aiInstructions;
            clobber = true;
          };
          ".gemini/settings.json" = {
            text = builtins.toJSON {};
            clobber = true;
          };
        };
      };
    })

    # MCP configuration
    (lib.mkIf config.home.dev.mcp.enable {
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
            text = builtins.toJSON mcpServersConfig;
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
            if \! runuser -u ${config.user.name} -- ${pkgs.claude-code}/bin/claude mcp list | grep -q "$name"; then
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
    })

    # Claude Code configuration
    (lib.mkIf config.home.dev.claude-code.enable {
      hjem.users.${config.user.name} = {
        packages = with pkgs; [
          claude-code
        ];
        files = {
          ".claude/CLAUDE.md" = {
            text = aiInstructions;
            clobber = true;
          };
          ".config/claude/claude_desktop_config.json" = {
            text = builtins.toJSON {
              mcpServers = {
                "Context7" = {
                  command = "npx";
                  args = ["-y" "@upstash/context7-mcp"];
                };
              };
            };
            clobber = true;
          };
          ".config/claude/settings.json" = {
            text = builtins.toJSON {
              includeCoAuthoredBy = false;
            };
            clobber = true;
          };
        };
      };
    })

    # Claude Agents configuration (condensed)
    (lib.mkIf config.home.dev.claude.agents.enable {
      hjem.users.${config.user.name} = {
        files = {
          ".claude/agents/code-reviewer.md" = {
            text = ''
              ---
              name: code-reviewer
              description: Use proactively after writing significant code to review and improve it
              tools: file-operations, grep, analysis
              ---
              Expert code reviewer focusing on security, performance, maintainability, and error handling.
            '';
            clobber = true;
          };
          ".claude/agents/debugger.md" = {
            text = ''
              ---
              name: debugger
              description: Expert debugging and error resolution
              tools: bash, file-operations, grep, logs
              ---
              Systematic debugging specialist with root cause analysis approach.
            '';
            clobber = true;
          };
          ".claude/agents/performance-engineer.md" = {
            text = ''
              ---
              name: performance-engineer
              description: Code optimization and performance analysis
              tools: profiling, benchmarking, analysis
              ---
              Performance engineering expert specializing in bottleneck identification and optimization.
            '';
            clobber = true;
          };
        };
      };
    })

    # Claude Slash Commands configuration (condensed)
    (lib.mkIf config.home.dev.claude.slash-commands.enable {
      hjem.users.${config.user.name} = {
        files = {
          ".claude/commands/nixos-build.md" = {
            text = ''
              # /nixos-build
              Build and switch NixOS configuration safely:
              1. Format code with `alejandra .`
              2. Test build with `nh os switch --dry`
              3. Apply changes with `nh os switch`
            '';
            clobber = true;
          };
          ".claude/commands/fix-issue.md" = {
            text = ''
              # /fix-issue
              Analyze and fix GitHub issue: $ARGUMENTS
              1. Use `gh issue view` to get issue details
              2. Search codebase for relevant files
              3. Implement and test fix
            '';
            clobber = true;
          };
        };
      };
    })

    # OpenCode configuration
    (lib.mkIf config.home.dev.opencode.enable {
      hjem.users.${config.user.name} = {
        packages = with pkgs; [
          nodejs_20
          uv
        ];
        files = {
          ".config/opencode/opencode.json" = {
            text = builtins.toJSON (
              {
                "$schema" = "https://opencode.ai/config.json";
                inherit (config.home.dev.opencode) theme;
                inherit (config.home.dev.opencode) model;
                autoupdate = true;
                share = "manual";
                disabled_providers = ["openai" "huggingface"];
                instructions = [
                  "AGENTS.md"
                  ".cursor/rules/*.md"
                  "{file:${config.user.configDirectory}/opencode/instructions.md}"
                ];
              }
              // (lib.optionalAttrs config.home.dev.opencode.enableMcpServers {
                mcp = opencodeMcpServers;
              })
            );
            clobber = true;
          };
          ".config/opencode/instructions.md" = {
            text = aiInstructions;
            clobber = true;
          };
        };
      };

      systemd.tmpfiles.rules = [
        "d ${config.user.homeDirectory}/.config/opencode 0755 ${config.user.name} users - -"
        "d ${config.user.homeDirectory}/.npm-global 0755 ${config.user.name} users - -"
      ];

      environment.variables.PATH = lib.mkAfter "${config.user.homeDirectory}/.npm-global/bin";

      systemd.services.opencode-install = {
        description = "Install OpenCode via npm";
        wantedBy = ["multi-user.target"];
        after = ["network.target"];
        serviceConfig = {
          Type = "oneshot";
          User = config.user.name;
          ExecStart = ''/bin/sh -c "export NPM_CONFIG_PREFIX=${config.user.homeDirectory}/.npm-global && if \! command -v opencode >/dev/null 2>&1; then mkdir -p $NPM_CONFIG_PREFIX && npm install -g opencode-ai; fi"'';
          RemainAfterExit = true;
        };
        path = with pkgs; [nodejs_20 bash uv];
      };
    })

    # NPM configuration
    (lib.mkIf config.home.dev.npm.enable {
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
        };
      };
      systemd.tmpfiles.rules = [
        "d ${config.user.homeDirectory}/.local/share/npm 0755 ${config.user.name} ${config.user.name} - -"
        "d ${config.user.homeDirectory}/.cache/npm 0755 ${config.user.name} ${config.user.name} - -"
        "d ${config.user.homeDirectory}/.config/npm/config 0755 ${config.user.name} ${config.user.name} - -"
        "d ${config.user.homeDirectory}/.cache/pnpm/store 0755 ${config.user.name} ${config.user.name} - -"
      ];
    })

    # Neovim configuration (simplified)
    (lib.mkIf config.home.dev.nvim.enable {
      hjem.users.${config.user.name} = {
        packages = [
          pkgs.ripgrep
          pkgs.fd
          pkgs.tree-sitter
          (pkgs.tree-sitter.withPlugins (p:
            with p; [
              tree-sitter-nix
              tree-sitter-lua
              tree-sitter-python
              tree-sitter-markdown
              tree-sitter-json
            ]))
          pkgs.neovim-unwrapped
          pkgs.lua-language-server
          pkgs.nil
          pkgs.pyright
          pkgs.stylua
          pkgs.alejandra
          pkgs.black
          pkgs.curl
          pkgs.jq
        ];
        files = {
          ".config/nvim/init.lua" = {
            clobber = true;
            text = ''
              -- Neovim Configuration
              vim.g.mapleader = " "
              vim.g.maplocalleader = "\\"

              -- Basic settings
              vim.opt.number = true
              vim.opt.relativenumber = true
              vim.opt.signcolumn = "yes"
              vim.opt.termguicolors = true
              vim.opt.expandtab = true
              vim.opt.tabstop = 2
              vim.opt.shiftwidth = 2
              vim.opt.clipboard = "unnamedplus"
              vim.opt.ignorecase = true
              vim.opt.smartcase = true

              -- Load vim.pack configuration
              require("vim-pack-config")

              -- Load opencode configuration if available
              pcall(require, "vim-pack-opencode")
            '';
          };
          ".config/nvim/lua/vim-pack-config.lua" = {
            text = ''
              -- Core plugins with vim.pack
              vim.pack.add({
                "https://github.com/neovim/nvim-lspconfig",
                "https://github.com/hrsh7th/nvim-cmp",
                "https://github.com/hrsh7th/cmp-nvim-lsp",
                "https://github.com/hrsh7th/cmp-buffer",
                "https://github.com/hrsh7th/cmp-path",
                "https://github.com/L3MON4D3/LuaSnip",
                "https://github.com/saadparwaiz1/cmp_luasnip",
                "https://github.com/nvim-telescope/telescope.nvim",
                "https://github.com/nvim-lua/plenary.nvim",
                "https://github.com/nvim-treesitter/nvim-treesitter",
                "https://github.com/numToStr/Comment.nvim",
                "https://github.com/windwp/nvim-autopairs",
                "https://github.com/scottmckendry/cyberdream.nvim",
                "https://github.com/nvim-lualine/lualine.nvim",
                "https://github.com/lewis6991/gitsigns.nvim",
                "https://github.com/stevearc/oil.nvim",
                "https://github.com/nvim-tree/nvim-web-devicons",
              })

              -- Basic setup
              local function initialize_config()
                -- LSP
                local lspconfig = require("lspconfig")
                local capabilities = require("cmp_nvim_lsp").default_capabilities()
                local servers = { "lua_ls", "nil_ls", "pyright" }
                for _, server in ipairs(servers) do
                  lspconfig[server].setup({ capabilities = capabilities })
                end

                -- Completion
                local cmp = require("cmp")
                cmp.setup({
                  snippet = { expand = function(args) require("luasnip").lsp_expand(args.body) end },
                  mapping = cmp.mapping.preset.insert({
                    ["<CR>"] = cmp.mapping.confirm({ select = true }),
                  }),
                  sources = {{ name = "nvim_lsp" }, { name = "buffer" }, { name = "path" }},
                })

                -- UI
                require("cyberdream").setup({ transparent = true })
                vim.cmd.colorscheme("cyberdream")
                require("lualine").setup({})
                require("gitsigns").setup({})
                require("oil").setup({ default_file_explorer = true })
                require("telescope").setup({})
                require("nvim-treesitter.configs").setup({ highlight = { enable = true } })
                require("Comment").setup({})
                require("nvim-autopairs").setup({})
              end

              vim.api.nvim_create_autocmd("PackChanged", { callback = function() vim.schedule(initialize_config) end })
              vim.schedule(function() if pcall(require, "lspconfig") then initialize_config() end end)
            '';
            clobber = true;
          };
        };
      };
    })

    # Neovide configuration
    (lib.mkIf (config.home.dev.nvim.enable && config.home.dev.nvim.neovide) {
      hjem.users.${config.user.name} = {
        packages = with pkgs; [neovide];
        files.".config/neovide/config.toml" = {
          clobber = true;
          text = ''
            [font]
            normal = ["Fast_Mono"]
            size = 14.0
            [window]
            transparency = 0.9
            [input]
            ime = true
          '';
        };
      };
    })

    # OpenCode Neovim integration
    (lib.mkIf (config.home.dev.nvim.enable && config.home.dev.opencode.enable) {
      hjem.users.${config.user.name}.files = {
        ".config/nvim/lua/vim-pack-opencode.lua" = {
          text = ''
            vim.pack.add({ "https://github.com/NickvanDyke/opencode.nvim" })
            vim.schedule(function()
              local success, opencode = pcall(require, "opencode")
              if success then
                opencode.setup({ model_id = "gpt-4.1", provider_id = "github-copilot" })
                vim.keymap.set({"n", "v"}, "<leader>ca", function() require("opencode").ask() end)
                vim.keymap.set("n", "<leader>ce", function() require("opencode").prompt("Explain @cursor") end)
              end
            end)
          '';
          clobber = true;
        };
      };
    })

    # Python configuration
    (lib.mkIf config.home.dev.python.enable {
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
            '';
          };
          "{{xdg_config_home}}/zsh/.zshrc" = {
            clobber = true;
            text = lib.mkAfter ''
              alias py="python3"
              alias pip="pip3"
              alias venv="python3 -m venv"
              mkvenv() { python3 -m venv ''${1:-venv}; }
              workon() { source ''${1:-venv}/bin/activate; }
            '';
          };
        };
      };
      systemd.tmpfiles.rules = [
        "d ${config.user.homeDirectory}/.local/share/python 0755 ${config.user.name} ${config.user.name} - -"
        "d ${config.user.homeDirectory}/.cache/pip 0755 ${config.user.name} ${config.user.name} - -"
        "d ${config.user.homeDirectory}/.local/share/venvs 0755 ${config.user.name} ${config.user.name} - -"
      ];
    })

    # Additional tools (inlined from tools.nix)
    (lib.mkIf config.home.dev.cursor-ide.enable {
      hjem.users.${config.user.name}.packages = with pkgs; [code-cursor];
    })

    (lib.mkIf config.home.dev.latex.enable {
      hjem.users.${config.user.name}.packages = with pkgs; [texliveFull texstudio tectonic];
    })

    (lib.mkIf config.home.dev.repomix.enable {
      hjem.users.${config.user.name}.packages = with pkgs; [repomix];
    })

    (lib.mkIf config.home.dev.upscale.enable {
      hjem.users.${config.user.name} = {
        packages = with pkgs; [realesrgan-ncnn-vulkan];
        files = {
          ".config/zsh/aliases/esrgan.zsh" = {
            text = ''
              alias esrgan="realesrgan-ncnn-vulkan -i ${config.user.homeDirectory}/Pictures/Upscale/Input -o ${config.user.homeDirectory}/Pictures/Upscale/Output"
            '';
            clobber = true;
          };
        };
      };
    })
  ];
}
