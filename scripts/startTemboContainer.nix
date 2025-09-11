{
  pkgs,
  config,
  ...
}: let
  motd = config.packages.motd;
in
  pkgs.writeShellScriptBin "startTemboContainer" ''
    ${motd}/bin/motd
    ${pkgs.zsh}/bin/zsh
  ''
