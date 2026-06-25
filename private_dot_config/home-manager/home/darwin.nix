{config, ...}: {
  imports = [
    ./modules/ghost-complete.nix
  ];

  home.homeDirectory = "/Users/${config.home.username}";

  programs.zsh.profileExtra = ''
    eval "$(/opt/homebrew/bin/brew shellenv)"
  '';
}
