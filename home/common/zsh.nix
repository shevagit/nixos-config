{ pkgs, ... }:{
 programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      ll = "ls -l";
      k  = "kubectl";
      kgp = "kubectl get pods";
      kns = "kubens";
      kctx = "kubectx";
      du = "du -hsc";
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
