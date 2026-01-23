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

      # keychain init - load ssh keys
      eval "$(keychain --eval --quiet)"

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
        
        if [[ -z "$src" ]] || [[ -z "$dest_or_app" ]]; then
          echo "Usage:"
          echo "  kcopy <local-file> <service> [remote-path]     # Copy TO pod"
          echo "  kcopy <service>:<remote-file> <local-path>     # Copy FROM pod"
          echo ""
          echo "Examples:"
          echo "  kcopy file.log myservice           # Copy to /tmp in pod"
          echo "  kcopy file.log myservice /app/     # Copy to /app/ in pod"
          echo "  kcopy myservice:/tmp/log.txt ./    # Copy from pod to local"
          return 1
        fi
        
        if [[ "$src" == *:* ]]; then
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
          local app="$dest_or_app"
          
          local pod=$(kubectl get pods -l app="$app" -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
          
          if [[ -z "$pod" ]]; then
            echo "No pod found for app=$app"
            return 1
          fi
          
          echo "Copying $src to $pod:$dest_path"
          kubectl cp "$src" "$pod:$dest_path"
        fi
        
        echo -n "Exec into $pod? [y/N] "
        read -r response
        if [[ "$response" =~ ^[Yy]$ ]]; then
          kubectl exec -it "$pod" -- /bin/sh
        fi
      }

      function kgp {
        # 1) Watch mode shortcut: kgp -w [extra kubectl args...]
        if [[ "$1" == "-w" || "$1" == "--watch" ]]; then
          shift
          kubectl get pods -w "$@"
          return
        fi

        # 2) Regex mode + legacy behavior
        local pattern="''${1:-}"
        shift 2>/dev/null || true

        # optional --all to print all matches
        local mode=""
        if [[ "''${1:-}" == "--all" ]]; then
          mode="--all"
          shift
        fi

        # any remaining args are passed to "kubectl get pods ..."
        local extra_args=("$@")

        # No args → plain get pods (preserves your original behavior)
        if [[ -z "$pattern" ]]; then
          kubectl get pods "''${extra_args[@]}"
          return
        fi

        # Fetch pod names (respecting any extra args like -n, -A, -l, etc.)
        local pods
        IFS=' ' read -r -A pods <<< "$(kubectl get pods "''${extra_args[@]}" -o jsonpath='{.items[*].metadata.name}')"

        local matches=()
        for p in "''${pods[@]}"; do
          if [[ $p =~ $pattern ]]; then
            matches+=("$p")
          fi
        done

        if (( ''${#matches[@]} == 0 )); then
          echo "No pods match regex: $pattern"
          return 1
        fi

        if [[ "$mode" == "--all" ]]; then
          printf "%s\n" "''${matches[@]}"
          return
        fi

        # Default: first match (zsh arrays are 1-indexed)
        echo "''${matches[1]}"
      }

      typeset -A KUBE_GROUPS=(
        [all]="asia-se1 sa-br1 eu-w3 eu-w4 me-c2 us-e1 us-e2"
        [emea]="eu-w3 eu-w4 me-c2"
        [us]="us-e1 us-e2"
        [apac]="asia-se1 sa-br1"
      )

      function krun {
        local parallel=0 ns="" contexts=()

        # print help if no args
        if [[ $# -eq 0 ]]; then
          echo ""
          echo "Usage: krun [options] [kubectl command...]"
          echo ""
          echo "Options:"
          echo "  --all                Run on all contexts"
          echo "  --group <name>       Run on a predefined group (see below)"
          echo "  --contexts \"c1 c2\"   Run on specific contexts"
          echo "  -P, --parallel       Run all contexts in parallel"
          echo "  -n, --namespace NS   Specify namespace for all contexts"
          echo "  -y                   Skip confirmation for mutating commands"
          echo ""
          echo "Available context groups:"
          for group in "''${(k)KUBE_GROUPS[@]}"; do
            echo "  $group: ''${KUBE_GROUPS[$group]}"
          done
          echo ""
          echo "Current kube contexts:"
          kubectl config get-contexts -o name | sed 's/^/  /'
          echo ""
          echo "Examples:"
          echo "  krun --all -- get pods -A"
          echo "  krun --group us -P -- rollout restart deploy/myapp -n production"
          echo "  krun --contexts \"us-e1 eu-w4\" -- get nodes -o wide"
          echo ""
          return 0
        fi

        # parse flags
        while (( $# )); do
          case "$1" in
            --all)        contexts=(''${=KUBE_GROUPS[all]}); shift ;;
            --group)      contexts=(''${=KUBE_GROUPS[$2]}); shift 2 ;;
            --contexts)   contexts=(''${=2}); shift 2 ;;
            -P|--parallel) parallel=1; shift ;;
            -n|--namespace) ns="$2"; shift 2 ;;
            --) shift; break ;;
            *)  break ;;
          esac
        done

        local cmd=("$@")
        # default: current context only
        (( ''${#contexts} == 0 )) && contexts=($(kubectl config current-context))

        # safety prompt for mutating ops (unless user passed -y)
        if [[ ! " $* " =~ " -y " ]]; then
          if [[ " ''${cmd[*]} " =~ "( apply | delete | scale | rollout | cordon | drain )" ]]; then
            echo "About to run on ''${#contexts} context(s): ''${contexts[*]}"
            read "REPLY?Continue? [y/N] "; [[ $REPLY =~ ^[Yy]$ ]] || return 1
          fi
        fi

        local pids=() rc=0
        for ctx in "''${contexts[@]}"; do
          if (( parallel )); then
            (
              echo ">>> [$ctx] kubectl ''${cmd[*]}"
              kubectl --context "$ctx" ''${ns:+--namespace "$ns"} "''${cmd[@]}" \
                | sed -e "s/^/[$ctx] /"
            ) & pids+=($!)
          else
            echo ">>> [$ctx] kubectl ''${cmd[*]}"
            kubectl --context "$ctx" ''${ns:+--namespace "$ns"} "''${cmd[@]}" \
              | sed -e "s/^/[$ctx] /"
          fi
        done

        if (( parallel )); then
          for pid in "''${pids[@]}"; do wait "$pid" || rc=1; done
          return $rc
        fi
      }
    '';
  };
}
