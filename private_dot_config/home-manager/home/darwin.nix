{config, ...}: {
  imports = [
    ./modules/ghost-complete.nix
  ];

  home.homeDirectory = "/Users/${config.home.username}";
}
