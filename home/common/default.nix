{
    imports = [
        ./git.nix
        ./fzf.nix
        ./zsh.nix
        ./starship.nix
        ./terminal.nix
        ./kitty-kittens.nix  # AI-powered terminal kittens
        ./go.nix
        ./kube.nix
        ./docker.nix
        ./hyprland.nix
        ./hyprland-theme.nix
        # ./swww.nix  # Disabled - DMS handles wallpapers
        # ./wlogout.nix  # Disabled - DMS handles power menu
        ./vscode-plugins.nix
        ./neovim.nix
        ./ai.nix
        # ./hyprpanel.nix  # Disabled - replaced by DMS (Dank Material Shell)
        ./dms  # DMS (Dank Material Shell) configuration
    ];
}