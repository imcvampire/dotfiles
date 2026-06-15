{pkgs, ...}: {
  home.packages = with pkgs; [
    swaylock
  ];

  programs.noctalia = {
    enable = true;
    settings.shell = {
      niri_overview_type_to_launch_enabled = true;
    };
    settings.location.auto_locate = true;
    settings.nightlight.enabled = true;
    settings.bar.main = {
      margin_ends = 0;
      margin_edge = 0;
      start = ["launcher" "workspaces"];
    };
  };

  xdg.configFile."niri/config.kdl".source = ./niri.kdl;
}
