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
        inputs.flake-parts.flakeModules.easyOverlay
      ];

      systems = [
        "x86_64-linux"
        "aarch64-darwin"
      ];

      perSystem =
        { system, pkgs, ... }:
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
