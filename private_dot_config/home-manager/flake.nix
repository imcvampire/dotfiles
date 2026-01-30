{
  description = "nix-darwin configuration with Home Manager";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database.url = "github:Mic92/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    # stylix.url = "github:danth/stylix";

    # mac-app-util.url = "github:hraban/mac-app-util";
  };

  outputs = {
    self,
    nixpkgs,
    nix-darwin,
    home-manager,
    nix-index-database,
    # stylix,
    # mac-app-util,
    ...
  } @ inputs: let
    userConfig = import ./user.nix;
    brewCustom = import ./brew-custom.nix;
    system = userConfig.system;
    username = userConfig.username;
  in {
    darwinConfigurations."${userConfig.hostname}" = nix-darwin.lib.darwinSystem {
      modules = [
        {
          nixpkgs.hostPlatform = system;
          nixpkgs.config.allowUnfree = true;
        }
        ./darwin-configuration.nix

        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.${username} = import ./home.nix;
          home-manager.extraSpecialArgs = {
            inherit system inputs;
          };
          home-manager.sharedModules = [
            # mac-app-util.homeManagerModules.default
            # stylix.homeManagerModules.stylix
            nix-index-database.homeModules.nix-index
            {programs.nix-index-database.comma.enable = true;}
          ];
        }
      ];

      specialArgs = {
        inherit self userConfig brewCustom;
      };
    };

    formatter.${system} = nixpkgs.legacyPackages.${system}.alejandra;
  };
}
