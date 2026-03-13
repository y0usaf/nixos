# Den Migration Plan

## Goal

Move this repository toward a `den`-style architecture without doing a hard cutover or collapsing the current working flake while the model is still being proven.

This spike keeps two constraints:

- preserve the current host outputs until the den model is mechanically credible
- migrate by extraction, not by reinterpretation from memory

## Current Shape

The current flake is explicit and readable, but the composition rules are spread across a few different layers:

- [`flake.nix`](../../flake.nix) owns inputs and top-level output assembly
- [`nixos/lib/default.nix`](../../nixos/lib/default.nix) maps concrete host configs into `nixosConfigurations`
- [`configs/hosts`](../../configs/hosts) mixes host metadata, hardware, services, and user-profile selection
- [`configs/users`](../../configs/users) contains large user-profile modules, including host-specific variants
- [`nixos/user`](../../nixos/user) and [`darwin/user`](../../darwin/user) define the option surface and implementation modules
- [`lib`](../../lib) holds reusable feature modules that already behave a lot like den batteries/aspects

## What Already Looks Like Den

Several patterns in the repo are already den-shaped:

1. Host declarations are centralised in [`nixos/lib/default.nix`](../../nixos/lib/default.nix), even if they are not first-class schema entries yet.
2. The custom `user.*` tree in files like [`configs/users/y0usaf.nix`](../../configs/users/y0usaf.nix) is effectively a user schema plus a large bundle of aspects.
3. Shared feature modules under [`nixos/user`](../../nixos/user), [`nixos/system`](../../nixos/system), [`darwin/user`](../../darwin/user), and [`lib`](../../lib) are already reusable class-scoped components.
4. Host files repeatedly select the same clusters of behaviour: workstation vs laptop vs server, AMD vs Intel, NVIDIA vs AMDGPU, persistent vs impermanent, graphical vs headless.

## Main Friction To Fix First

The biggest migration obstacle is not flake wiring. It is the presence of multiple host-specific user profile files:

- [`configs/users/y0usaf.nix`](../../configs/users/y0usaf.nix)
- [`configs/users/y0usaf-dev.nix`](../../configs/users/y0usaf-dev.nix)
- [`configs/users/server.nix`](../../configs/users/server.nix)
- [`configs/users/y0usaf-darwin.nix`](../../configs/users/y0usaf-darwin.nix)

Those files currently mix:

- account definition
- user defaults
- platform-specific implementation
- host-profile choices

In den terms, they should become layered aspects instead of monolithic modules.

## Target Model

### Schema

Use den schema for stable inventory data:

- `den.hosts.<system>.<host>`
  - `hostName`
  - `profile` such as `desktop`, `portable`, `server`, `darwin-laptop`
  - `roles` such as `graphical`, `gaming`, `headless`, `impermanent`
- `den.hosts.<system>.<host>.users.<user>`
  - `classes` such as `hjem` on Linux or `homeManager` on Darwin
  - `homeDirectory`
  - `profile` such as `desktop`, `mobile`, `server`, `darwin`

Keep schema for data that should be queryable. Keep aspects for behaviour.

In the spike scaffold, `user.profile` is the routing seam for the legacy
profile imports. That is deliberate: profile choice belongs in inventory
data, while the imported module tree remains a temporary implementation detail.

### Aspects

Split behaviour into four groups:

1. Base platform aspects
   - `linux-base`
   - `darwin-base`

2. Host-shape aspects
   - `linux-workstation`
   - `linux-portable`
   - `linux-server`
   - `impermanent-host`
   - `headless-host`

3. Hardware aspects
   - `cpu-amd`
   - `cpu-intel`
   - `gpu-nvidia`
   - `gpu-amdgpu`

4. User/profile aspects
   - `y0usaf`
   - `profile-desktop`
   - `profile-mobile`
   - `profile-server`
   - `profile-darwin`

### Bridging Strategy

During migration, den aspects should import existing modules instead of rewriting them immediately.

Examples:

- host aspects can continue importing hardware modules from [`configs/hosts/*/hardware-configuration.nix`](../../configs/hosts)
- profile aspects can temporarily import the current profile files from [`configs/users`](../../configs/users)
- shared aspects can keep importing [`../../../nixos`](../../nixos) and [`../../../darwin`](../../darwin) as the base class payload

This keeps the first den branch honest: it is a translation layer around the current repo, not a parallel universe.

## Proposed Mapping

| Current file or pattern | Den destination |
| --- | --- |
| [`flake.nix`](../../flake.nix) Linux/Darwin output assembly | short-term bridge flake, later replaced by `inherit (den.flake)` outputs |
| [`nixos/lib/default.nix`](../../nixos/lib/default.nix) host map | `den.hosts.*` declarations |
| Repeated host metadata in [`configs/hosts/*/default.nix`](../../configs/hosts) | host schema fields |
| `../../../nixos` import in Linux hosts | `linux-base` aspect |
| `../../../darwin` import and Darwin bootstrap | `darwin-base` aspect |
| [`configs/users/y0usaf.nix`](../../configs/users/y0usaf.nix) | `y0usaf` base plus `profile-desktop` extraction |
| [`configs/users/y0usaf-dev.nix`](../../configs/users/y0usaf-dev.nix) | `profile-mobile` extraction |
| [`configs/users/server.nix`](../../configs/users/server.nix) | `profile-server` extraction |
| [`configs/users/y0usaf-darwin.nix`](../../configs/users/y0usaf-darwin.nix) | `profile-darwin` extraction |
| [`lib`](../../lib) reusable modules | den shared aspects or class-specific batteries |
| Host-specific impermanence modules | `impermanent-host` plus per-host imports |

The sidecar now uses `den.hosts.*.users.*.profile` to select those profile
aspects, so host inventory drives composition instead of duplicating profile
choices in host-local includes.

## Migration Phases

### Phase 0

Add a sidecar den module tree that is not wired into the root flake outputs yet.

Success criteria:

- host inventory is represented once in `den.hosts`
- current user/profile variants are represented explicitly
- aspect boundaries are visible enough to review

### Phase 1

Use den as a bridge inside the current flake, exactly as the upstream migration guide recommends:

- evaluate den modules separately
- attach `host.mainModule` to existing `nixosConfigurations` and `darwinConfigurations`
- keep current outputs intact

### Phase 2

Extract repeated host clusters:

- workstation defaults shared by desktop and laptop/framework
- server/headless defaults
- docker, tailscale, syncthing-proxy, controllers
- GPU and CPU feature clusters

### Phase 3

Split the large user profile files into smaller den aspects:

- account identity
- shared dev tools
- shared UI defaults
- shared shell/tools/services
- per-host profile overlays

### Phase 4

After Linux and Darwin evaluate cleanly through den, switch the flake outputs to:

```nix
inherit (den.flake) nixosConfigurations darwinConfigurations;
```

## Guardrails

- do not rewrite hardware modules during the den migration
- do not flatten the current `user.*` option tree until the den layering is proven
- do not switch to generated den outputs until Linux and Darwin hosts can both be evaluated from the den bridge
- keep server and framework impermanence logic host-local until a genuinely shared shape emerges

## Deliverables In This Spike

- [`experiments/den`](../../experiments/den) sidecar scaffold
- an initial schema proposal
- initial host declarations
- initial shared, host, and profile aspect boundaries
