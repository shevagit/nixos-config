{
  programs.fzf = {
    enable = true;
    defaultCommand = "rg --files --no-ignore-vcs --hidden";
    # Enable fzf keybindings for Bash
    enableBashIntegration = true;
    enableZshIntegration = true;
  };
}