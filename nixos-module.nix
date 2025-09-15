{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.services.tembo-ai-agents;
  tools = import ./tools.nix {inherit pkgs;};
in {
  options.services.tembo-ai-agents = {
    enable = mkEnableOption "Tembo AI Agents service";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = tools;
  };

  meta = {
    maintainers = [];
    description = "NixOS module for Tembo AI Agents";
  };
}
