{config, pkgs, ...}: {
  home.homeDirectory = "/home/${config.home.username}";
  home.packages = with pkgs; [
    bash

    python3
    ruby

    anytype
    bitwarden-desktop
    brave
    ghostty
  ];
}
