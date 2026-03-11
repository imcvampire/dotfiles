{
  description = "NixOS and nix-darwin configuration with Home Manager";

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
    allUsers = import ./user.nix;
    darwinConfig = allUsers.darwin;
    nixosConfig = allUsers.nixos;
    brewCustom = import ./brew-custom.nix;

    hmSharedModules = [
      # stylix.homeManagerModules.stylix
      nix-index-database.homeModules.nix-index
      {programs.nix-index-database.comma.enable = true;}
    ];
  in {
    darwinConfigurations."${darwinConfig.hostname}" = nix-darwin.lib.darwinSystem {
      modules = [
        {
          nixpkgs.hostPlatform = darwinConfig.system;
          nixpkgs.config.allowUnfree = true;
        }
        ./hosts/darwin/default.nix

        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.${darwinConfig.username} = {
            imports = [
              ./home/shared.nix
              ./home/darwin.nix
            ];
          };
          home-manager.extraSpecialArgs = {
            inherit inputs;
            system = darwinConfig.system;
          };
          home-manager.sharedModules =
            [
              # mac-app-util.homeManagerModules.default
            ]
            ++ hmSharedModules;
        }
      ];

      specialArgs = {
        inherit self brewCustom;
        userConfig = darwinConfig;
      };
    };

    nixosConfigurations."${nixosConfig.hostname}" = nixpkgs.lib.nixosSystem {
      modules = [
        {
          nixpkgs.hostPlatform = nixosConfig.system;
          nixpkgs.config.allowUnfree = true;
        }
        ./hosts/nixos/default.nix

        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.${nixosConfig.username} = {
            imports = [
              ./home/shared.nix
              ./home/nixos.nix
            ];
          };
          home-manager.extraSpecialArgs = {
            inherit inputs;
            system = nixosConfig.system;
          };
          home-manager.sharedModules = hmSharedModules;
        }
      ];

      specialArgs = {
        inherit self;
        userConfig = nixosConfig;
      };
    };

    formatter =
      nixpkgs.lib.genAttrs
      [darwinConfig.system nixosConfig.system]
      (system: nixpkgs.legacyPackages.${system}.alejandra);
  };
}
