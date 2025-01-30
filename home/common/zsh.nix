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
      rm = "rm -i";
    };

    history.size = 10000;
    history.ignoreAllDups = true;
    history.path = "$HOME/.zsh_history";
    history.ignorePatterns = ["rm *" "pkill *" "cp *"];
    # Add paths in PATH
    initExtra = ''
      export PATH="$HOME/bin:$PATH"

      # Bind Ctrl + Left Arrow to backward-word and Ctrl + Right Arrow to forward-word
      bindkey "^[[1;5D" backward-word
      bindkey "^[[1;5C" forward-word
    '';
  };
}
