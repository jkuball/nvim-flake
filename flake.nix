{
  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixvim.url = "github:nix-community/nixvim";
    devshell.url = "github:numtide/devshell";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    typenix.url = "github:ryanrasti/typenix";
  };

  outputs =
    { self
    , flake-parts
    , nixvim
    , ...
    } @ inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.devshell.flakeModule
        inputs.flake-parts.flakeModules.easyOverlay
        inputs.treefmt-nix.flakeModule
      ];

      systems = [
        "x86_64-linux"
        "aarch64-darwin"
      ];

      perSystem =
        # @ts: { system: string; pkgs: Nixpkgs; [key: string]: any }
        { system, pkgs, config, ... }:
        {
          _module.args.pkgs = import inputs.nixpkgs {
            inherit system;
            overlays = [ self.overlays.default ];
          };

          overlayAttrs = {
            typenix = inputs.typenix.packages.${system}.typenix;
          };

          treefmt.programs = {
            nixpkgs-fmt.enable = true;
            deadnix.enable = true;
          };

          devshells."default" = {
            packages = [
              config.packages.default
              pkgs.typenix
            ];
          };

          packages."default" = nixvim.legacyPackages.${system}.makeNixvimWithModule {
            inherit pkgs;
            module = self.nixvimModules.default;
          };

          checks."typenix" = pkgs.runCommand "typenix-check"
            { nativeBuildInputs = [ pkgs.typenix ]; }
            ''
              typenix -p ${self}
              touch $out
            '';
        };

      flake = {
        nixvimModules.default = ./modules;
      };
    };
}
