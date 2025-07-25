{
  config,
  lib,
  ...
}: let
  cfg = config.home.dev.nvim;
  username = "y0usaf";
in {
  config = lib.mkIf cfg.enable {
    users.users.${username}.maid.file.xdg_config."nvim/lua/plugins.lua".text = ''
      return {
        -- LSP
        {
          "neovim/nvim-lspconfig",
          event = { "BufReadPre", "BufNewFile" },
          dependencies = {
            "hrsh7th/cmp-nvim-lsp",
          },
          config = function()
            local lspconfig = require("lspconfig")
            local capabilities = require("cmp_nvim_lsp").default_capabilities()

            local on_attach = function(client, bufnr)
              local opts = { buffer = bufnr, silent = true }
              vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
              vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
              vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
              vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
              vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
              vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
              vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
            end


            local servers = { "lua_ls", "nil_ls", "pyright" }
            for _, server in ipairs(servers) do
              lspconfig[server].setup({
                capabilities = capabilities,
                on_attach = on_attach,
                settings = server == "lua_ls" and {
                  Lua = { diagnostics = { globals = { "vim" } } }
                } or {},
              })
            end
          end,
        },


        {
          "hrsh7th/nvim-cmp",
          event = "InsertEnter",
          dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "L3MON4D3/LuaSnip",
            "saadparwaiz1/cmp_luasnip",
            "onsails/lspkind.nvim",
          },
          config = function()
            local cmp = require("cmp")
            local luasnip = require("luasnip")
            local lspkind = require("lspkind")

            cmp.setup({
              snippet = {
                expand = function(args)
                  luasnip.lsp_expand(args.body)
                end,
              },
              mapping = cmp.mapping.preset.insert({
                ["<C-b>"] = cmp.mapping.scroll_docs(-4),
                ["<C-f>"] = cmp.mapping.scroll_docs(4),
                ["<C-Space>"] = cmp.mapping.complete(),
                ["<C-e>"] = cmp.mapping.abort(),
                ["<CR>"] = cmp.mapping.confirm({ select = true }),
                ["<Tab>"] = cmp.mapping(function(fallback)
                  if cmp.visible() then
                    cmp.select_next_item()
                  elseif luasnip.expand_or_jumpable() then
                    luasnip.expand_or_jump()
                  else
                    fallback()
                  end
                end, { "i", "s" }),
              }),
              sources = cmp.config.sources({
                { name = "nvim_lsp", priority = 1000 },
                { name = "luasnip", priority = 750 },
              }, {
                { name = "buffer", priority = 500, max_item_count = 5 },
                { name = "path", priority = 250, max_item_count = 3 },
              }),
              formatting = {
                format = lspkind.cmp_format({
                  mode = "symbol_text",
                  maxwidth = 50,
                  ellipsis_char = "...",
                }),
              },
            })
          end,
        },


        {
          "nvim-telescope/telescope.nvim",
          event = "VeryLazy",
          dependencies = {
            "nvim-lua/plenary.nvim",
            { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
          },
          config = function()
            require("telescope").setup({})
            require("telescope").load_extension("fzf")
          end,
        },


        {
          "nvim-treesitter/nvim-treesitter",
          build = ":TSUpdate",
          event = { "BufReadPost", "BufNewFile" },
          opts = {
            highlight = { enable = true },
            indent = { enable = true },
          },
        },


        { "numToStr/Comment.nvim", event = "VeryLazy", opts = {} },
        { "windwp/nvim-autopairs", event = "InsertEnter", opts = {} },



        {
          "kevinhwang91/nvim-ufo",
          event = "VeryLazy",
          dependencies = "kevinhwang91/promise-async",
          opts = {},
          init = function()
            vim.o.foldcolumn = "1"
            vim.o.foldlevel = 99
            vim.o.foldlevelstart = 99
            vim.o.foldenable = true
          end,
        },
        {
          "j-hui/fidget.nvim",
          event = "VeryLazy",
          opts = {
            notification = {
              window = {
                winblend = 0,
                border = "rounded",
                max_width = 0,
                max_height = 0,
              },
              view = {
                stack_upwards = true,
                icon_separator = " ",
                group_separator = "---",
                group_separator_hl = "Comment",
              },
              configs = {
                default = {
                  name = "Notification",
                  ttl = 5,
                  group_key = nil,
                  icon = "💬",
                  annote = nil,
                  priority = 30,
                  skip_history = false,
                  update_hook = nil,
                },
                error = {
                  name = "Error",
                  icon = "❌",
                  ttl = 8,
                  priority = 100,
                },
                warn = {
                  name = "Warning",
                  icon = "⚠️",
                  ttl = 6,
                  priority = 80,
                },
                info = {
                  name = "Info",
                  icon = "ℹ️",
                  ttl = 4,
                  priority = 50,
                },
              },
            },
            progress = {
              display = {
                render_limit = 3,
                done_ttl = 2,
              },
            },
          },
          config = function(_, opts)
            require("fidget").setup(opts)

            vim.notify = require("fidget").notify
          end,
        },
        {
          "RRethy/vim-illuminate",
          event = "VeryLazy",
          config = function()
            require("illuminate").configure({
              delay = 100,
              large_file_cutoff = 2000,
              large_file_overrides = {
                providers = { "lsp" },
              },
            })
          end,
        },
        {
          "folke/twilight.nvim",
          cmd = "Twilight",
          opts = {
            dimming = {
              alpha = 0.25,
              color = { "Normal", "#ffffff" },
            },
            context = 15,
            treesitter = true,
          },
        },


        {
          "kawre/leetcode.nvim",
          cmd = "Leet",
          dependencies = {
            "nvim-telescope/telescope.nvim",
            "nvim-lua/plenary.nvim",
            "MunifTanjim/nui.nvim",
          },
          opts = {
            lang = "python3",
            storage = {
              home = "~/leetcode/",
            },
            logging = true,
            injector = {
              ["python3"] = {
                before = true,
              },
            },
          },
        },

        -- File Explorer
        {
          "nvim-neo-tree/neo-tree.nvim",
          branch = "v3.x",
          cmd = "Neotree",
          dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons",
            "MunifTanjim/nui.nvim",
          },
          opts = {
            close_if_last_window = false,
            popup_border_style = "rounded",
            enable_git_status = true,
            enable_diagnostics = true,
            filesystem = {
              filtered_items = {
                visible = false,
                hide_dotfiles = false,
                hide_gitignored = false,
              },
              follow_current_file = {
                enabled = true,
                leave_dirs_open = false,
              },
              group_empty_dirs = false,
              hijack_netrw_behavior = "open_default",
              use_libuv_file_watcher = true,
            },
            window = {
              position = "left",
              width = 30,
              mapping_options = {
                noremap = true,
                nowait = true,
              },
              mappings = {
                ["<space>"] = "none",
                ["[g"] = "prev_git_modified",
                ["]g"] = "next_git_modified",
              },
            },
            default_component_configs = {
              indent = {
                indent_size = 2,
                padding = 1,
                with_markers = true,
                indent_marker = "│",
                last_indent_marker = "└",
                highlight = "NeoTreeIndentMarker",
                with_expanders = nil,
                expander_collapsed = "",
                expander_expanded = "",
                expander_highlight = "NeoTreeExpander",
              },
              icon = {
                folder_closed = "",
                folder_open = "",
                folder_empty = "ﰊ",
                default = "*",
                highlight = "NeoTreeFileIcon"
              },
              modified = {
                symbol = "[+]",
                highlight = "NeoTreeModified",
              },
              name = {
                trailing_slash = false,
                use_git_status_colors = true,
                highlight = "NeoTreeFileName",
              },
              git_status = {
                symbols = {
                  added     = "", -- or "✚", but this is redundant info if you use git_status_colors on the name
                  modified  = "", -- or "", but this is redundant info if you use git_status_colors on the name
                  deleted   = "✖",-- this can only be used in the git_status source
                  renamed   = "󰁕",-- this can only be used in the git_status source
                  untracked = "",
                  ignored   = "",
                  unstaged  = "󰄱",
                  staged    = "",
                  conflict  = "",
                }
              },
            },
          },
        },

        -- Terminal
        {
          "akinsho/toggleterm.nvim",
          version = "*",
          opts = {
            size = 20,
            open_mapping = [[<c-\>]],
            hide_numbers = true,
            shade_filetypes = {},
            shade_terminals = true,
            shading_factor = 2,
            start_in_insert = true,
            insert_mappings = true,
            persist_size = true,
            direction = "float",
            close_on_exit = true,
            shell = vim.o.shell,
            float_opts = {
              border = "curved",
              winblend = 0,
              highlights = {
                border = "Normal",
                background = "Normal",
              },
            },
          },
        },


      }
    '';
  };
}
