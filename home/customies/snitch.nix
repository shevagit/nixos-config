{ snitch, ... }:

{
  imports = [
    snitch.homeManagerModules.default
  ];

  programs.snitch = {
    enable = true;
    # settings = {
    #   theme = "catppuccin-mocha";  # or "gruvbox-dark", "dracula", "nord", etc.
    #   update_interval = 60;
    # };
  };
}
