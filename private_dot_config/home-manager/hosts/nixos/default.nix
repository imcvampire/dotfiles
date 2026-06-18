{
  config,
  pkgs,
  lib,
  userConfig,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
  ];

  system.stateVersion = "24.11";
  system.autoUpgrade = {
    enable = true;
    flake = "path:/home/${userConfig.username}/.config/home-manager#${userConfig.hostname}";
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_GB.UTF-8";
    LC_IDENTIFICATION = "en_GB.UTF-8";
    LC_MEASUREMENT = "en_GB.UTF-8";
    LC_MONETARY = "en_GB.UTF-8";
    LC_NAME = "en_GB.UTF-8";
    LC_NUMERIC = "en_GB.UTF-8";
    LC_PAPER = "en_GB.UTF-8";
    LC_TELEPHONE = "en_GB.UTF-8";
    LC_TIME = "en_GB.UTF-8";
  };

  networking.hostName = userConfig.hostname;
  networking.networkmanager.enable = true;
  hardware.bluetooth.enable = true;

  # Windows stores RTC in local time by default; this prevents clock drift in dual boot.
  time.hardwareClockInLocalTime = true;
  i18n.defaultLocale = "en_GB.UTF-8";

  users.users.${userConfig.username} = {
    isNormalUser = true;
    extraGroups = ["networkmanager" "wheel" "docker"];
    shell = pkgs.zsh;
    ignoreShellProgramCheck = true;
  };

  nix = {
    settings = {
      experimental-features = ["nix-command" "flakes"];
      trusted-users = ["root" userConfig.username];
      extra-substituters = ["https://noctalia.cachix.org"];
      extra-trusted-public-keys = ["noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="];
    };

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  programs.niri.enable = true;
  programs.xwayland.enable = true;
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      # Add missing dynamic libraries for unpackaged programs here, not in
      # environment.systemPackages.
    ];
  };

  services.greetd = {
    enable = true;
    useTextGreeter = true;
    settings.default_session.command = "${lib.getExe pkgs.tuigreet} --time --remember --cmd ${lib.getExe' config.programs.niri.package "niri-session"}";
  };

  services.printing.enable = false;

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  services.automatic-timezoned.enable = true;
  services.power-profiles-daemon.enable = true;
  services.upower.enable = true;
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = "suspend";
    HandleLidSwitchDocked = "suspend";
    HandlePowerKey = "suspend";
  };
  services.fprintd.enable = true;

  systemd.services.lock-sessions-before-sleep = {
    description = "Lock graphical sessions before sleep";
    wantedBy = ["sleep.target"];
    before = ["sleep.target"];
    unitConfig.DefaultDependencies = false;
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${lib.getExe' pkgs.systemd "loginctl"} lock-sessions";
      ExecStartPost = "${lib.getExe' pkgs.coreutils "sleep"} 1";
    };
  };

  programs.firefox.enable = true;

  nixpkgs.config = {
    allowUnfree = true;

    permittedInsecurePackages = [
      "electron-39.8.10"
    ];
  };

  virtualisation.docker.enable = true;
}
