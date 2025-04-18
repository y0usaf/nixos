###############################################################################
# AGS Module
# Configures AGS (Astal GTK Shell) for custom desktop widgets
# - Provides a simple time widget
# - Configures TypeScript and SCSS styling
# - Sets up the necessary configuration files
###############################################################################
{
  config,
  pkgs,
  lib,
  host,
  ...
}: let
  cfg = config.cfg.ui.ags;
in {
  ###########################################################################
  # Module Options
  ###########################################################################
  options.cfg.ui.ags = {
    enable = lib.mkEnableOption "AGS (Astal GTK Shell)";
  };

  ###########################################################################
  # Module Configuration
  ###########################################################################
  config = lib.mkIf cfg.enable {
    ###########################################################################
    # Packages
    ###########################################################################
    home.packages = with pkgs; [ags];

    ###########################################################################
    # Configuration Files
    ###########################################################################
    xdg.configFile = {
      # Main TypeScript files
      "ags/app.ts".text = ''
        import { App } from "astal/gtk3"
        import style from "./style.scss"
        import TimeWidget from "./widget/TimeWidget"

        App.start({
            css: style,
            main() {
                App.get_monitors().map(TimeWidget)
            },
        })
      '';

      # SCSS styling
      "ags/style.scss".text = ''
        // https://gitlab.gnome.org/GNOME/gtk/-/blob/gtk-3-24/gtk/theme/Adwaita/_colors-public.scss
        $fg-color: #{"@theme_fg_color"};
        $bg-color: #{"@theme_bg_color"};

        window.TimeWidget {
            background: transparent;
            color: $fg-color;
            font-weight: bold;

            >box {
                background: $bg-color;
                border-radius: 10px;
                padding: 16px 24px;
            }

            label {
                font-size: 24px;
            }
        }
      '';

      # TypeScript declarations
      "ags/env.d.ts".text = ''
        declare const SRC: string

        declare module "inline:*" {
            const content: string
            export default content
        }

        declare module "*.scss" {
            const content: string
            export default content
        }

        declare module "*.blp" {
            const content: string
            export default content
        }

        declare module "*.css" {
            const content: string
            export default content
        }
      '';

      # TypeScript configuration
      "ags/tsconfig.json".text = ''
        {
            "$schema": "https://json.schemastore.org/tsconfig",
            "compilerOptions": {
                "experimentalDecorators": true,
                "strict": true,
                "target": "ES2022",
                "module": "ES2022",
                "moduleResolution": "node",
                // "checkJs": true,
                // "allowJs": true,
                "jsx": "react-jsx",
                "jsxImportSource": "astal/gtk3",
                "outDir": ".",
                "rootDir": "."
            }
        }
      '';

      # Package configuration
      "ags/package.json".text = ''
        {
            "name": "astal-shell",
            "type": "module",
            "dependencies": {
                "astal": "/nix/store/9c0pmm7xai3v3ghmr0mgywprrykqj64v-astal-gjs-0-unstable-2025-02-20/share/astal/gjs"
            }
        }
      '';

      # Gitignore
      "ags/.gitignore".text = ''
        node_modules/
        @girs/
      '';

      # Widget component
      "ags/widget/TimeWidget.tsx".text = ''
        import { App, Astal, Gtk, Gdk } from "astal/gtk3"
        import { Variable } from "astal"

        const time = Variable("").poll(1000, "date '+%H:%M:%S'")

        export default function TimeWidget(gdkmonitor: Gdk.Monitor) {
            const { CENTER } = Astal.WindowAnchor

            return <window
                className="TimeWidget"
                gdkmonitor={gdkmonitor}
                exclusivity={Astal.Exclusivity.EXCLUSIVE}
                anchor={CENTER}
                application={App}>
                <box>
                    <label label={time()} />
                </box>
            </window>
        }
      '';
    };
  };
}
