{lib, ...}: {
  imports = [
    # ./hyprland-environment.nix
    ./hyprpaper.nix
    #./hypridle.nix
    ./hyprlock.nix
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    systemdIntegration = true;
    settings = {
      monitor = ["eDP-2,1920x1200@165.01500,0x0,1"];

      # ENVIRONMENT VARIABLES
      env = [
        "HYPRCURSOR_THEME,Bibata-Modern-Ice"
        "HYPRCURSOR_SIZE,24"
      ];

      # INPUT
      input = {
        follow_mouse = 1;
        sensitivity = 0;
        kb_layout = "de";
        touchpad = {
          natural_scroll = true;
        };
      };

      # LOOK AND FEEL
      general = {
        gaps_in = 2;
        gaps_out = 2;
        border_size = 2;
        "col.active_border" = "0xaae2e2e3";
        "col.inactive_border" = "0xaa414550";
        resize_on_border = false;
        allow_tearing = false;
        layout = "dwindle";
      };

      decoration = {
        rounding = 10;
        active_opacity = 1.0;
        inactive_opacity = 1.0;
        # drop_shadow = true;
        # shadow_range = 4;
        # shadow_render_power = 3;
        # "col.shadow" = "rgba(1a1a1aee)";
        blur = {
          enabled = true;
          size = 3;
          passes = 1;
          vibrancy = 0.1696;
        };
      };

      animations = {
        enabled = true;
        bezier = [
          "myBezier, 0.05, 0.9, 0.1, 1.05"
        ];
        animation = [
          "windows, 1, 7, myBezier"
          "windowsOut, 1, 7, default, popin 80%"
          "border, 1, 10, default"
          "borderangle, 1, 8, default"
          "fade, 1, 7, default"
          "workspaces, 1, 6, default"
        ];
      };

      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      misc = {
        force_default_wallpaper = -1;
        disable_hyprland_logo = false;
      };

      gestures = {
        workspace_swipe = true;
      };

      # AUTOSTART
      exec-once = [
        "systemctl --user start hyprland-session.target"
        "waybar &"
        "hyprpaper &"
        "hypridle &"
        "brave &"
        "kitty fish &"
        "vesktop"
      ];

      # Keybindings
      "$mainMod" = "SUPER";

      bind = [
        # Launch Applications
        "$mainMod, R, exec,  rofi -show drun -show-icons"
        "$mainMod SHIFT, N, exec, swaync-client -rs"
        "$mainMod SHIFT, C, exec, exit"
        "$mainMod, Q, exec, kitty fish"
        "$mainMod, C, killactive"

        # Window Management
        "$mainMod, P, pseudo"
        "$mainMod SHIFT, I, togglesplit"
        "$mainMod, M, fullscreen, 1"
        "$mainMod SHIFT, M, fullscreen, 0"

        # Move Focus
        "$mainMod, Left, movefocus, l"
        "$mainMod, Right, movefocus, r"
        "$mainMod, Up, movefocus, u"
        "$mainMod, Down, movefocus, d"

        # Move Windows
        "$mainMod SHIFT, Left, movewindow, l"
        "$mainMod SHIFT, Right, movewindow, r"
        "$mainMod SHIFT, Up, movewindow, u"
        "$mainMod SHIFT, Down, movewindow, d"
        "$mainMod SHIFT, H, movewindow, l"
        "$mainMod SHIFT, L, movewindow, r"
        "$mainMod SHIFT, K, movewindow, u"
        "$mainMod SHIFT, J, movewindow, d"

        # Workspaces
        "$mainMod, 1, workspace, 1"
        "$mainMod, 2, workspace, 2"
        "$mainMod, 3, workspace, 3"
        "$mainMod, 4, workspace, 4"
        "$mainMod, 5, workspace, 5"
        "$mainMod, 6, workspace, 6"
        "$mainMod, 7, workspace, 7"
        "$mainMod, 8, workspace, 8"
        "$mainMod, 9, workspace, 9"
        "$mainMod, 0, workspace, 10"

        "$mainMod SHIFT, 1, movetoworkspace, 1"
        "$mainMod SHIFT, 2, movetoworkspace, 2"
        "$mainMod SHIFT, 3, movetoworkspace, 3"
        "$mainMod SHIFT, 4, movetoworkspace, 4"
        "$mainMod SHIFT, 5, movetoworkspace, 5"
        "$mainMod SHIFT, 6, movetoworkspace, 6"
        "$mainMod SHIFT, 7, movetoworkspace, 7"
        "$mainMod SHIFT, 8, movetoworkspace, 8"
        "$mainMod SHIFT, 9, movetoworkspace, 9"
        "$mainMod SHIFT, 0, movetoworkspace, 10"

        # Workspace Navigation with Mouse
        "$mainMod, mouse_down, workspace, e+1"
        "$mainMod, mouse_up, workspace, e-1"

        # Other
        "$mainMod, ENTER, togglespecialworkspace"
        "$mainMod SHIFT, ENTER, movetoworkspace,special"

        "$mainMod SHIFT, Print, exec, grim -g \"$(slurp)\" ~/Pictures/screenshot-$(date +%s).png"
        "$mainMod, L, exec, hyprlock"
      ];

      bindm = [
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
      ];

      windowrulev2 = [
        "suppressevent maximize, class:.*"
        "workspace 1, class:Brave-browser"
        "workspace 2, class:kitty"
      ];

      windowrule = [
        "float,class:.waypaper-wrapped"
        "move, 2, class:Brave-browser"
        "move, 1, class:kitty"
        "move, 4, class:vesktop"
      ];
    };

    extraConfig = ''

      # additional non-Nix-configurable settings
    '';
  };
}
