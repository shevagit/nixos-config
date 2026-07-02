-- Hyprland Lua config (ACTIVE). Ported from the former hyprland.nix `settings`
-- block. Home Manager injects this file verbatim into ~/.config/hypr/hyprland.lua
-- via `wayland.windowManager.hyprland.extraConfig` (configType = "lua"), so it is
-- the live Hyprland config as of the next login.
--
-- Note: the lua-vs-conf backend is chosen ONCE at Hyprland startup — `hyprctl
-- reload` re-runs this file but cannot switch backends. After the rebuild that
-- flipped configType to "lua", log out and back in for it to take effect.
-- To roll back to the old hyprlang config: `git revert` the switch commit + rebuild.
--
-- API reference: https://wiki.hypr.land/Configuring/Start/
-- and example:    https://github.com/hyprwm/Hyprland/blob/main/example/hyprland.lua
--
-- Verified 2026-07-02 against Hyprland 0.55.4 (src/config/lua/bindings/
-- LuaBindingsDispatchers.cpp) in a nested instance: all 54 binds registered
-- with no lua/config errors. The previously-uncertain dispatchers are correct:
--     • hl.dsp.window.fullscreen()            → toggle fullscreen (no-arg default)
--     • hl.dsp.window.move({ direction=... })  → dsp_moveInDirection
--     • hl.dsp.window.move({ monitor="+1" })   → dsp_moveToMonitor
--     • hl.dsp.focus({ workspace="m+1"/"m-1" }) → workspace selector (relative-on-monitor)

local mod = "SUPER"
local home = os.getenv("HOME")

------------------
---- MONITORS ----
------------------
hl.monitor({ output = "DP-1", mode = "2560x1440@164",   position = "0x0",    scale = 1 })
hl.monitor({ output = "DP-3", mode = "2560x1440@99.95", position = "2560x0", scale = 1 })

-------------------
---- AUTOSTART ----
-------------------
hl.on("hyprland.start", function()
  hl.exec_cmd("~/.config/hyprland/scripts/bares-wrapper.sh")
  hl.exec_cmd("wl-paste --type text --watch cliphist store")  -- clipboard history (DMS)
  hl.exec_cmd("wl-paste --type image --watch cliphist store") -- image clipboard history
end)

-----------------------
---- LOOK AND FEEL ----
-----------------------
hl.config({
  general = {
    layout   = "master",
    gaps_in  = 10,
    gaps_out = 20,
  },

  master = {
    new_status = "slave",
    mfact      = 0.55,
  },

  decoration = {
    rounding     = 10,
    dim_inactive = true,
    dim_strength = 0.2,
    blur = {
      size     = 3,
      passes   = 2,
      vibrancy = 0.1696,
    },
    shadow = {
      range        = 4,
      render_power = 3,
    },
  },

  input = {
    kb_layout  = "us,gr",
    kb_options = "grp:win_space_toggle",
  },
})

---------------------
---- KEYBINDINGS ----
---------------------

-- Actions
hl.bind(mod .. " + Return", hl.dsp.exec_cmd("kitty"))
hl.bind(mod .. " + d",      hl.dsp.exec_cmd("rofi -show drun -config ~/.config/rofi/launcher.rasi"))
hl.bind(mod .. " + p",      hl.dsp.exec_cmd("dms ipc call powermenu toggle"))
hl.bind(mod .. " + l",      hl.dsp.exec_cmd(home .. "/.config/hyprland/scripts/dms-restart.sh"))
hl.bind(mod .. " + SHIFT + e", hl.dsp.exec_cmd("hyprctl dispatch exit 0")) -- logout; to be removed
hl.bind(mod .. " + q",      hl.dsp.window.close())
hl.bind("CONTROL + Space",  hl.dsp.window.float({ action = "toggle" }))
hl.bind(mod .. " + F",      hl.dsp.window.fullscreen())
hl.bind(mod .. " + w",      hl.dsp.exec_cmd("dms ipc call wallpaper next"))

-- Move to the next empty workspace
hl.bind(mod .. " + SHIFT + grave", hl.dsp.exec_cmd("~/.config/hyprland/scripts/move-to-next-empty.sh"))

-- Move focus
hl.bind(mod .. " + H", hl.dsp.focus({ direction = "left" }))
hl.bind(mod .. " + L", hl.dsp.focus({ direction = "right" }))
hl.bind(mod .. " + K", hl.dsp.focus({ direction = "up" }))
hl.bind(mod .. " + J", hl.dsp.focus({ direction = "down" }))

-- Move window
hl.bind(mod .. " + SHIFT + H",     hl.dsp.window.move({ direction = "left" }))
hl.bind(mod .. " + SHIFT + L",     hl.dsp.window.move({ direction = "right" }))
hl.bind(mod .. " + SHIFT + K",     hl.dsp.window.move({ direction = "up" }))
hl.bind(mod .. " + SHIFT + J",     hl.dsp.window.move({ direction = "down" }))
hl.bind(mod .. " + SHIFT + left",  hl.dsp.window.move({ direction = "left" }))
hl.bind(mod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
hl.bind(mod .. " + SHIFT + up",    hl.dsp.window.move({ direction = "up" }))
hl.bind(mod .. " + SHIFT + down",  hl.dsp.window.move({ direction = "down" }))

-- Move window to next monitor
hl.bind(mod .. " + SHIFT + TAB", hl.dsp.window.move({ monitor = "+1" }))

-- Switch / move-to workspaces with mod (+SHIFT) + [0-9]
for i = 1, 10 do
  local key = i % 10 -- 10 maps to key "0"
  hl.bind(mod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
  hl.bind(mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Workspace navigation on the current monitor
hl.bind("CONTROL + ALT + right", hl.dsp.focus({ workspace = "m+1" }))
hl.bind("CONTROL + ALT + left",  hl.dsp.focus({ workspace = "m-1" }))
hl.bind(mod .. " + mouse_up",    hl.dsp.focus({ workspace = "m+1" }))
hl.bind(mod .. " + mouse_down",  hl.dsp.focus({ workspace = "m-1" }))

-- Lock
hl.bind("CONTROL + ALT + L", hl.dsp.exec_cmd("swaylock"))

-- Screenshot
hl.bind(mod .. " + Print", hl.dsp.exec_cmd("grimblast save area /tmp/screenshot.png && swappy -f /tmp/screenshot.png"))

-- Volume (locked = active while screen locked, repeating = key-repeat)
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("pactl set-sink-volume @DEFAULT_SINK@ +5%"),     { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("pactl set-sink-volume @DEFAULT_SINK@ -5%"),     { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("pactl set-sink-mute @DEFAULT_SINK@ toggle"),    { locked = true })

-- Mouse drag move / resize
hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })
