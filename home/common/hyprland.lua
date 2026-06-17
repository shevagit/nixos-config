-- Hyprland Lua config — DRAFT / work-in-progress port of hyprland.nix `settings`.
--
-- This file is shipped by Home Manager to ~/.config/hypr/hyprland-draft.lua and
-- is NOT loaded by Hyprland (it only auto-loads a file named exactly
-- `hyprland.lua`). The hyprlang `hyprland.conf` remains the active config.
--
-- To trial this live (from a TTY or terminal):
--     ln -sf hyprland-draft.lua ~/.config/hypr/hyprland.lua
--     hyprctl reload   # or log out / back in
-- To roll back:
--     rm ~/.config/hypr/hyprland.lua    # hyprland.conf takes over again
--
-- API reference: https://wiki.hypr.land/Configuring/Start/
-- and example:    https://github.com/hyprwm/Hyprland/blob/main/example/hyprland.lua
--
-- ⚠ DISPATCHERS TO VERIFY in a live session — these `hl.dsp.*` forms are inferred
--   from the example (which doesn't cover them) and may need tweaking:
--     • hl.dsp.window.fullscreen()           (was `fullscreen,`)
--     • hl.dsp.window.move({ direction=... }) (was `movewindow, l/r/u/d`)
--     • hl.dsp.window.move({ monitor="+1" })  (was `movewindow, mon:+1`)
--     • hl.dsp.focus({ workspace="m+1"/"m-1" })(was `workspace, m+1/m-1`)

local mod = "SUPER"
local home = os.getenv("HOME")

------------------
---- MONITORS ----
------------------
hl.monitor({ output = "DP-1", mode = "2560x1440@164",   position = "0x0",    scale = 1 })
hl.monitor({ output = "DP-4", mode = "2560x1440@99.95", position = "2560x0", scale = 1 })

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
hl.bind(mod .. " + F",      hl.dsp.window.fullscreen())          -- ⚠ verify
hl.bind(mod .. " + w",      hl.dsp.exec_cmd("dms ipc call wallpaper next"))

-- Move to the next empty workspace
hl.bind(mod .. " + SHIFT + grave", hl.dsp.exec_cmd("~/.config/hyprland/scripts/move-to-next-empty.sh"))

-- Move focus
hl.bind(mod .. " + H", hl.dsp.focus({ direction = "left" }))
hl.bind(mod .. " + L", hl.dsp.focus({ direction = "right" }))
hl.bind(mod .. " + K", hl.dsp.focus({ direction = "up" }))
hl.bind(mod .. " + J", hl.dsp.focus({ direction = "down" }))

-- Move window  (⚠ verify direction form)
hl.bind(mod .. " + SHIFT + H",     hl.dsp.window.move({ direction = "left" }))
hl.bind(mod .. " + SHIFT + L",     hl.dsp.window.move({ direction = "right" }))
hl.bind(mod .. " + SHIFT + K",     hl.dsp.window.move({ direction = "up" }))
hl.bind(mod .. " + SHIFT + J",     hl.dsp.window.move({ direction = "down" }))
hl.bind(mod .. " + SHIFT + left",  hl.dsp.window.move({ direction = "left" }))
hl.bind(mod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
hl.bind(mod .. " + SHIFT + up",    hl.dsp.window.move({ direction = "up" }))
hl.bind(mod .. " + SHIFT + down",  hl.dsp.window.move({ direction = "down" }))

-- Move window to next monitor  (⚠ verify monitor form)
hl.bind(mod .. " + SHIFT + TAB", hl.dsp.window.move({ monitor = "+1" }))

-- Switch / move-to workspaces with mod (+SHIFT) + [0-9]
for i = 1, 10 do
  local key = i % 10 -- 10 maps to key "0"
  hl.bind(mod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
  hl.bind(mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Workspace navigation on the current monitor  (⚠ verify m+/m- form)
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
