{config, pkgs, ...}: {
  home.homeDirectory = "/home/${config.home.username}";
  home.packages = with pkgs; [
    bash

    python3
    ruby

    jetbrains.idea
    zed

    anytype
    bitwarden-desktop
    brave
    ghostty
  ];
}
