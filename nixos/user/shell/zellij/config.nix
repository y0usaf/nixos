{
  config,
  lib,
  pkgs,
  flakeInputs,
  genLib,
  ...
}: let
  baseConfig =
    {
      hide_session_name = false;
      copy_on_select = true;
      show_startup_tips = false;
      on_force_close = "quit";
      session_serialization = false;
      pane_frames = true;
    }
    // lib.optionalAttrs config.user.shell.zellij.zjstatus.enable {
      default_layout = "zjstatus";
    }
    // config.user.shell.zellij.settings;

  zjstatusHintsConfig = let
    cfg = config.user.shell.zellij;
  in
    lib.optionalString (cfg.zjstatusHints.enable or false) ''
      plugins {
        zjstatus-hints location="file:${flakeInputs.zjstatus-hints.packages.${config.nixpkgs.system}.default}/bin/zjstatus-hints.wasm" {
          max_length ${toString (cfg.zjstatusHints.maxLength or 0)}
          pipe_name "${cfg.zjstatusHints.pipeName or "zjstatus_hints"}"
        }
      }

      load_plugins {
        zjstatus-hints
      }
    '';
in {
  config = lib.mkIf config.user.shell.zellij.enable {
    environment.systemPackages = [
      pkgs.zellij
    ];
    usr = {
      files =
        {
          ".config/zellij/config.kdl" = {
            clobber = false;
            text =
              genLib.toKDL baseConfig
              + "\n\n// Using default keybindings for now\n"
              + zjstatusHintsConfig;
          };
        }
        // lib.optionalAttrs (config.user.shell.zellij.autoStart && config.user.shell.zsh.enable) {
          ".config/zsh/aliases/zellij.zsh" = {
            clobber = true;
            text = ''
              # Skip if already in a multiplexer or SSH session (fast: variable checks only)
              [[ -n "$ZELLIJ" || -n "$SSH_CONNECTION" || -n "$TMUX" ]] && return

              # Skip if in virtual console
              # Fast path: TERM check (no subprocess)
              [[ "$TERM" == "linux" ]] && return

              # Robust fallback: device path check (minimal subprocess overhead)
              [[ $(readlink /proc/self/fd/0 2>/dev/null) =~ ^/dev/tty[0-9] ]] && return

              exec zellij
            '';
          };
        };
    };
  };
}
