import Widget from "resource:///com/github/Aylur/ags/widget.js";
import Hyprland from "resource:///com/github/Aylur/ags/service/hyprland.js";
import { Utils } from "resource:///com/github/Aylur/ags/utils.js";
const { execAsync, exec } = Utils;
import Gtk from "gi://Gtk?version=3.0";

// Workspaces widget with window indicators
const Workspaces = () => Widget.Box({
    class_name: "workspaces",
    setup: self => self.hook(Hyprland, self => {
        self.children = Hyprland.workspaces
            .sort((a, b) => a.id - b.id)
            .map(ws => Widget.Button({
                class_name: `workspace ${ws.id === Hyprland.active.workspace.id ? 'active' : ''}`,
                child: Widget.Label({
                    label: `${ws.id}`,
                    setup: label => label.hook(Hyprland, label => {
                        // Get windows on this workspace and show icons
                        const clients = Hyprland.clients.filter(c => c.workspace.id === ws.id);
                        const icons = clients.map(client => {
                            const className = client.class.toLowerCase();
                            // Map applications to icons
                            const iconMap = {
                                'firefox': '',
                                'google-chrome': '',
                                'code': '',
                                'discord': '',
                                'spotify': '',
                                'steam': '',
                                'telegram': '',
                                'slack': '',
                                'foot': '',
                                'terminator': '',
                                'alacritty': '',
                                'signal': '',
                                'element': '',
                                'compass': '',
                            };
                            return iconMap[className] || '';
                        }).filter(icon => icon !== '').join(' ');
                        
                        label.label = icons ? `${ws.id} ${icons}` : `${ws.id}`;
                    }),
                }),
                on_clicked: () => Hyprland.messageAsync(`dispatch workspace ${ws.id}`),
            }));
    }),
});

// Clock widget for left bar
const LeftClock = () => Widget.Button({
    class_name: "left-clock",
    child: Widget.Label({
        setup: self => self.poll(60000, self => {
            const date = new Date();
            self.label = `⏰ ${date.toLocaleTimeString('en-US', { 
                hour: '2-digit', 
                minute: '2-digit',
                hour12: false
            })}`;
        }),
    }),
});

// Weather widget
const Weather = () => Widget.Button({
    class_name: "weather",
    child: Widget.Label({
        setup: self => self.poll(1800000, self => { // Update every 30 minutes
            execAsync(['bash', '-c', `
                LOCATION="Athens,Greece"
                CONDITION=$(curl -s "wttr.in/$LOCATION?format=%C")
                TEMP=$(curl -s "wttr.in/$LOCATION?format=%t")
                
                if [[ -z "$CONDITION" ]] || echo "$CONDITION" | grep -qi "Unknown location"; then
                    echo "❓"
                    exit 0
                fi
                
                ICON="❓"
                case "$CONDITION" in
                    *Clear*|*Sunny*) ICON="☀️" ;;
                    *Partly*|*Clouds*) ICON="🌤️" ;;
                    *Cloudy*) ICON="☁️" ;;
                    *Overcast*) ICON="🌥️" ;;
                    *Thunder*|*Storm*) ICON="⛈️" ;;
                    *Snow*) ICON="❄️" ;;
                    *Light*|*Heavy*|*Showers*|*Drizzle*) ICON="🌧️" ;;
                    *Mist*|*Fog*) ICON="🌫️" ;;
                esac
                
                echo "$ICON$TEMP"
            `])
                .then(output => self.label = output.trim() || "❓")
                .catch(() => self.label = "❓");
        }),
    }),
    tooltipText: "Weather in Athens, Greece",
});

// CPU usage
const CPU = () => Widget.Button({
    class_name: "cpu",
    child: Widget.Label({
        setup: self => self.poll(15000, self => {
            execAsync(['bash', '-c', `top -bn1 | grep "Cpu(s)" | sed "s/.*, *\\([0-9.]*\\)%* id.*/\\1/" | awk '{print 100 - $1 "%"}'`])
                .then(output => self.label = ` ${output.trim()}`)
                .catch(() => self.label = " N/A");
        }),
    }),
});

// GPU temperature
const GPU = () => Widget.Button({
    class_name: "gpu",
    child: Widget.Label({
        setup: self => self.poll(90000, self => {
            execAsync(['bash', '-c', `
                if lspci | grep -i "nvidia" > /dev/null; then
                    nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits | head -1
                elif lspci | grep -qi "amd"; then
                    for dir in /sys/class/hwmon/hwmon*; do
                        if grep -q "amdgpu" "$dir/name"; then
                            RAW_TEMP=$(cat "$dir/temp1_input")
                            echo $((RAW_TEMP / 1000))
                            exit 0
                        fi
                    done
                    echo "N/A"
                else
                    echo "N/A"
                fi
            `])
                .then(temp => {
                    if (temp.trim() !== "N/A") {
                        self.label = `󰏈 ${temp.trim()}°C`;
                    } else {
                        self.label = "󰏈 N/A";
                    }
                })
                .catch(() => self.label = "󰏈 N/A");
        }),
    }),
    tooltipText: "GPU Temperature",
});

