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
    userConfig = import ./user.nix;
    system = userConfig.system;
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    homeConfigurations."${userConfig.username}" = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;

      modules = [
        mac-app-util.homeManagerModules.default
        # stylix.homeManagerModules.stylix
        {
          home.username = "${userConfig.username}";
        }
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
