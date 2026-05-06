let
  sources = builtins.mapAttrs (_: source:
    if builtins.isAttrs source
    then
      source
      // (if source ? revision then {
        rev = source.revision;
        shortRev = builtins.substring 0 7 source.revision;
      } else {})
      // (if source ? hash then {
        narHash = source.hash;
      } else {})
    else source) (import ./npins);
in
  (import sources.with-inputs sources (import ./follows.nix)) (import ./outputs.nix)