// Application launchers
const AppLauncher = () => Widget.Button({
    class_name: "app-launcher",
    child: Widget.Label("󰌧"),
    tooltipText: "App Launcher",
    on_clicked: () => execAsync(['rofi', '-show', 'drun', '-config', `${Utils.HOME}/.config/rofi/launcher.rasi`]).catch(() => {}),
});

const VSCodeLauncher = () => Widget.Button({
    class_name: "vscode",
    child: Widget.Label("󰘐"),
    tooltipText: "Visual Studio Code",
    on_clicked: () => execAsync(['code', '--enable-features=UseOzonePlatform', '--ozone-platform=wayland']).catch(() => {}),
});

const ChromeLauncher = () => Widget.Button({
    class_name: "chrome",
    child: Widget.Label("󰊯"),
    tooltipText: "Google Chrome",
    on_clicked: () => execAsync(['google-chrome-stable']).catch(() => {}),
});

const InsomniaLauncher = () => Widget.Button({
    class_name: "insomnia",
    child: Widget.Label("󱂛"),
    tooltipText: "Insomnia",
    on_clicked: () => execAsync(['insomnia']).catch(() => {}),
});

// Spotify widget with controls
const Spotify = () => Widget.Button({
    class_name: "spotify",
    child: Widget.Label({
        setup: self => self.poll(2000, self => {
            execAsync(['bash', '-c', `
                if ! (playerctl --list-all 2>/dev/null | grep -q spotify); then
                    echo ""
                    exit 0
                fi
                
                status=$(playerctl status -p spotify 2>/dev/null)
                if [ "$status" != "Playing" ] && [ "$status" != "Paused" ]; then
                    echo ""
                    exit 0
                fi
                
                artist=$(playerctl metadata -p spotify artist)
                title=$(playerctl metadata -p spotify title)
                
                short_title=$(echo "$title" | cut -c1-10)
                short_artist=$(echo "$artist" | cut -c1-9)
                
                icon=""
                [ "$status" = "Playing" ] && icon=""
                
                echo "$short_artist\\n$short_title"
            `])
                .then(output => {
                    if (output.trim()) {
                        self.label = output.trim();
                        self.get_parent().class_name = `spotify ${output.includes('') ? 'playing' : 'paused'}`;
                    } else {
                        self.label = "";
                        self.get_parent().class_name = "spotify";
                    }
                })
                .catch(() => {
                    self.label = "";
                    self.get_parent().class_name = "spotify";
                });
        }),
    }),
    on_clicked: () => execAsync(['playerctl', '-p', 'spotify', 'play-pause']).catch(() => {}),
    on_secondary_click: () => execAsync(['playerctl', '-p', 'spotify', 'next']).catch(() => {}),
    on_middle_click: () => execAsync(['playerctl', '-p', 'spotify', 'previous']).catch(() => {}),
    on_scroll_up: () => execAsync(['playerctl', '-p', 'spotify', 'volume', '0.05+']).catch(() => {}),
    on_scroll_down: () => execAsync(['playerctl', '-p', 'spotify', 'volume', '0.05-']).catch(() => {}),
});

// System tray
const SystemTray = () => Widget.Box({
    class_name: "system-tray",
    children: [],
    setup: self => self.hook(ags.Service.SystemTray || {}, self => {
        // AGS system tray implementation
        // This is a placeholder - AGS handles system tray differently
        self.children = [];
    }),
});

// Power menu
const PowerMenu = () => Widget.Button({
    class_name: "power-menu",
    child: Widget.Label("⏻"),
    tooltipText: "Power Menu",
    on_clicked: () => execAsync([`${Utils.HOME}/.config/hyprland/scripts/wofi-power-menu.sh`]).catch(() => {}),
});

// Restart waybar/AGS button
const RestartAGS = () => Widget.Button({
    class_name: "restart-ags",
    child: Widget.Label("🔄"),
    tooltipText: "Restart AGS",
    on_clicked: () => {
        execAsync(['ags', 'quit']).then(() => {
            Utils.timeout(2000, () => execAsync(['ags', 'run']).catch(() => {}));
        }).catch(() => {});
    },
});

// Main left bar
export const LeftBar = () => Widget.Window({
    name: "leftbar",
    anchor: ["left", "top", "bottom"],
    exclusivity: "exclusive",
    child: Widget.Box({
        class_name: "leftbar",
        vertical: true,
        children: [
            Widget.Box({
                class_name: "left-modules",
                vertical: true,
                children: [
                    Workspaces(),
                    LeftClock(),
                    Weather(),
                    CPU(),
                    GPU(),
                    AppLauncher(),
                    VSCodeLauncher(),
                    ChromeLauncher(),
                    InsomniaLauncher(),
                    Spotify(),
                ],
            }),
            Widget.Box({
                class_name: "left-modules-bottom",
                vertical: true,
                vpack: "end",
                children: [
                    SystemTray(),
                    PowerMenu(),
                    RestartAGS(),
                ],
            }),
        ],
    }),
});