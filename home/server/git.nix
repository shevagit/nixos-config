{
  programs.git = {
    enable = true;
    aliases = {
      retag = "!f() { git tag -f -a \"$1\" -m \"$1\" && git push origin \"$1\" -f; }; f";
      deltag = "!f() { git tag -d \"$1\" && git push --delete origin \"$1\"; }; f";
    };
    extraConfig = {
      init = {
        defaultBranch = "main";
      };
    };
  };

  # Basic git config for server
  home.file = {
    ".gitconfig-github" = {
      text = ''
        [user]
            name = sheva
            email = shevaneo@gmail.com
        [commit]
            gpgSign = false
        [core]
            sshCommand = ssh -i ~/.ssh/nixsimos-github
      '';
    };
  };
}
