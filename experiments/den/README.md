# Den Sidecar Spike

This directory is an architecture spike, not the active flake path.

Its purpose is to translate the current repo into den concepts with the smallest possible amount of invention:

- `modules/schema.nix` defines stable host/user inventory fields
- `modules/hosts.nix` declares the concrete machines and user profiles
- `modules/aspects/shared.nix` captures repeated platform and service clusters
- `modules/aspects/hosts.nix` carries host-local hardware and one-off overrides
- `modules/aspects/users.nix` models the current user-profile variants as explicit profile aspects

The design goal is incremental adoption:

1. keep existing modules importable
2. expose current structure as `den.hosts` plus `den.aspects`
3. split monolithic user files only after the mapping is reviewable

