{ pkgs, ... }:{
 programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      ll = "ls -lash";
      l = "ls -lh";
      k  = "kubectl";
      kgp = "kubectl get pods";
      kns = "kubens";
      kgi = "kubectl get ingress";
      kctx = "kubectx";
      du = "du -hsc";
      rm = "rm -i";
      gp = "git pull";
      gs = "git status";
      gd = "git diff";
    };

    history.size = 10000;
    history.ignoreAllDups = true;
    history.path = "$HOME/.zsh_history";
    history.ignorePatterns = [ "rm *" ];
    # Add paths in PATH
    initContent = ''
      # ~/sync/bin is Syncthing-replicated to the other machines, so a helper
      # script written here is runnable everywhere within seconds — no rebuild,
      # no commit. Syncthing preserves the executable bit, so chmod +x travels
      # with it. Use `#!/usr/bin/env bash`: NixOS has no /bin/bash.
      # Scripts worth versioning belong in the repo instead, not here.
      export PATH="$HOME/bin:$HOME/.local/bin:$HOME/sync/bin:$PATH"
      export KUBE_EDITOR=nvim
      export EDITOR=nvim

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
