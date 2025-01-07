{
  config,
  inputs,
  pkgs,
  lib,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    inputs.home-manager.nixosModules.default
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  #Enable the flakes
  nix.settings.experimental-features = ["nix-command" "flakes"];

  networking.hostName = "trollos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Vienna";

  # Select internationalisation properties.
  i18n.defaultLocale = "de_AT.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_AT.UTF-8";
    LC_IDENTIFICATION = "de_AT.UTF-8";
    LC_MEASUREMENT = "de_AT.UTF-8";
    LC_MONETARY = "de_AT.UTF-8";
    LC_NAME = "de_AT.UTF-8";
    LC_NUMERIC = "de_AT.UTF-8";
    LC_PAPER = "de_AT.UTF-8";
    LC_TELEPHONE = "de_AT.UTF-8";
    LC_TIME = "de_AT.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "at";
    variant = "nodeadkeys";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
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

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.sha3de = {
    isNormalUser = true;
    description = "sha3de";
    extraGroups = ["networkmanager" "wheel" "docker"];
    packages = with pkgs; [
      #  thunderbird
    ];
  };

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };

  hardware = {
    graphics.enable = true;
  };

  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages."${pkgs.system}".hyprland;
    xwayland.enable = true;
  };

  #Home manager configuration
  home-manager = {
    extraSpecialArgs = {inherit inputs;};
    backupFileExtension = "backup";
    users = {
      "sha3de" = import ./home.nix;
    };
  };

  fonts.fontDir.enable = true;
  fonts.fontconfig.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  #Startup Script
  systemd.user.services.startup = {
    description = "...";
    serviceConfig.PassEnvironment = "DISPLAY";
    script = ''
      rclone --vfs-cache-mode writes mount onedrive: ~/onedrive/
    '';
    wantedBy = ["multi-user.target"];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    #Random shit
    ripgrep
    wl-clipboard-rs

    pavucontrol
    avizo
    btop
    brightnessctl
    alsa-utils
    swaynotificationcenter
    git
    pkgs.postman
    grim
    slurp
    rclone
    onlyoffice-bin

    brave
    vesktop

    #Language
    nodejs

    #Terminal
    kitty
    fish
    tmux

    #Editors
    neovim
    vscode
    jetbrains-toolbox
    android-studio
    jetbrains.idea-ultimate
    jetbrains.datagrip

    # Hyprland
    sway
    waybar
    dunst
    hyprlock
    hyprpaper
    waybar
    xdg-desktop-portal-hyprland
    xdg-desktop-portal
    swaynotificationcenter

    # File Managers
    rofi-wayland
    nautilus

    #Drivers
    libGL
    libvdpau
    libxkbcommon
    xorg.libxcb
    xorg.xcbutil
    xorg.libX11
    vulkan-loader
    mesa
    qemu
    usbutils

    #Fonts
    pkgs.nerdfonts
  ];

  # fonts.packages = with pkgs; [
  #   nerdfonts.hack
  # ];
  #Install Docker
  systemd.timers."onedrive-backup" = {
    wantedBy = ["timers.target"];
    timerConfig = {
      OnBootSec = "10m";
      OnUnitActiveSec = "10m";
      Unit = "onedrive-backup.service";
    };
  };
  systemd.services."onedrive-backup" = {
    script = ''
      ${pkgs.rclone}/bin/rclone sync /home/sha3de/onedrive/ onedrive:nixos \
        --log-file /home/sha3de/sync.txt \
        -P \
        --log-level info \
        --exclude '.git' \
        --exclude 'node_modules'
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "sha3de";
    };
  };

  virtualisation.docker.enable = true;

  virtualisation.docker.daemon.settings = {
    data-root = "~/dev/docker";
  };

  environment.variables.EDITOR = "nano";

  services.greetd = {
    enable = true;
    vt = 1;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember --cmd Hyprland";
        user = "greeter";
      };
    };
  };
  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}
