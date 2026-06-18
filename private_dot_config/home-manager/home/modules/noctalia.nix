{
  config,
  lib,
  pkgs,
  ...
}: let
  lockCommand = pkgs.writeShellScript "noctalia-lock-session" ''
    ${lib.getExe config.programs.noctalia.package} msg session lock
    ${lib.getExe' pkgs.coreutils "sleep"} 1
  '';
in {
  programs.noctalia = {
    enable = true;
    systemd.enable = true;
    settings.shell = {
      niri_overview_type_to_launch_enabled = true;
    };
    settings.lockscreen.enabled = true;
    settings.location.auto_locate = true;
    settings.nightlight.enabled = true;
    settings.bar.main = {
      margin_ends = 0;
      margin_edge = 0;
      start = ["launcher" "workspaces"];
    };
  };

  services.swayidle = {
    enable = true;
    systemdTargets = ["graphical-session.target"];
    events.before-sleep = "${lockCommand}";
  };

  xdg.configFile."niri/config.kdl".source = ./niri.kdl;
}
