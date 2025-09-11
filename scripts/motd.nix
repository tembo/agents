{pkgs, ...}: let
  motd = [
    "Welcome to AI-Agents by Tembo"
    ""
    "Intersted in running background agents? Check out tembo.io!"
  ];
in
  pkgs.writeShellScriptBin "motd" ''
    echo "${builtins.concatStringsSep "\n" motd}" | ${pkgs.boxes}/bin/boxes -d simple -p a2
    if [ ! -t 0 ] || [ ! -t 1 ]; then
      echo -n "Non-TTY shell detected, you probably want to run:\n docker run -it ai-agents:latest" | ${pkgs.boxes}/bin/boxes -d warning -p a2
    fi
  ''
