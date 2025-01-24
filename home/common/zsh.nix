{ pkgs, ... }:{
 programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      ll = "ls -lash";
      k  = "kubectl";
      kgp = "kubectl get pods";
      kns = "kubens";
      kctx = "kubectx";
      du = "du -hsc";
      cdnix = "cd ~/githubdir/nixos-config";
      cdlwgit = "cd ~/learnworlds/gitlabdir";
    };

    history.size = 10000;
    history.ignoreAllDups = true;
    history.path = "$HOME/.zsh_history";
    history.ignorePatterns = ["rm *" "pkill *" "cp *"];
    # Add paths in PATH
    initExtra = ''
      export PATH="$HOME/bin:$PATH"
    '';
  };
}
