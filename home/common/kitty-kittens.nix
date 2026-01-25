{ pkgs, ... }:

{
  # Add Python with anthropic package for AI kittens
  home.packages = with pkgs; [
    (python3.withPackages (ps: with ps; [
      anthropic
    ]))
  ];

  # Command Explainer Kitten - Explain selected commands with Claude AI
  home.file.".config/kitty/kittens/ai-explain/__init__.py" = {
    executable = true;
    text = ''
      #!/usr/bin/env python3
      """
      AI Command Explainer Kitten for Kitty Terminal
      Explains shell commands using Claude AI
      Keybinding: ctrl+shift+x
      """

      import sys
      import os
      from typing import List
      from kitty.boss import Boss

      def main(args: List[str]) -> str:
          """
          Main entry point for the kitten.
          Called by kitty with command line arguments.
          """
          # If invoked without text, show usage
          if len(args) < 2:
              return "Usage: Select text in terminal, then press ctrl+shift+x to explain"

          # The selected text is passed as an argument
          command = " ".join(args[1:])

          if not command.strip():
              return "Error: No command text selected"

          # Check for API key
          api_key = os.environ.get('ANTHROPIC_API_KEY')
          if not api_key:
              return """Error: ANTHROPIC_API_KEY not set

      To set up your API key, add to your shell config (~/.zshrc or ~/.bashrc):
        export ANTHROPIC_API_KEY="sk-ant-..."

      Or add to your NixOS configuration:
        home.sessionVariables = {
          ANTHROPIC_API_KEY = "your-key-here";
        };

      Then reload your shell or run: source ~/.zshrc"""

          try:
              from anthropic import Anthropic

              # Show loading message
              print("🤔 Thinking... Asking Claude to explain the command...", flush=True)

              # Initialize Claude client
              client = Anthropic(api_key=api_key)

              # Create prompt for Claude
              prompt = f"""Explain this shell command in detail:

      {command}

      Please provide:
      1. What the command does (high-level overview)
      2. Explanation of each part/flag
      3. Any important notes or warnings
      4. Example use cases if relevant

      Keep the explanation clear and concise."""

              # Call Claude API
              response = client.messages.create(
                  model="claude-sonnet-4-5-20250929",
                  max_tokens=1024,
                  messages=[{"role": "user", "content": prompt}]
              )

              # Extract the response text
              explanation = response.content[0].text

              # Format output with nice borders
              output = f"""
      ╔════════════════════════════════════════════════════════════════╗
      ║              AI Command Explanation (Claude)                   ║
      ╠════════════════════════════════════════════════════════════════╣
      ║ Command: {command[:55]}{'...' if len(command) > 55 else ' ' * (55 - len(command))}║
      ╚════════════════════════════════════════════════════════════════╝

      {explanation}

      ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
      Press ESC or q to close
      """
              return output

          except ImportError:
              return """Error: anthropic package not found

      This shouldn't happen in NixOS. Try rebuilding your configuration:
        home-manager switch --flake .#sheva@nixsimos"""

          except Exception as e:
              return f"""Error calling Claude API: {str(e)}

      Common issues:
      - Check your ANTHROPIC_API_KEY is valid
      - Ensure you have internet connectivity
      - API might be temporarily unavailable (try again in a moment)

      Full error: {repr(e)}"""

      # This makes the kitten work as a text handler
      handle_result = main

      if __name__ == '__main__':
          result = main(sys.argv)
          print(result)
    '';
  };

  # Natural Language to Command Kitten (Phase 2)
  # Will be implemented in next phase
  home.file.".config/kitty/kittens/ai-command/__init__.py" = {
    executable = true;
    text = ''
      #!/usr/bin/env python3
      """
      AI Command Generator Kitten - Coming in Phase 2
      Converts natural language to shell commands
      Keybinding: ctrl+shift+a
      """

      import sys

      def main(args):
          return """AI Command Generator - Coming Soon!

      This kitten will convert natural language to shell commands.
      Example: "find all python files modified in the last week"
      → Output: find . -name "*.py" -mtime -7

      Status: Planned for Phase 2"""

      handle_result = main

      if __name__ == '__main__':
          print(main(sys.argv))
    '';
  };

  # Smart Command Suggestions Kitten (Phase 2)
  home.file.".config/kitty/kittens/ai-suggest/__init__.py" = {
    executable = true;
    text = ''
      #!/usr/bin/env python3
      """
      AI Smart Suggestions Kitten - Coming in Phase 2
      Context-aware command suggestions
      Keybinding: ctrl+shift+s
      """

      import sys

      def main(args):
          return """AI Smart Suggestions - Coming Soon!

      This kitten will analyze your current directory and suggest
      relevant commands based on:
      - Git status
      - Project type (Nix, Node, Python, etc.)
      - Available files and tools

      Status: Planned for Phase 2"""

      handle_result = main

      if __name__ == '__main__':
          print(main(sys.argv))
    '';
  };

  # Error Helper Kitten (Phase 2)
  home.file.".config/kitty/kittens/ai-error/__init__.py" = {
    executable = true;
    text = ''
      #!/usr/bin/env python3
      """
      AI Error Helper Kitten - Coming in Phase 2
      Diagnoses errors and suggests fixes
      Keybinding: ctrl+shift+f
      """

      import sys

      def main(args):
          return """AI Error Helper - Coming Soon!

      This kitten will:
      - Capture the last command output from scrollback
      - Detect error patterns
      - Send to Claude for diagnosis
      - Suggest fixes

      Status: Planned for Phase 2"""

      handle_result = main

      if __name__ == '__main__':
          print(main(sys.argv))
    '';
  };
}
