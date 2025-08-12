{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    wlogout
  ];

  programs.wlogout = {
    enable = true;
    package = pkgs.wlogout;

    layout = [
      { label = "lock";     text = "Lock";     action = "${pkgs.hyprlock}/bin/hyprlock";                        keybind = "l"; }
      { label = "logout";   text = "Logout";   action = "${pkgs.hyprland}/bin/hyprctl dispatch exit 0";         keybind = "o"; }
      { label = "reboot";   text = "Restart";  action = "${pkgs.systemd}/bin/systemctl reboot";                 keybind = "r"; }
      { label = "shutdown"; text = "Shutdown"; action = "${pkgs.systemd}/bin/systemctl poweroff";              keybind = "s"; }
    ];

    # Modern, glassy style
    style = ''
      /* Dim backdrop (enable Hyprland blur for 'wlogout' layer; see note below) */
      window {
        background-color: rgba(0,0,0,0.35);
      }

      /* Base card */
      button {
        background-image: linear-gradient(180deg, rgba(41,45,62,0.92), rgba(20,22,30,0.92));
        color: #ECEFF4;
        border: 1px solid rgba(255,255,255,0.10);
        border-radius: 20px;
        padding: 22px 24px;
        margin: 14px;
        min-width: 240px;
        min-height: 120px;
        box-shadow:
          0 6px 24px rgba(0,0,0,0.35),
          inset 0 1px 0 rgba(255,255,255,0.06);
        transition: transform .12s ease, box-shadow .2s ease, border-color .2s ease, background .2s ease;
      }

      /* Hover/Focus lift */
      button:hover, button:focus {
        transform: translateY(-2px);
        box-shadow:
          0 14px 34px rgba(0,0,0,0.45),
          inset 0 1px 0 rgba(255,255,255,0.08);
        border-color: rgba(255,255,255,0.20);
      }

      /* Kill the default giant icon; go text-forward */
      button image {
        -gtk-icon-transform: scale(0);
        opacity: 0;
        margin: 0;
        padding: 0;
        min-width: 0;
        min-height: 0;
      }

      /* Title */
      button label#text {
        font-weight: 700;
        font-size: 20px;
        letter-spacing: 0.3px;
        margin-top: 0;
        margin-bottom: 4px;
      }

      /* Key hint */
      button label#keybind {
        font-size: 12px;
        opacity: 0.70;
        margin-top: 2px;
      }

      /* Per-button accents (subtle colored edge + glow on hover) */
      #lock {
        border-color: rgba(96,165,250,0.35);
        box-shadow: 0 6px 24px rgba(0,0,0,0.35), 0 0 0 0 rgba(59,130,246,0);
      }
      #lock:hover, #lock:focus {
        box-shadow:
          0 14px 34px rgba(0,0,0,0.45),
          0 0 20px 4px rgba(59,130,246,0.18);
      }

      #logout {
        border-color: rgba(147,197,253,0.35);
      }
      #logout:hover, #logout:focus {
        box-shadow:
          0 14px 34px rgba(0,0,0,0.45),
          0 0 20px 4px rgba(147,197,253,0.18);
      }

      #reboot {
        border-color: rgba(52,211,153,0.35);
      }
      #reboot:hover, #reboot:focus {
        box-shadow:
          0 14px 34px rgba(0,0,0,0.45),
          0 0 20px 4px rgba(52,211,153,0.18);
      }

      #shutdown {
        border-color: rgba(248,113,113,0.45);
      }
      #shutdown:hover, #shutdown:focus {
        box-shadow:
          0 14px 34px rgba(0,0,0,0.45),
          0 0 20px 4px rgba(248,113,113,0.20);
      }
    '';
  };

  # Toggle wrapper (SUPER+P again closes)
  home.file.".config/wlogout/scripts/power-menu".text = ''
    #!/usr/bin/env bash
    set -euo pipefail

    if pgrep -x wlogout >/dev/null; then
      pkill -x wlogout
      exit 0
    fi

    exec ${pkgs.wlogout}/bin/wlogout \
      -b 2 \               # 2 buttons per row (2x2 grid feels balanced)
      -T 180 \             # top margin
      -B 180 \             # bottom margin
      --layout "$HOME/.config/wlogout/layout" \
      --css "$HOME/.config/wlogout/style.css"
  '';
  home.file.".config/wlogout/scripts/power-menu".executable = true;

}
