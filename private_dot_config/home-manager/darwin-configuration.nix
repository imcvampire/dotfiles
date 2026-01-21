{
  config,
  pkgs,
  lib,
  userConfig,
  brewCustom,
  ...
}: {
  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 6;

  # User configuration
  users.users.${userConfig.username} = {
    name = userConfig.username;
    home = "/Users/${userConfig.username}";
    shell = pkgs.zsh;
  };

  nix = {
    settings = {
      experimental-features = ["nix-command" "flakes"];
      trusted-users = ["root" userConfig.username];
    };

    # Garbage collection
    gc = {
      automatic = true;
      interval = {
        Weekday = 0;
        Hour = 2;
        Minute = 0;
      };
      options = "--delete-older-than 30d";
    };

    extraOptions = ''
      experimental-features = nix-command flakes
      keep-outputs = true
      keep-derivations = true
    '';
  };

  system.activationScripts.extraActivation.text = ''
    softwareupdate --install-rosetta --agree-to-license
  '';

  system.primaryUser = userConfig.username;

  # Disable the sound effect on boot
  system.startup.chime = false;

  system.defaults = {
    dock = {
      show-recents = true;
      tilesize = 36;
      minimize-to-application = true;
      mru-spaces = false;
      scroll-to-open = true;
      persistent-apps = [
        {
          app = "/Applications/Brave Browser.app";
        }
        {
          app = "/Applications/Google Chrome.app";
        }
        {
          app = "/Applications/Ghostty.app";
        }
        {
          app = "/Applications/IntelliJ IDEA.app";
        }
        {
          app = "/Applications/Cursor.app";
        }
        {
          app = "/Applications/Slack.app";
        }
        {
          app = "/System/Applications/Mail.app";
        }
        {
          app = "/Applications/Telegram.app";
        }
        {
          app = "/System/Applications/Calendar.app";
        }
        {
          app = "/System/Applications/Reminders.app";
        }
        {
          app = "/System/Applications/Notes.app";
        }
        {
          app = "/System/Applications/Music.app";
        }
      ];
    };

    finder = {
      FXEnableExtensionChangeWarning = false;
      FXPreferredViewStyle = "clmv"; # Column view
      FXRemoveOldTrashItems = true;
      QuitMenuItem = true;
      ShowPathbar = true;
      ShowStatusBar = true;
      _FXShowPosixPathInTitle = true;
    };

    LaunchServices = {
      # Disable the "Are you sure you want to open this application?" dialog
      LSQuarantine = false;
    };

    hitoolbox.AppleFnUsageType = "Change Input Source";

    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark";

      AppleShowAllExtensions = true;
      AppleShowAllFiles = true;

      InitialKeyRepeat = 15;
      KeyRepeat = 2;
      ApplePressAndHoldEnabled = false;

      AppleICUForce24HourTime = false;

      # Expand save panel by default
      NSNavPanelExpandedStateForSaveMode = true;
      NSNavPanelExpandedStateForSaveMode2 = true;

      # Expand print panel by default
      PMPrintingExpandedStateForPrint = true;
      PMPrintingExpandedStateForPrint2 = true;
    };

    trackpad = {
      Clicking = true;
      TrackpadThreeFingerDrag = false;
    };

    screencapture.location = "~/Desktop";

    controlcenter = {
      NowPlaying = true;
      Sound = true;
      BatteryShowPercentage = false;
    };

    SoftwareUpdate.AutomaticallyInstallMacOSUpdates = true;

    WindowManager.EnableTiledWindowMargins = false;

    CustomUserPreferences = {
      NSGlobalDomain = {
        AppleLanguages = ["en" "vi"];
        AppleLocale = "en_UK";
        AppleAccentColor = -1;
        AppleHighlightColor = "1.000000 0.733333 0.721569 Red";
        AppleICUForce12HourTime = true;
        AppleShowScrollBars = "WhenScrolling";
      };
      "com.apple.desktopservices" = {
        DSDontWriteNetworkStores = true;
        DSDontWriteUSBStores = true;
      };
    };
  };

  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToControl = true;
  };

  security.pam.services.sudo_local.touchIdAuth = true;

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "zap";
      upgrade = true;
    };

    taps = [
      "theseal/ssh-askpass"
      "pirj/noclamshell"
      "TheBoredTeam/boring-notch"
      "CodeOne45/tap"
    ] ++ brewCustom.taps;

    brews = [
      "chezmoi"
      "jump"
      "libyaml"
      "theseal/ssh-askpass/ssh-askpass"
      {
        name = "pirj/noclamshell/noclamshell";
        # start_service = true;
      }
      "docker-compose"
      "vex"
    ] ++ brewCustom.brews;

    casks = [
      "appcleaner"
      "brave-browser"
      "ghostty"
      "docker-desktop"
      "telegram"
      # "utm"
      "anytype"
      "ibkr"
      "portfolioperformance"
      "raycast"
      "intellij-idea"
      "cursor"
      "logi-options+"
      "boring-notch"
      "zed"
      "lunar"
      "slack"
      "numi"
      "notion"
    ] ++ brewCustom.casks;

    masApps = {
      # Mac App Store apps (use mas list to get IDs)
      "Bitwarden" = 1352778147;
      "Keynote" = 409183694;
      "LocalSend" = 1661733229;
      "Numbers" = 409203825;
      "Pages" = 409201541;
      "SnippetsLab" = 1006087419;
      # "uBlock Origin Lite" = 6745342698;
      "WhatsApp" = 310633997;
      "Yubico Authenticator" = 1497506650;
    } // brewCustom.masApps;
  };
}
