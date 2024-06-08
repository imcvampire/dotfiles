{
  description = "Home Manager configuration of nqa";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
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
    userConfig = import ./user.nix;
  in {
    homeConfigurations."${userConfig.home.username}" = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;

      modules = [
        userConfig
        ./home.nix
        nix-index-database.hmModules.nix-index
        { programs.nix-index-database.comma.enable = true; }
      ];

      extraSpecialArgs = {
        inherit system;
      };
    };

    formatter."${system}" = nixpkgs.legacyPackages.${system}.alejandra;
  };
}
