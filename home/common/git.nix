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
      gpg = {
        format = "ssh";
      };
      user = {
        signingkey = "~/.ssh/nixsimos-github.pub";
      };
      "includeIf.gitdir:/home/sheva/githubdir/" = {
        path = "~/.gitconfig-github";
      };
      "includeIf.gitdir:/home/sheva/learnworlds/gitlabdir/" = {
        path = "~/.gitconfig-gitlab";
      };
    };
  };

  # create separate configuration files for each use
  home.file = {
    ".gitconfig-github" = {
      text = ''
        [user]
            name = sheva
            email = shevaneo@gmail.com
        [core]
            sshCommand = ssh -i ~/.ssh/nixsimos-github.pub
      '';
    };

    ".gitconfig-gitlab" = {
      text = ''
        [user]
            name = Andreas Sevastos
            email = sheva@learnworlds.com
        [core]
            sshCommand = ssh -i ~/.ssh/ed25519_gitlab.pub
      '';
    };
  };
}