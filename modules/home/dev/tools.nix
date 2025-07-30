{
  config,
  pkgs,
  lib,
  ...
}: let
  cursorCfg = config.home.dev.cursor-ide;
  latexCfg = config.home.dev.latex;
  repomixCfg = config.home.dev.repomix;
  upscaleCfg = config.home.dev.upscale;
in {
  options = {
    # dev/cursor-ide.nix (17 lines -> INLINED\!)
    home.dev.cursor-ide = {
      enable = lib.mkEnableOption "Cursor IDE";
    };
    # dev/latex.nix (19 lines -> INLINED\!)
    home.dev.latex = {
      enable = lib.mkEnableOption "LaTeX development environment";
    };
    # dev/repomix.nix (23 lines -> INLINED\!)
    home.dev.repomix = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable repomix tool for AI-friendly repository packing";
      };
    };
    # dev/upscale.nix (28 lines -> INLINED\!)
    home.dev.upscale = {
      enable = lib.mkEnableOption "realesrgan-ncnn-vulkan for upscaling";
    };
  };
  config = lib.mkMerge [
    (lib.mkIf cursorCfg.enable {
      hjem.users.${config.user.name}.packages = with pkgs; [
        code-cursor
      ];
    })
    (lib.mkIf latexCfg.enable {
      hjem.users.${config.user.name}.packages = with pkgs; [
        texliveFull
        texstudio
        tectonic
      ];
    })
    (lib.mkIf repomixCfg.enable {
      hjem.users.${config.user.name}.packages = with pkgs; [
        repomix
      ];
    })
    (lib.mkIf upscaleCfg.enable {
      hjem.users.${config.user.name} = {
        packages = with pkgs; [
          realesrgan-ncnn-vulkan
        ];
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
