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
      kgi = "kubectl get ingress";
      kctx = "kubectx";
      du = "du -hsc";
      cdnix = "cd ~/githubdir/nixos-config";
      cdlwgit = "cd ~/learnworlds/gitlabdir";
      cdlwdatsunprep = "cd ~/learnworlds/gitlabdir/datsunpreparator";
      rm = "rm -i";
    };

    history.size = 10000;
    history.ignoreAllDups = true;
    history.path = "$HOME/.zsh_history";
    history.ignorePatterns = ["rm *" "pkill *" "cp *"];
    # Add paths in PATH
    initContent = ''
      export PATH="$HOME/bin:$PATH"
      export KUBE_EDITOR=vim

      # zoxide init
      eval "$(zoxide init zsh)"

      # Bind Ctrl + Left Arrow to backward-word and Ctrl + Right Arrow to forward-word
      bindkey "^[[1;5D" backward-word
      bindkey "^[[1;5C" forward-word

      # getnix-index
      function getnixindexdb {
        local _index="index-$(uname -m | sed 's/^arm64$/aarch64/')-$(uname | tr A-Z a-z)"
        local _cache=~/.cache/nix-index
        local _file=''${_cache}/files
        test -d ''${_cache} || mkdir -p ''${_cache}
        curl -s -L -R -o ''${_file} -z ''${_file} \
          "https://github.com/Mic92/nix-index-database/releases/latest/download/''${_index}"
      }
      
      function kwide {
        kubectl $@ -o wide
      }

      function ktail {
        local _app=$1; shift
        kubectl logs --prefix -f -l app=''${_app} $@ | \
          grep -E -v 'health|metrics'
      }
    '';
  };
}
