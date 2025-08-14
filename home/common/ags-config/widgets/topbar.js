import Widget from "resource:///com/github/Aylur/ags/widget.js";
import Hyprland from "resource:///com/github/Aylur/ags/service/hyprland.js";
import Audio from "resource:///com/github/Aylur/ags/service/audio.js";
import { Utils } from "resource:///com/github/Aylur/ags/utils.js";
const { execAsync, exec } = Utils;
import Gtk from "gi://Gtk?version=3.0";

// Memory widget
const Memory = () => Widget.Label({
    class_name: "memory",
    setup: self => self.poll(3000, self => {
        execAsync(['bash', '-c', `free -h | awk '/^Mem:/ {print " " $3 "/" $2}'`])
            .then(output => self.label = output.trim())
            .catch(err => self.label = " N/A");
    }),
});

// Active window title
const WindowTitle = () => Widget.Label({
    class_name: "window-title",
    label: "Desktop",
    setup: self => self.hook(Hyprland.active.client, self => {
        const client = Hyprland.active.client;
        if (client.class.length === 0) {
            self.label = "Desktop";
        } else {
            self.label = `${client.title}` || `${client.class}`;
        }
    }),
});

// Clock with calendar popup
const Clock = () => Widget.Button({
    class_name: "clock",
    child: Widget.Label({
        setup: self => self.poll(1000, self => {
            const date = new Date();
            self.label = `📅${date.toLocaleDateString('en-US', { 
                weekday: 'long', 
                year: 'numeric', 
                month: 'long', 
                day: 'numeric' 
            })}`;
        }),
    }),
    on_clicked: () => {
        execAsync(['bash', '-c', 'gnome-calendar || zenity --calendar || notify-send "Calendar" "$(date)"'])
            .catch(() => {});
    },
});

// Bluetooth indicator
const Bluetooth = () => Widget.Button({
    class_name: "bluetooth",
    child: Widget.Label({
        setup: self => self.poll(5000, self => {
            execAsync(['bash', '-c', 'bluetoothctl show | grep "Powered: yes" > /dev/null && echo "󰂯" || echo "󰂲"'])
                .then(output => self.label = output.trim())
                .catch(() => self.label = "󰂲");
        }),
    }),
    on_clicked: () => execAsync(['env', 'GDK_BACKEND=x11', 'blueman-manager']).catch(() => {}),
});

// Network indicator
const NetworkIndicator = () => Widget.Button({
    class_name: "network",
    child: Widget.Label({
        setup: self => self.poll(5000, self => {
            execAsync(['bash', '-c', `nmcli -t -f ACTIVE,SSID dev wifi | awk -F: '$1=="yes" {print "  " $2 " (" substr($0, index($0, ")")) ")"}'`])
                .then(output => {
                    if (output.trim()) {
                        self.label = output.trim();
                    } else {
                        // Check for ethernet
                        execAsync(['bash', '-c', `ip route | grep default | grep -o 'dev [^ ]*' | cut -d' ' -f2 | head -1`])
                            .then(iface => {
                                if (iface.trim()) {
                                    execAsync(['bash', '-c', `ip addr show ${iface.trim()} | grep 'inet ' | awk '{print $2}' | cut -d'/' -f1`])
                                        .then(ip => self.label = `󰈀 ${ip.trim()}`)
                                        .catch(() => self.label = "󰈀 Connected");
                                } else {
                                    self.label = "⚠️ No network";
                                }
                            })
                            .catch(() => self.label = "⚠️ No network");
                    }
                })
                .catch(() => self.label = "⚠️ No network");
        }),
    }),
    on_clicked: () => execAsync(['alacritty', '-e', 'nmtui']).catch(() => {}),
});

// Audio/Volume control
const Volume = () => Widget.Button({
    class_name: "volume",
    child: Widget.Label({
        setup: self => self.hook(Audio, self => {
            if (!Audio.speaker) return;
            
            const vol = Math.round(Audio.speaker.volume * 100);
            const isMuted = Audio.speaker.stream?.is_muted ?? false;
            
            if (isMuted) {
                self.label = ` ${vol}%`;
            } else {
                const icon = vol > 66 ? "" : vol > 33 ? "" : "";
                self.label = `${icon} ${vol}%`;
            }
        }),
    }),
    on_clicked: () => execAsync(['pavucontrol']).catch(() => {}),
    on_scroll_up: () => Audio.speaker.volume += 0.05,
    on_scroll_down: () => Audio.speaker.volume -= 0.05,
});

// Battery indicator (if available)
const BatteryIndicator = () => Widget.Button({
    class_name: "battery",
    child: Widget.Label({
        setup: self => self.poll(30000, self => {
            execAsync(['bash', '-c', 'upower -i /org/freedesktop/UPower/devices/battery_BAT0 2>/dev/null | grep percentage | awk \'{print $2}\''])
                .then(output => {
                    if (output.trim()) {
                        const percent = parseInt(output);
                        const icons = ["", "", "", "", ""];
                        const icon = icons[Math.floor(percent / 20)];
                        self.label = `${icon} ${percent}%`;
                    } else {
                        self.label = "";
                    }
                })
                .catch(() => self.label = "");
        }),
    }),
    on_clicked: () => {
        execAsync(['bash', '-c', 'upower -i /org/freedesktop/UPower/devices/battery_BAT0 | rofi -dmenu -p "🔋 Battery Info"'])
            .catch(() => {});
    },
});

// Keyboard layout indicator
const KeyboardLayout = () => Widget.Button({
    class_name: "keyboard-layout",
    child: Widget.Label({
        setup: self => self.poll(1000, self => {
            execAsync(['bash', '-c', 'hyprctl devices | grep "active keymap:" | head -1 | sed "s/.*active keymap: //"'])
                .then(layout => {
                    const flag = layout.trim() === "English (US)" ? "🇺🇸" : "🇬🇷";
                    self.label = flag;
                })
                .catch(() => self.label = "🇺🇸");
        }),
    }),
    on_clicked: () => execAsync(['hyprctl', 'switchxkblayout', 'current', 'next']).catch(() => {}),
});

// Notifications indicator
const Notifications = () => Widget.Button({
    class_name: "notifications",
    child: Widget.Label({
        setup: self => self.poll(2000, self => {
            execAsync(['swaync-client', '--count'])
                .then(count => {
                    const num = parseInt(count);
                    self.label = `🔔 ${num > 0 ? num : ''}`;
                })
                .catch(() => self.label = "🔔");
        }),
    }),
    on_clicked: () => execAsync(['swaync-client', '-t']).catch(() => {}),
});

// Main top bar
export const TopBar = () => Widget.Window({
    name: "topbar",
    anchor: ["top", "left", "right"],
    exclusivity: "exclusive",
    child: Widget.CenterBox({
        class_name: "topbar",
        start_widget: Widget.Box({
            class_name: "left-section",
            children: [Memory()],
        }),
        center_widget: Widget.Box({
            class_name: "center-section",
            children: [WindowTitle()],
        }),
        end_widget: Widget.Box({
            class_name: "right-section",
            children: [
                Clock(),
                Bluetooth(),
                NetworkIndicator(),
                Volume(),
                BatteryIndicator(),
                KeyboardLayout(),
                Notifications(),
            ],
        }),
    }),
});