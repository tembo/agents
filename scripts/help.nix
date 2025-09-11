{pkgs, ...}: let
in
  pkgs.writeShellScriptBin "help" ''
    echo "Help coming soon"
  ''
