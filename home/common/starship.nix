{
  programs.starship = {
    enable = true;
    settings = {
      "$schema" = "https://starship.rs/config-schema.json";

      # General settings
      add_newline = true;

      # Prompt character
      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[✗](bold red)";
      };

      direnv = { disabled = false; };

      directory = { truncation_length = 6; };

      git_branch = { symbol = "🌱 "; };

      git_status = {
        conflicted = "🏳";
        ahead = "⇡$${count}";
        diverged = "⇕⇡$${ahead_count}⇣$${behind_count}";
        behind = "⇣$${count}";
        up_to_date = "✓";
        untracked = "🤷";
        stashed = "📦";
        modified = "📝";
        staged = "[++($${count})](green)";
        renamed = "👅";
        deleted = "🗑";
      };

      sudo = {
        style = "bold green";
        symbol = "👩 💻 ";
        disabled = false;
      };

      gcloud = { format = "on [$symbol($project)]($style) "; };

      kubernetes = {
        symbol = "☸️ ";
        disabled = false;
        style = "red";
        format = "[$symbol$context(/$namespace)]($style) in ";
        contexts = [
          { context_pattern = "dev-eu-w1"; style = "green"; }
          { context_pattern = "test-playground-us-w3"; style = "yellow"; }
        ];
      };

      golang = {
        symbol = "🐹 ";
        style = "bold cyan";
        format = "via [$symbol$version]($style) ";
      };

      docker_context = { format = "via [🐋 $context](blue bold)"; };

      time = {
        disabled = false;
        format = "[$time]($style) ";
        time_format = "%T";
        style = "bold yellow";
      };

      terraform = {
        format = "[🏎💨 $workspace]($style) ";
        detect_folders = [ ".terraform" ];
      };

      helm = { format = "via [⎈ $version](bold white) "; };
    };
  };
}
