inputs: {
  # Keep source-only inputs as paths.
  "nixpkgs-discord-legacy" = source: source // {flake = false;};
  "with-inputs" = source: source // {flake = false;};

  # Local path inputs from pi-flake.
  "piCodexFast" = {
    outPath = inputs."pi-flake".outPath + "/extensions/pi-codex-fast";
    inputs."nixpkgs".follows = "nixpkgs";
  };
  "piCompact" = {
    outPath = inputs."pi-flake".outPath + "/extensions/pi-compact";
    inputs."nixpkgs".follows = "nixpkgs";
  };
  "piContextJanitor" = {
    outPath = inputs."pi-flake".outPath + "/extensions/pi-context-janitor";
    inputs."nixpkgs".follows = "nixpkgs";
  };
  "piGeckoWebsearch" = {
    outPath = inputs."pi-flake".outPath + "/extensions/pi-gecko-websearch";
    inputs."nixpkgs".follows = "nixpkgs";
  };
  "piHashline" = {
    outPath = inputs."pi-flake".outPath + "/extensions/pi-hashline";
    inputs."nixpkgs".follows = "nixpkgs";
  };
  "piMinimalUi" = {
    outPath = inputs."pi-flake".outPath + "/extensions/pi-minimal-ui";
    inputs."nixpkgs".follows = "nixpkgs";
  };
  "piMorph" = {
    outPath = inputs."pi-flake".outPath + "/extensions/pi-morph";
    inputs."nixpkgs".follows = "nixpkgs";
  };
  "piRtk" = {
    outPath = inputs."pi-flake".outPath + "/extensions/pi-rtk";
    inputs."nixpkgs".follows = "nixpkgs";
  };
  "piToolManagement" = {
    outPath = inputs."pi-flake".outPath + "/extensions/pi-tool-management";
    inputs."nixpkgs".follows = "nixpkgs";
  };
  "piWebfetch" = {
    outPath = inputs."pi-flake".outPath + "/extensions/pi-webfetch";
    inputs."nixpkgs".follows = "nixpkgs";
  };

  # Sub-input follows reconstructed from flake.lock; absolute follows are collapsed to concrete sources to avoid cycles.
  "agent-harness" = {
    inputs = {
      "crane".follows = "crane";
      "nixpkgs".follows = "nixpkgs";
      "rust-overlay".follows = "rust-overlay";
    };
  };
  "agent-slack".inputs."flake-utils".follows = "flake-utils";
  "agent-slack".inputs."nixpkgs".follows = "nixpkgs";
  "bun2nix" = {
    inputs = {
      "flake-parts".follows = "flake-parts";
      "import-tree".follows = "import-tree";
      "nixpkgs".follows = "nixpkgs";
      "systems".follows = "systems_7";
      "treefmt-nix".follows = "treefmt-nix";
    };
  };
  "claude-code-nix".inputs."flake-utils".follows = "flake-utils_2";
  "claude-code-nix".inputs."nixpkgs".follows = "nixpkgs";
  "codex-cli-nix".inputs."flake-utils".follows = "flake-utils_3";
  "codex-cli-nix".inputs."nixpkgs".follows = "nixpkgs";
  "codex-desktop-linux".inputs."flake-utils".follows = "flake-utils_4";
  "codex-desktop-linux".inputs."nixpkgs".follows = "nixpkgs";
  "cursors".inputs."flake-utils".follows = "flake-utils_5";
  "cursors".inputs."nixpkgs".follows = "nixpkgs";
  "fast-fonts".inputs."nixpkgs".follows = "nixpkgs";
  "flake-parts".inputs."nixpkgs-lib".follows = "nixpkgs";
  "flake-parts_2".inputs."nixpkgs-lib".follows = "nixpkgs";
  "flake-parts_3".inputs."nixpkgs-lib".follows = "nixpkgs-lib";
  "flake-parts_4".inputs."nixpkgs-lib".follows = "nixpkgs";
  "flake-utils".inputs."systems".follows = "systems";
  "flake-utils_2".inputs."systems".follows = "systems_2";
  "flake-utils_3".inputs."systems".follows = "systems_3";
  "flake-utils_4".inputs."systems".follows = "systems_4";
  "flake-utils_5".inputs."systems".follows = "systems_5";
  "flake-utils_6".inputs."systems".follows = "systems_8";
  "gpui-shell" = {
    inputs = {
      "crane".follows = "crane_2";
      "matugen".follows = "matugen";
      "nixpkgs".follows = "nixpkgs";
      "rust-overlay".follows = "rust-overlay_2";
    };
  };
  "handy".inputs."bun2nix".follows = "bun2nix";
  "handy".inputs."nixpkgs".follows = "nixpkgs";
  "hermes-agent" = {
    inputs = {
      "flake-parts".follows = "flake-parts_2";
      "nixpkgs".follows = "nixpkgs";
      "pyproject-build-systems".follows = "pyproject-build-systems";
      "pyproject-nix".follows = "pyproject-nix_2";
      "uv2nix".follows = "uv2nix_2";
    };
  };
  "home-manager".inputs."nixpkgs".follows = "nixpkgs_2";
  "home-manager_2".inputs."nixpkgs".follows = "nixpkgs";
  "impermanence".inputs."home-manager".follows = "home-manager";
  "impermanence".inputs."nixpkgs".follows = "nixpkgs_2";
  "linear-cli".inputs."deno2nix".follows = "deno2nix";
  "linear-cli".inputs."nixpkgs".follows = "nixpkgs";
  "mango" = {
    inputs = {
      "flake-parts".follows = "flake-parts_3";
      "nixpkgs".follows = "nixpkgs";
      "scenefx".follows = "scenefx";
    };
  };
  "manzil".inputs."nixpkgs".follows = "nixpkgs";
  "matugen".inputs."nixpkgs".follows = "nixpkgs__node";
  "matugen".inputs."systems".follows = "systems_6";
  "nh".inputs."nixpkgs".follows = "nixpkgs";
  "niri".inputs."nixpkgs".follows = "nixpkgs";
  "niri".inputs."rust-overlay".follows = "rust-overlay_3";
  "nix-formatter-pack" = {
    inputs = {
      "nixpkgs".follows = "nixpkgs";
      "nmd".follows = "nmd";
      "nmt".follows = "nmt";
    };
  };
  "nix-on-droid" = {
    inputs = {
      "home-manager".follows = "home-manager_2";
      "nix-formatter-pack".follows = "nix-formatter-pack";
      "nixpkgs".follows = "nixpkgs";
      "nixpkgs-docs".follows = "nixpkgs-docs";
      "nixpkgs-for-bootstrap".follows = "nixpkgs-for-bootstrap";
      "nmd".follows = "nmd";
    };
  };
  "nmd".inputs."nixpkgs".follows = "nixpkgs-docs";
  "nmd".inputs."scss-reset".follows = "scss-reset";
  "nvtune".inputs."nixpkgs".follows = "nixpkgs";
  "obs-image-reaction".inputs."flake-utils".follows = "flake-utils_6";
  "obs-image-reaction".inputs."nixpkgs".follows = "nixpkgs";
  "patchix".inputs."nixpkgs".follows = "nixpkgs";
  "pi-flake" = {
    inputs = {
      "nixpkgs".follows = "nixpkgs";
      "piCodexFast".follows = "piCodexFast";
      "piCompact".follows = "piCompact";
      "piContextJanitor".follows = "piContextJanitor";
      "piGeckoWebsearch".follows = "piGeckoWebsearch";
      "piHashline".follows = "piHashline";
      "piMinimalUi".follows = "piMinimalUi";
      "piMorph".follows = "piMorph";
      "piRtk".follows = "piRtk";
      "piSrc".follows = "piSrc";
      "piToolManagement".follows = "piToolManagement";
      "piWebfetch".follows = "piWebfetch";
    };
  };
  "pyproject-build-systems" = {
    inputs = {
      "nixpkgs".follows = "nixpkgs";
      "pyproject-nix".follows = "pyproject-nix";
      "uv2nix".follows = "uv2nix";
    };
  };
  "pyproject-nix".inputs."nixpkgs".follows = "nixpkgs";
  "pyproject-nix_2".inputs."nixpkgs".follows = "nixpkgs";
  "pyproject-nix_3".inputs."nixpkgs".follows = "nixpkgs";
  "rudo".inputs."nixpkgs".follows = "nixpkgs";
  "rust-overlay".inputs."nixpkgs".follows = "nixpkgs";
  "rust-overlay_2".inputs."nixpkgs".follows = "nixpkgs";
  "rust-overlay_3".inputs."nixpkgs".follows = "nixpkgs";
  "rust-overlay_4".inputs."nixpkgs".follows = "nixpkgs_4";
  "scenefx".inputs."nixpkgs".follows = "nixpkgs";
  "strictix" = {
    inputs = {
      "flake-parts".follows = "flake-parts_4";
      "nixpkgs".follows = "nixpkgs";
      "systems".follows = "systems_9";
    };
  };
  "treefmt-nix".inputs."nixpkgs".follows = "nixpkgs";
  "tweakcc".inputs."nixpkgs".follows = "nixpkgs";
  "uv2nix".inputs."nixpkgs".follows = "nixpkgs";
  "uv2nix".inputs."pyproject-nix".follows = "pyproject-nix";
  "uv2nix_2".inputs."nixpkgs".follows = "nixpkgs";
  "uv2nix_2".inputs."pyproject-nix".follows = "pyproject-nix_3";
  "zjstatus-hints" = {
    inputs = {
      "crane".follows = "crane_3";
      "nixpkgs".follows = "nixpkgs_4";
      "rust-overlay".follows = "rust-overlay_4";
    };
  };
}
