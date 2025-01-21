{
  # Configure GNOME settings using dconf
  dconf.settings = {
    "org/gnome/desktop/default-applications/terminal" = {
      exec = "terminator";
      exec-arg = "-x";
    };
  };
}
