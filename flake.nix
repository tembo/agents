{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    nix-ai-tools.url = "github:numtide/nix-ai-tools";

    nix2container.url = "github:nlewo/nix2container";

    flake-parts.url = "github:hercules-ci/flake-parts";

    haumea = {
      url = "github:nix-community/haumea/v0.2.2";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} ({
      config,
      withSystem,
      moduleWithSystem,
      ...
    }: {
      imports = [];
      flake = {};
      systems = [
        "x86_64-linux"
      ];
      perSystem = {
        config,
        pkgs,
        system,
        ...
      }: let
        nix2containerPkgs = inputs.nix2container.packages.${system};

        tools = import ./tools.nix {inherit pkgs;};

        scripts = inputs.haumea.lib.load {
          src = ./scripts;
          inputs = {
            inherit pkgs;
          };
        };

        docker = import ./docker.nix {
          inherit inputs pkgs nix2containerPkgs config tools;
          scripts = builtins.attrValues scripts;
        };
      in {
        _module.args.pkgs = import inputs.nixpkgs {
          inherit system;
          overlays = [
            (final: prev: inputs.nix-ai-tools.packages.${system})
          ];
          config = {};
        };

        devShells.default = pkgs.mkShell {
          shellHook = ''
            ${scripts.motd}/bin/motd
          '';
          packages = tools ++ (builtins.attrValues scripts);
        };

        packages =
          scripts
          // {
            inherit docker;
          };
      };
    });
}
