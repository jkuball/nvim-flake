{
  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    nixvim.url = "github:nix-community/nixvim";
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
        inputs.treefmt-nix.flakeModule
      ];

      systems = [
        "x86_64-linux"
        "aarch64-darwin"
      ];

      perSystem =
        { system, pkgs, ... }:
        let
          pkgs' = import inputs.nixpkgs {
            inherit system;
            overlays = [ self.overlays.default ];
          };
        in
        {
          treefmt.programs = {
            nixpkgs-fmt.enable = true;
            deadnix.enable = true;
          };

          packages."default" = nixvim.legacyPackages.${system}.makeNixvimWithModule {
            pkgs = pkgs';
            module = self.nixvimModules.default;
          };
        };

      flake = {
        overlays.default = final: prev: {
          typenix = inputs.typenix.packages.${prev.system}.typenix;
        };

        nixvimModules.default = ./modules;
      };
    };
}
