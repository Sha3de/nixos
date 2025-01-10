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

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  boot.initrd.kernelModules = ["amdgpu"];

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

  #Enable Java
  programs.java = {
    enable = true;
  };

  #Enable firefox
  #programs.firefox.enable = true;

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
    teams-for-linux
    clinfo

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
    hyprcursor
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
    radeontop
    stress-ng

    #Games
    minecraft

    #Fonts
    pkgs.nerdfonts
  ];
  #HIP
  systemd.tmpfiles.rules = let
    rocmEnv = pkgs.symlinkJoin {
      name = "rocm-combined";
      paths = with pkgs.rocmPackages; [
        rocblas
        hipblas
        clr
      ];
    };
  in [
    "L+    /opt/rocm   -    -    -     -    ${rocmEnv}"
  ];

  #OPENCL
  hardware.graphics.extraPackages = with pkgs; [rocmPackages.clr.icd];
  environment.variables = {
    ROC_ENABLE_PRE_VEGA = "1";
  };

  #OneDrive Backup
  systemd.timers."onedrive-backup" = {
    wantedBy = ["timers.target"];
    timerConfig = {
      OnBootSec = "10m";
      OnUnitActiveSec = "10m";
      Unit = "onedrive-backup.service";
    };
  };
  systemd.services."onedrive-backup" = {
    # Ensure the service starts after the network is up
    wantedBy = ["multi-user.target"];
    after = ["network-online.target"];
    requires = ["network-online.target"];

    # Service configuration
    serviceConfig = {
      Type = "simple";
      ExecStartPre = [
        "/run/current-system/sw/bin/mkdir -p home/sha3de/onedrive"
        "${pkgs.rclone}/bin/rclone sync /home/sha3de/onedrive/ onedrive:nixos \ --log-file /home/sha3de/sync.txt \ -P \ --log-level info \ --exclude '.git' \ --exclude 'node_modules ' "
      ];
      ExecStart = "${pkgs.rclone}/bin/rclone mount onedrive: home/sha3de/onedrive/";
      ExecStop = "/run/current-system/sw/bin/fusermount -u home/sha3de/onedrive/";
      Restart = "on-failure";
      RestartSec = "10s";
      User = "sha3de";
      Group = "users";
      Environment = ["PATH=/run/wrappers/bin/:$PATH"]; # Required environments
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
