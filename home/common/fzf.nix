{
  programs.fzf = {
    enable = true;
    defaultCommand = "rg --files --no-ignore-vcs --hidden";
    # Enable fzf keybindings for Bash
    enableBashIntegration = true;
    enableZshIntegration = true;

    # atuin owns Ctrl-R in zsh (history search + the host column — see
    # home/common/atuin.nix); its zsh integration is sourced after fzf's.
    # Disable fzf's Ctrl-R widget for zsh ONLY so the two don't fight (this is
    # what the home-manager eval warning is about). fzf keeps Ctrl-T / Alt-C
    # everywhere, and keeps Ctrl-R in bash, where atuin isn't integrated.
    historyWidget.zsh.command = "";
  };
}