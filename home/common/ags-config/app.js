// Set GTK version first
imports.gi.versions.Gtk = '3.0';
const { Gtk, GLib, Gdk } = imports.gi;

print("AGS Starting...")
print("Gtk version:", Gtk.MAJOR_VERSION, Gtk.MINOR_VERSION)

// Create a simple window using GTK 3
const window = new Gtk.Window({
    type: Gtk.WindowType.TOPLEVEL,
    title: "AGS Test Bar",
    decorated: false,
});

const label = new Gtk.Label({
    label: "🎉 Hello from AGS - Modern Bar!",
    margin: 10,
});

// Style the window
window.set_default_size(300, 50);
window.add(label);

// Set window properties for wayland bar
window.set_type_hint(Gdk.WindowTypeHint.DOCK);
window.stick();
window.set_keep_above(true);

window.show_all();

print("Basic AGS bar created successfully!")