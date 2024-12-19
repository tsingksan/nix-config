{ pkgs, nodejs }:

let
  pnpm-shim = pkgs.writeShellScriptBin "pnpm" "exec \"${pkgs.lib.getBin nodejs}/bin/node\" \"${pkgs.lib.getBin nodejs}/bin/corepack\" pnpm \"$@\"";

in pnpm-shim