{config, pkgs, ...}: {
  home.homeDirectory = "/home/${config.home.username}";
  home.packages = with pkgs; [
    python3

    anytype
    bitwarden-desktop
    brave
    ghostty
  ];
}
