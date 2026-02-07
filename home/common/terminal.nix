{

  programs.kitty = {
    enable = true;
    themeFile = "Dracula";
    settings = {
      confirm_os_window_close = 0;
      dynamic_background_opacity = true;
      enable_audio_bell = false;
      mouse_hide_wait = "-1.0";
      window_padding_width = 10;
      background_opacity = "0.5";
      background_blur = 5;
      shell_integration = "no-rc";
      copy_on_select = "clipboard";  # Auto-copy selected text
      strip_trailing_spaces = "smart";  # Clean up copied text
      allow_remote_control = "yes";
    };
    extraConfig = ''
      mouse_map right press ungrabbed paste_from_clipboard
    '';
    keybindings = {
      # Terminator-style splits
      "ctrl+shift+o" = "launch --location=vsplit --cwd=current";
      "ctrl+shift+e" = "launch --location=hsplit --cwd=current";
      "ctrl+shift+w" = "close_window";

      # Navigate between panes
      "ctrl+shift+left" = "neighboring_window left";
      "ctrl+shift+right" = "neighboring_window right";
      "ctrl+shift+up" = "neighboring_window up";
      "ctrl+shift+down" = "neighboring_window down";

      # AI Kittens - Claude-powered terminal assistance
      "ctrl+shift+x" = "launch --type=overlay --hold python3 ~/.config/kitty/kittens/ai-explain.py";   # Explain command
      "ctrl+shift+a" = "launch --type=overlay --hold python3 ~/.config/kitty/kittens/ai-command.py";   # Natural language to command
      "ctrl+shift+s" = "launch --type=overlay --hold python3 ~/.config/kitty/kittens/ai-suggest.py";   # Smart suggestions
      "ctrl+shift+f" = "launch --type=overlay --hold python3 ~/.config/kitty/kittens/ai-error.py";     # Error helper
    };
  };

  programs.alacritty = {
    enable = true;
    settings = {
      env.TERM = "xterm-256color";
      font = {
        size = 12;
      };
      scrolling.multiplier = 5;
      selection.save_to_clipboard = true;
    };
  };
}
