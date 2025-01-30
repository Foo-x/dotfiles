{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, home-manager, } @ inputs:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        apps.update = {
          type = "app";
          program = toString (pkgs.writeShellScript "update-script" ''
            set -e
            echo "Updating flake ..."
            nix flake update
            echo "Updating home-manager ..."
            nix run .#switch-home
            echo "Update complete!"
          '');
        };
        apps.switch-home = {
          type = "app";
          program = toString (pkgs.writeShellScript "switch-home" ''
            set -e
            nix run nixpkgs#home-manager -- switch --flake .#myHomeConfig --impure
          '');
        };
      }
    )
    // flake-utils.lib.eachDefaultSystemPassThrough (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        homeConfigurations = {
          myHomeConfig = home-manager.lib.homeManagerConfiguration {
            pkgs = pkgs;
            extraSpecialArgs = {
              inherit inputs;
            };
            modules = [
              ./.config/home-manager/home.nix
            ];
          };
        };
      }
    );
}
