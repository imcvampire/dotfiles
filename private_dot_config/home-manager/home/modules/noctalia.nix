{
  lib,
  pkgs,
  ...
}: let
  defaultNiriConfig = builtins.readFile "${pkgs.niri.src}/resources/default-config.kdl";
  niriConfig =
    lib.replaceStrings
    [
      ''// layout "us,ru"''
      ''// options "grp:win_space_toggle,compose:ralt,ctrl:nocaps"''
      ''spawn-at-startup "waybar"''
      ''Mod+Shift+Slash { show-hotkey-overlay; }''
      ''Mod+T hotkey-overlay-title="Open a Terminal: alacritty" { spawn "alacritty"; }''
      ''Mod+D hotkey-overlay-title="Run an Application: fuzzel" { spawn "fuzzel"; }''
      ''XF86AudioRaiseVolume allow-when-locked=true { spawn-sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1+ -l 1.0"; }''
      ''XF86AudioLowerVolume allow-when-locked=true { spawn-sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1-"; }''
      ''XF86AudioMute        allow-when-locked=true { spawn-sh "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"; }''
      ''XF86MonBrightnessUp allow-when-locked=true { spawn "brightnessctl" "--class=backlight" "set" "+10%"; }''
      ''XF86MonBrightnessDown allow-when-locked=true { spawn "brightnessctl" "--class=backlight" "set" "10%-"; }''
      ''Mod+Comma  { consume-window-into-column; }''
    ]
    [
      ''layout "us"''
      ''options "ctrl:nocaps"''
      ''spawn-at-startup "noctalia"''
      ''
        Mod+Shift+Slash { show-hotkey-overlay; }

        Mod+Space { spawn-sh "noctalia msg panel-toggle launcher"; }
        Mod+S { spawn-sh "noctalia msg panel-toggle control-center"; }
        Mod+Comma { spawn-sh "noctalia msg settings-toggle"; }''
      ''Mod+T hotkey-overlay-title="Open a Terminal: ghostty" { spawn "ghostty"; }''
      ''Mod+D hotkey-overlay-title="Run an Application: Noctalia Launcher" { spawn-sh "noctalia msg panel-toggle launcher"; }''
      ''XF86AudioRaiseVolume allow-when-locked=true { spawn-sh "noctalia msg volume-up"; }''
      ''XF86AudioLowerVolume allow-when-locked=true { spawn-sh "noctalia msg volume-down"; }''
      ''XF86AudioMute        allow-when-locked=true { spawn-sh "noctalia msg volume-mute"; }''
      ''XF86MonBrightnessUp allow-when-locked=true { spawn-sh "noctalia msg brightness-up"; }''
      ''XF86MonBrightnessDown allow-when-locked=true { spawn-sh "noctalia msg brightness-down"; }''
      ''Mod+Shift+Comma { consume-window-into-column; }''
    ]
    defaultNiriConfig
    + ''

      // Noctalia shell integration for Niri.
      window-rule {
          geometry-corner-radius 20
          clip-to-geometry true
      }

      window-rule {
          match app-id="dev.noctalia.Noctalia.Settings"
          open-floating true
          default-column-width { fixed 1080; }
          default-window-height { fixed 920; }
      }

      debug {
          honor-xdg-activation-with-invalid-serial
      }
    '';
in {
  home.packages = with pkgs; [
    swaylock
  ];

  programs.noctalia = {
    enable = true;
    settings.shell.niri_overview_type_to_launch_enabled = true;
    settings.bar.main = {
      margin_ends = 0;
      margin_edge = 0;
      padding = 0;
      radius = 0;
    };
  };

  xdg.configFile."niri/config.kdl".text = niriConfig;
}
