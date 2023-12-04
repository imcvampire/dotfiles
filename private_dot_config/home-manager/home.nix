{ config, pkgs, ... }:

{
  home.username = "nqa";
  home.homeDirectory = "/Users/nqa";

  home.stateVersion = "23.05";

  home.packages = [
    pkgs.pgcli
    pkgs.asdf-vm
  ];

  home.file = {
  };

  # You can also manage environment variables but you will have to manually
  # source
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/nqa/etc/profile.d/hm-session-vars.sh
  #
  # if you don't want to manage your shell through Home Manager.
  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  programs = {
    home-manager = {
      enable = true;
    };

    direnv = {
      enable = true;
    };

    k9s = {
      enable = true;
    };

    ripgrep = {
      enable = true;
    };

    less = {
      enable = true;
    };

    lesspipe = {
      enable = true;
    };

    bat = {
      enable = true;
      config = {
        theme = "gruvbox-dark";
        italic-text = "always";
      };
    };

    nix-index.enable = true;
  };
}
