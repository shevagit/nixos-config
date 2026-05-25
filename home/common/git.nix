{ osConfig, ... }:
let
  host = osConfig.networking.hostName;
in
{
  programs.git = {
    enable = true;
    signing.format = null;
    settings = {
      alias = {
        retag = "!f() { git tag -f -a \"$1\" -m \"$1\" && git push origin \"$1\" -f; }; f";
        deltag = "!f() { git tag -d \"$1\" && git push --delete origin \"$1\"; }; f";
      };
      init = {
        defaultBranch = "main";
      };
      "includeIf.gitdir:/home/sheva/githubdir/" = {
        path = "~/.gitconfig-github";
      };
      "includeIf.gitdir:/home/sheva/learnworlds/gitlabdir/" = {
        path = "~/.gitconfig-gitlab";
      };
      "includeIf.gitdir:/home/sheva/learnworlds/githubdir/" = {
        path = "~/.gitconfig-githublw";
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
        [commit]
            gpgSign = false
        [core]
            sshCommand = ssh -i ~/.ssh/nix${host}-p
      '';
    };
    ".gitconfig-gitlab" = {
      text = ''
        [user]
            name = Andreas Sevastos
            email = sheva@learnworlds.com
            signingkey = ~/.ssh/nix${host}-gl.pub
        [gpg]
            format = ssh
        [commit]
            gpgSign = true
        [core]
            sshCommand = ssh -i ~/.ssh/nix${host}-gl
      '';
    };
    ".gitconfig-githublw" = {
      text = ''
        [user]
            name = Andreas Sevastos
            email = sheva@learnworlds.com
            signingkey = ~/.ssh/nix${host}-w.pub
        [gpg]
            format = ssh
        [commit]
            gpgSign = true
        [core]
            sshCommand = ssh -i ~/.ssh/nix${host}-w -o IdentitiesOnly=yes
        [url "git@github-work:"]
            insteadOf = git@github.com:
      '';
    };
  };
}