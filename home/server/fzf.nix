{
  programs.fzf = {
    enable = true;
    defaultCommand = "rg --files --no-ignore-vcs --hidden";
    # Enable fzf keybindings for shells
    enableBashIntegration = true;
    enableZshIntegration = true;
  };
}
