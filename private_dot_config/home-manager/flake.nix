{
  description = "Home Manager configuration of nqa";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database.url = "github:Mic92/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    # stylix.url = "github:danth/stylix";

    mac-app-util.url = "github:hraban/mac-app-util";
  };

  outputs = {
    nixpkgs,
    home-manager,
    nix-index-database,
    # stylix,
    mac-app-util,
    ...
  }: let
    system = "x86_64-darwin";
    pkgs = nixpkgs.legacyPackages.${system};
    userConfig = import ./user.nix;
  in {
    homeConfigurations."${userConfig.home.username}" = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;

      modules = [
        mac-app-util.homeManagerModules.default
        userConfig
        # stylix.homeManagerModules.stylix
        ./home.nix
        nix-index-database.hmModules.nix-index
        {programs.nix-index-database.comma.enable = true;}
      ];

      extraSpecialArgs = {
        inherit system;
      };
    };

    formatter."${system}" = nixpkgs.legacyPackages.${system}.alejandra;
  };
}
