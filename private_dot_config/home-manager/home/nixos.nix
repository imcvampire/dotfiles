{config, pkgs, ...}: {
  home.homeDirectory = "/home/${config.home.username}";
  home.packages = with pkgs; [
    bash

    python3
    ruby

    zed-editor
    jetbrains.idea
    bruno

    anytype
    bitwarden-desktop
    thunderbird

    brave
    ghostty
  ];
}
