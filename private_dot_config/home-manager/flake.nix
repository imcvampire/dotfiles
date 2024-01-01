{
  description = "Home Manager configuration of nqa";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database.url = "github:Mic92/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    nixpkgs,
    home-manager,
    nix-index-database,
    ...
  }: let
    system = "x86_64-darwin";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    homeConfigurations."nqa" = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;

      modules = [
        ./user.nix
        ./home.nix
        nix-index-database.hmModules.nix-index
      ];
    };

    formatter.x86_64-darwin = nixpkgs.legacyPackages.x86_64-darwin.alejandra;
  };
}
