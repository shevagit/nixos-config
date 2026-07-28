{ config, pkgs, lib, ... }: {
  imports = [
    ../../home
    ../../home/common
  ];
  # Host-specific Hyprland overrides. The shared config uses configType = "lua"
  # (see home/common/hyprland.nix), so these MUST be Lua injected via extraConfig,
  # NOT `settings.*`. Under the lua backend the module serializes `settings` into
  # hl.*() calls, and keys like `bindl` render as `hl.bindl(...)` — a nil value
  # that throws a fatal Lua error and aborts the ENTIRE config (broken resolution,
  # dead keybinds, error banner). mkAfter appends this after the shared hyprland.lua.
  wayland.windowManager.hyprland.extraConfig = lib.mkAfter ''

    ---- host: athanasiou (laptop) ----

    -- Brightness (F5/F6)
    hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"))
    hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl set +5%"))

    -- 3-finger horizontal swipe switches workspaces
    hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

    -- Lock on lid close via DMS (locked = fires even while screen is locked)
    hl.bind("switch:on:Lid Switch", hl.dsp.exec_cmd("dms ipc call lock lock"), { locked = true })

    -- Monitors: office monitor on top, embedded panel below, catch-all fallback
    hl.monitor({ output = "DP-1",  mode = "2560x1440@60", position = "0x0",    scale = 1 })
    hl.monitor({ output = "eDP-1", mode = "1920x1080@60", position = "0x1440", scale = 1 })
    hl.monitor({ output = "",      mode = "preferred",    position = "auto",   scale = "auto" })
  '';
  
  # host-specific packages
  home.packages = with pkgs; [
    libnotify # add notify-send for battery notifications
  ];

}
