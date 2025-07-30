{
  config,
  lib,
  pkgs,
  ...
}: let
  catFetchCfg = config.home.shell.cat-fetch;
  aliasesCfg = config.home.shell.aliases;
  zshCfg = config.home.shell.zsh;
  zellijCfg = config.home.shell.zellij;
  inherit (config.user) name homeDirectory nixosConfigDirectory tokensDirectory;
  
  # Zellij IDE layout configuration
  ideLayout = ''
    layout {
        cwd "${config.user.homeDirectory}"
        tab name="Tab
            pane split_direction="vertical" {
                pane size="25%" command="bash" {
                    args "-c" "while true; do echo 'File browser pane - implement file browser here'; sleep 60; done"
                }
                pane command="/nix/store/10niqvrkxcxv7m9svqg9sw03pq2f9c79-neovim-unwrapped-0.11.1/bin/nvim" size="50%" {
                    args "--cmd" "lua" "vim.g.loaded_node_provider=0;vim.g.loaded_perl_provider=0;vim.g.loaded_python_provider=0;vim.g.python3_host_prog='/nix/store/nw09bl4zh8ydf2h32qrxrp22b619v2m2-neovim-0.11.1/bin/nvim-python3';vim.g.ruby_host_prog='/nix/store/nw09bl4zh8ydf2h32qrxrp22b619v2m2-neovim-0.11.1/bin/nvim-ruby'" "--cmd" "set" "packpath^=/nix/store/vil1bkzh8fyccnkg30anpvzv0m79fdhj-vim-pack-dir" "--cmd" "set" "rtp^=/nix/store/vil1bkzh8fyccnkg30anpvzv0m79fdhj-vim-pack-dir"
                }
                pane size="50%" {
                    pane command="claude" cwd="nixos" focus=true size="50%"
                    pane command="/nix/store/0jr78nw5jw3paq9fhgvcldi2bva98wjq-lazygit-0.53.0/bin/lazygit" cwd="nixos" size="50%"
                }
            }
        }
        new_tab_template {
            pane
        }
    }
  '';
  
  zshConfig = {
    cat-fetch = true;
    history-memory = 10000;
    history-storage = 10000;
    enableFancyPrompt = true;
    zellij = {
      enable = false;
    };
  };
