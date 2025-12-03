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
      kaccount = "kubectl get pods --context us-e2 -n production -w | grep -E '^account-[^-]+-[^-]+$'";
      kwebsite = "kubectl get pods --context us-e1 -n production -w | grep -E '^website-[^-]+-[^-]+$'";
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
      export PATH="$HOME/bin:$HOME/.local/bin:$PATH"
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

      function kcopy {
        local src=$1
        local dest_or_app=$2
        local dest_path=''${3:-/tmp}
        
        # Check if we're copying TO or FROM pod
        if [[ "$src" == *:* ]]; then
          # Format: kcopy service:file.log ./local-path
          local app="''${src%%:*}"
          local remote_path="''${src#*:}"
          local local_path="$dest_or_app"
          
          local pod=$(kubectl get pods -l app="$app" -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
          
          if [[ -z "$pod" ]]; then
            echo "No pod found for app=$app"
            return 1
          fi
          
          echo "Copying from $pod:$remote_path to $local_path"
          kubectl cp "$pod:$remote_path" "$local_path"
        else
          # Format: kcopy file.log service [/remote/path]
          local app="$dest_or_app"
          
          local pod=$(kubectl get pods -l app="$app" -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
          
          if [[ -z "$pod" ]]; then
            echo "No pod found for app=$app"
            return 1
          fi
          
          echo "Copying $src to $pod:$dest_path"
          kubectl cp "$src" "$pod:$dest_path"
        fi
      }
    '';
  };
}
