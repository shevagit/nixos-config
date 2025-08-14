import { App, Astal, Gtk } from "astal/gtk3"
import { Variable, bind, exec, execAsync } from "astal"

// Simple workspaces
function Workspaces() {
    return <box className="workspaces">
        <label label="1" className="workspace active" />
        <label label="2" className="workspace" />
        <label label="3" className="workspace" />
        <label label="4" className="workspace" />
    </box>
}

// Clock
function Clock() {
    const time = Variable("").poll(1000, () => 
        new Date().toLocaleTimeString('en-US', { 
            hour: '2-digit', 
            minute: '2-digit',
            hour12: false
        })
    )
    
    return <button className="clock">
        <label label={bind(time).as(t => `⏰ ${t}`)} />
    </button>
}

// Memory
function Memory() {
    const memory = Variable("").poll(3000, () => 
        exec("free -h | awk '/^Mem:/ {print \" \" $3 \"/\" $2}'")
    )
    
    return <button className="memory">
        <label label={bind(memory)} />
    </button>
}

// Window title
function WindowTitle() {
    return <button className="window-title">
        <label label="Desktop" />
    </button>
}

// Top bar
function TopBar() {
    return <window
        className="topbar"
        anchor={Astal.WindowAnchor.TOP | Astal.WindowAnchor.LEFT | Astal.WindowAnchor.RIGHT}
        exclusivity={Astal.Exclusivity.EXCLUSIVE}>
        <centerbox>
            <box className="left-section" halign={Gtk.Align.START}>
                <Memory />
            </box>
            <box className="center-section" halign={Gtk.Align.CENTER}>
                <WindowTitle />
            </box>
            <box className="right-section" halign={Gtk.Align.END}>
                <Clock />
                <button className="notifications">
                    <label label="🔔" />
                </button>
            </box>
        </centerbox>
    </window>
}

// Left bar  
function LeftBar() {
    return <window
        className="leftbar"
        anchor={Astal.WindowAnchor.LEFT | Astal.WindowAnchor.TOP | Astal.WindowAnchor.BOTTOM}
        exclusivity={Astal.Exclusivity.EXCLUSIVE}>
        <box vertical className="left-container">
            <box vertical className="left-modules">
                <Workspaces />
                <Clock />
                <button className="weather">
                    <label label="🌤️ Weather" />
                </button>
                <button className="cpu">
                    <label label=" CPU" />
                </button>
                <button className="app-launcher">
                    <label label="󰌧" />
                </button>
                <button className="vscode">
                    <label label="󰘐" />
                </button>
                <button className="chrome">
                    <label label="󰊯" />
                </button>
            </box>
            <box vertical className="left-modules-bottom" valign={Gtk.Align.END}>
                <button className="power-menu">
                    <label label="⏻" />
                </button>
                <button className="restart-ags">
                    <label label="🔄" />
                </button>
            </box>
        </box>
    </window>
}

export default function Bar(monitor) {
    // For now, just create both bars on the primary monitor
    if (monitor === App.get_monitors()[0]) {
        return [TopBar(), LeftBar()]
    }
    return []
}