in {
  options = {
    # shell/cat-fetch.nix (28 lines -> INLINED\!)
    home.shell.cat-fetch = {
      enable = lib.mkEnableOption "cat fetch display on shell startup";
    };
    # shell/aliases.nix (89 lines -> INLINED\!)
    home.shell.aliases = {
      enable = lib.mkEnableOption "Enable base aliases";
    };
    # shell/zsh.nix (175 lines -> INLINED\!)
    home.shell.zsh = {
      enable = lib.mkEnableOption "zsh shell configuration";
    };
    # shell/zellij.nix + zellij-ide.nix -> INLINED\!
    home.shell.zellij = {
      enable = lib.mkEnableOption "zellij terminal multiplexer";
      autoStart = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Automatically start zellij when opening zsh";
      };
      layouts = {
        ide = lib.mkOption {
          type = lib.types.str;
          default = "";
          description = "IDE layout configuration";
        };
      };
    };
  };
  
  config = lib.mkMerge [
    (lib.mkIf catFetchCfg.enable {
      hjem.users.${config.user.name}.files = {
        ".config/zsh/.zshrc" = {
          text = lib.mkAfter ''
            print_cats() {
                echo -e "\033[0;31m ⟋|､      \033[0;34m  ⟋|､      \033[0;35m  ⟋|､      \033[0;32m  ⟋|､
            \033[0;31m(°､ ｡ 7    \033[0;34m(°､ ｡ 7    \033[0;35m(°､ ｡ 7    \033[0;32m(°､ ｡ 7
            \033[0;31m |､  ~ヽ   \033[0;34m |､  ~ヽ   \033[0;35m |､  ~ヽ   \033[0;32m |､  ~ヽ
            \033[0;31m じしf_,)〳\033[0;34m じしf_,)〳\033[0;35m じしf_,)〳\033[0;32m じしf_,)〳
            \033[0;36m  [tomo]   \033[0;33m  [moon]   \033[0;32m  [ekko]   \033[0;35m  [bozo]\033[0m"
            }
            print_cats
          '';
          clobber = true;
        };
      };
    })
    (lib.mkIf aliasesCfg.enable {
      hjem.users.${name}.files = {
        ".config/zsh/aliases/android.zsh" = {
          text = ''alias adb="HOME=\"$XDG_DATA_HOME/android\" adb"'';
          clobber = true;
        };
        ".config/zsh/aliases/download.zsh" = {
          text = ''alias wget="wget --hsts-file=\"$XDG_DATA_HOME/wget-hsts\""'';
          clobber = true;
        };
        ".config/zsh/aliases/version-control.zsh" = {
          text = ''alias svn="svn --config-dir \"$XDG_CONFIG_HOME/subversion\"" alias hmpush="git -C ${nixosConfigDirectory} push origin main --force" alias hmpull="git -C ${nixosConfigDirectory} fetch origin && git -C ${nixosConfigDirectory} reset --hard origin/main" '';
          clobber = true;
        };
        ".config/zsh/aliases/javascript.zsh" = {
          text = ''alias yarn="yarn --use-yarnrc \"$XDG_CONFIG_HOME/yarn/config\""'';
          clobber = true;
        };
        ".config/zsh/aliases/media.zsh" = {
          text = ''alias mocp="mocp -M \"$XDG_CONFIG_HOME/moc\" -O MOCDir=\"$XDG_CONFIG_HOME/moc\""'';
          clobber = true;
        };
        ".config/zsh/aliases/navigation.zsh" = {
          text = ''alias cat="bat" alias cattree="${nixosConfigDirectory}/lib/scripts/cattree.sh" alias l.="lsd -A | grep -E \"^\\.\"" alias la="lsd -A --color=always --group-dirs=first --icon=always" alias ll="lsd -l --color=always --group-dirs=first --icon=always" alias ls="lsd -lA --color=always --group-dirs=first --icon=always" alias lt="lsd -A --tree --color=always --group-dirs=first --icon=always" '';
          clobber = true;
        };
        ".config/zsh/aliases/system.zsh" = {
          text = ''alias userctl="systemctl --user" alias hmfail="journalctl -u home-manager-${name}.service -n 20 --no-pager" alias pkgs="nix-store --query --requisites /run/current-system | cut -d- -f2- | sort | uniq | grep -i" alias pkgcount="nix-store --query --requisites /run/current-system | cut -d- -f2- | sort | uniq | wc -l" alias hwconfig="sudo nixos-generate-config --show-hardware-config" alias gpupower="sudo nvidia-smi -pl" '';
          clobber = true;
        };
        ".config/zsh/aliases/search.zsh" = {
          text = ''alias grep="grep --color=auto" alias dir="dir --color=auto" alias egrep="grep -E --color=auto" alias fgrep="grep -F --color=auto" '';
          clobber = true;
        };
        ".config/zsh/aliases/development.zsh" = {
          text = ''alias lintcheck="clear; statix check .; deadnix ." alias lintfix="clear; statix fix .; deadnix ." alias ide="zellij --layout ${config.user.configDirectory}/zellij/layouts/ide.kdl" alias opencode="${homeDirectory}/.npm-global/bin/opencode" '';
          clobber = true;
        };
      };
    })
    (lib.mkIf zshCfg.enable {
      environment.variables.ZDOTDIR = "${config.user.configDirectory}/zsh";
      programs.zsh.enable = true;
      hjem.users.${name} = {
        packages = with pkgs; [
          zsh
          bat
          lsd
          tree
        ];
        files = {
          ".config/zsh/.zshenv" = {
            text = let
              tokenFunctionScript = ''
                export_vars_from_files() {
                    local dir_path=$1
                    # Skip opencode-related API keys to prefer oauth
                    local skip_for_opencode=("ANTHROPIC_API_KEY" "OPENAI_API_KEY")

                    for file_path in "$dir_path"/*.txt; do
                        if [[ -f $file_path ]]; then
                            var_name=$(basename "$file_path" .txt)

                            # Skip API keys that conflict with opencode oauth
                            if [[ " ''${skip_for_opencode[@]} " =~ " $var_name " ]]; then
                                continue
                            fi

                            export $var_name=$(cat "$file_path")
                        fi
                    done
                }
                export_vars_from_files "${tokensDirectory}"

                # Set default applications
                export TERMINAL="${config.home.core.defaults.terminal}"
                export BROWSER="${config.home.core.defaults.browser}"
                export EDITOR="${config.home.core.defaults.editor}"
              '';
            in
              tokenFunctionScript;
            clobber = true;
          };
          ".config/zsh/.zprofile" = {
            text = ''
              if [[ $- == *i* ]]; then
                case "$(hostname)" in
                  "${config.user.name}-desktop")
                    sudo nvidia-smi -pl 150
                    ;;
                  "${config.user.name}-laptop")
                    ;;
                esac
              fi
            '';
            clobber = true;
          };
          ".config/zsh/.zshrc" = {
            text = ''
              # Set default applications
              export TERMINAL="${config.home.core.defaults.terminal}"
              export BROWSER="${config.home.core.defaults.browser}"
              export EDITOR="${config.home.core.defaults.editor}"

              # Source all files in the aliases directory
              for alias_file in ''${ZDOTDIR:-$XDG_CONFIG_HOME/zsh}/aliases/*.zsh; do
                source "$alias_file"
              done

              HISTSIZE=${toString zshConfig.history-memory}
              SAVEHIST=${toString zshConfig.history-storage}
               HISTFILE="${homeDirectory}/.local/state/zsh/history"
              setopt HIST_IGNORE_DUPS
              setopt HIST_IGNORE_ALL_DUPS
              setopt HIST_IGNORE_SPACE
              setopt HIST_EXPIRE_DUPS_FIRST
              setopt SHARE_HISTORY
              setopt EXTENDED_HISTORY
              ${lib.optionalString zshConfig.enableFancyPrompt ''
                PS1='%F{blue}%~ %(?.%F{green}.%F{red})%#%f '
              ''}
              zstyle ':completion:*' menu select
              zstyle ':completion:*' matcher-list \
                  'm:{a-zA-Z}={A-Za-z}' \
                  'r:|[._-]=* r:|=*' \
                  'l:|=* r:|=*'
              if [ "$(hostname)" = "${config.user.name}-laptop" ]; then
                  fanspeed() {
                      if [ -z "$1" ]; then
                          echo "Usage: fanspeed <percentage>"
                          return 1
                      fi
                      local speed="$1"
                      asusctl fan-curve -m quiet -D "30c:$speed,40c:$speed,50c:$speed,60c:$speed,70c:$speed,80c:$speed,90c:$speed,100c:$speed" -e true -f gpu
                      asusctl fan-curve -m quiet -D "30c:$speed,40c:$speed,50c:$speed,60c:$speed,70c:$speed,80c:$speed,90c:$speed,100c:$speed" -e true -f cpu
                  }
              fi
              temppkg() {
                  if [ -z "$1" ]; then
                      echo "Usage: temppkg package_name"
                      return 1
                  fi
                  nix-shell -p "$1" --run "exec $SHELL"
              }
              temprun() {
                  if [ -z "$1" ]; then
                      echo "Usage: temprun package_name [args...]"
                      return 1
                  fi
                  local pkg="$1"
                  shift
                  nix run "nixpkgs#$pkg" -- "$@"
              }
            '';
            clobber = true;
          };
        };
      };
    })
    (lib.mkIf zellijCfg.enable {
      hjem.users.${config.user.name} = {
        packages = with pkgs; [
          zellij
        ];
        files = {
          ".config/zellij/config.kdl" = {
            clobber = true;
            text = ''
              hide_session_name false
              on_force_close "quit"
              pane_frames true
              rounded_corners true
              session_serialization false
              show_startup_tips false
              simplified_ui false
            '';
          };
          ".config/zellij/layouts/music.kdl" = {
            clobber = true;
            text = ''
              layout alias="music" {
                  default_tab_template {
                      pane size=1 borderless=true {
                          plugin location="zellij:tab-bar"
                      }
                      children
                      pane size=2 borderless=true {
                          plugin location="zellij:status-bar"
                      }
                  }
                  tab name="Music" {
                      pane split_direction="vertical" {
                          pane command="cmus"
                          pane command="cava"
                      }
                  }
              }
            '';
          };
          ".config/zellij/layouts/ide.kdl" = {
            clobber = true;
            text = ideLayout;
          };
          ".config/zellij/config-ide.kdl" = {
            clobber = true;
            text = ''
              hide_session_name false
              on_force_close "quit"
              pane_frames true
              rounded_corners true
              session_serialization false
              show_startup_tips false
              simplified_ui true
            '';
          };
          ".config/zsh/.zshrc" = {
            clobber = true;
            text = lib.mkBefore (lib.optionalString zellijCfg.autoStart ''
              if [[ -z "$ZELLIJ" && -z "$SSH_CONNECTION" && "$TERM_PROGRAM" \!= "vscode" && -z "$NVIM" ]]; then
                  exec zellij
              fi
            '') + lib.mkAfter ''
              alias ide='zellij --layout ${config.user.configDirectory}/zellij/layouts/ide.kdl'
            '';
          };
        };
      };
    })
  ];
}
