{ pkgs, ... }:

{
  # Add Python with anthropic package for AI kittens
  home.packages = with pkgs; [
    (python3.withPackages (ps: with ps; [
      anthropic
    ]))
    wl-clipboard  # For clipboard access on Wayland
  ];

  # Command Explainer Kitten - Explain selected commands with Claude AI
  home.file.".config/kitty/kittens/ai-explain.py" = {
    executable = true;
    text = ''
      #!/usr/bin/env python3
      """
      AI Command Explainer Kitten for Kitty Terminal
      Explains shell commands using Claude AI
      Keybinding: ctrl+shift+x

      Usage:
      1. Select text in terminal (with mouse or keyboard)
      2. Copy it (it's in clipboard now)
      3. Press ctrl+shift+x
      4. Or just press ctrl+shift+x and paste/type the command
      """

      import sys
      import os
      import subprocess

      def main():
          # Clear screen and show prominent overlay indicator
          print("\033[2J\033[H", end="")  # Clear screen and move cursor to top

          # Prominent overlay indicator
          print("\033[48;5;53m" + " " * 70 + "\033[0m")  # Purple background bar
          print("\033[48;5;53m\033[1;97m" + "  🪟  OVERLAY WINDOW - Press Enter when done to return to terminal  " + "\033[0m")
          print("\033[48;5;53m" + " " * 70 + "\033[0m")  # Purple background bar
          print()

          # Try to get text from clipboard first (if user selected something)
          try:
              # Try multiple clipboard methods
              try:
                  # Try wl-paste for Wayland
                  clipboard_text = subprocess.run(
                      ['wl-paste'],
                      capture_output=True,
                      text=True,
                      timeout=1
                  ).stdout.strip()
              except:
                  try:
                      # Try xclip for X11
                      clipboard_text = subprocess.run(
                          ['xclip', '-selection', 'clipboard', '-o'],
                          capture_output=True,
                          text=True,
                          timeout=1
                      ).stdout.strip()
                  except:
                      clipboard_text = ""
          except:
              clipboard_text = ""

          # If clipboard is empty or very long, prompt for input
          if not clipboard_text or len(clipboard_text) > 500:
              print("\n╔══════════════════════════════════════════════════════════╗")
              print("║           AI Command Explainer (Claude)                 ║")
              print("╚══════════════════════════════════════════════════════════╝\n")
              print("Enter the command to explain (or Ctrl+C to cancel):")
              print("→ ", end="", flush=True)

              try:
                  command = input().strip()
              except (KeyboardInterrupt, EOFError):
                  print("\nCancelled.")
                  return
          else:
              command = clipboard_text

          if not command:
              print("Error: No command provided")
              return

          # Check for API key - try env var first, then secrets file
          api_key = os.environ.get('ANTHROPIC_API_KEY')

          if not api_key:
              # Try to load from secrets file
              secrets_file = os.path.expanduser('~/.config/secrets.env')
              if os.path.exists(secrets_file):
                  try:
                      with open(secrets_file, 'r') as f:
                          for line in f:
                              line = line.strip()
                              if line.startswith('export ANTHROPIC_API_KEY='):
                                  # Parse: export ANTHROPIC_API_KEY="value" or export ANTHROPIC_API_KEY=value
                                  api_key = line.split('=', 1)[1].strip().strip('"').strip("'")
                                  break
                              elif line.startswith('ANTHROPIC_API_KEY='):
                                  api_key = line.split('=', 1)[1].strip().strip('"').strip("'")
                                  break
                  except Exception as e:
                      pass

          if not api_key:
              print("""
      ╔══════════════════════════════════════════════════════════╗
      ║                     ERROR                                ║
      ╚══════════════════════════════════════════════════════════╝

      ANTHROPIC_API_KEY not set!

      To fix this:
      1. Edit: ~/.config/secrets.env
      2. Add: export ANTHROPIC_API_KEY="sk-ant-..."
      3. Reload shell: source ~/.config/secrets.env

      Or run: echo $ANTHROPIC_API_KEY to check if it's set
      """)
              print("\n\033[48;5;53m" + " " * 70 + "\033[0m")
              print("\033[48;5;53m\033[1;97m" + "  🪟  OVERLAY - Press Enter to close and return to terminal     " + "\033[0m")
              print("\033[48;5;53m" + " " * 70 + "\033[0m")
              try:
                  input()
              except (KeyboardInterrupt, EOFError):
                  pass
              return

          try:
              from anthropic import Anthropic

              # Show loading message
              print("\n🤔 Thinking... Asking Claude to explain:", flush=True)
              print(f"   {command[:70]}{'...' if len(command) > 70 else '''}\n", flush=True)

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
      ╔══════════════════════════════════════════════════════════════════╗
      ║              AI Command Explanation (Claude)                     ║
      ╠══════════════════════════════════════════════════════════════════╣
      ║ Command: {command[:56]}{'...' if len(command) > 56 else ' ' * (56 - len(command))}║
      ╚══════════════════════════════════════════════════════════════════╝

      {explanation}
      """
              print(output)

              # Bottom indicator bar
              print("\n\033[48;5;53m" + " " * 70 + "\033[0m")
              print("\033[48;5;53m\033[1;97m" + "  🪟  OVERLAY - Press Enter to close and return to terminal     " + "\033[0m")
              print("\033[48;5;53m" + " " * 70 + "\033[0m")

              # Wait for user to press enter
              try:
                  input()
              except (KeyboardInterrupt, EOFError):
                  pass

          except ImportError:
              print("""
      ╔══════════════════════════════════════════════════════════╗
      ║                     ERROR                                ║
      ╚══════════════════════════════════════════════════════════╝

      Error: anthropic package not found

      This shouldn't happen in NixOS. Try rebuilding:
        home-manager switch --flake .#sheva@nixsimos
      """)
              print("\n\033[48;5;53m" + " " * 70 + "\033[0m")
              print("\033[48;5;53m\033[1;97m" + "  🪟  OVERLAY - Press Enter to close and return to terminal     " + "\033[0m")
              print("\033[48;5;53m" + " " * 70 + "\033[0m")
              try:
                  input()
              except (KeyboardInterrupt, EOFError):
                  pass

          except Exception as e:
              print(f"""
      ╔══════════════════════════════════════════════════════════╗
      ║                     ERROR                                ║
      ╚══════════════════════════════════════════════════════════╝

      Error calling Claude API: {str(e)}

      Common issues:
      - Check your ANTHROPIC_API_KEY is valid
      - Ensure you have internet connectivity
      - API might be temporarily unavailable

      Full error: {repr(e)}
      """)
              print("\n\033[48;5;53m" + " " * 70 + "\033[0m")
              print("\033[48;5;53m\033[1;97m" + "  🪟  OVERLAY - Press Enter to close and return to terminal     " + "\033[0m")
              print("\033[48;5;53m" + " " * 70 + "\033[0m")
              try:
                  input()
              except (KeyboardInterrupt, EOFError):
                  pass

      if __name__ == '__main__':
          main()
    '';
  };

  # Natural Language to Command Kitten (Phase 2)
  # Will be implemented in next phase
  home.file.".config/kitty/kittens/ai-command.py" = {
    executable = true;
    text = ''
      #!/usr/bin/env python3
      """
      AI Command Generator Kitten - Coming in Phase 2
      Converts natural language to shell commands
      Keybinding: ctrl+shift+a
      """

      print("""
      ╔══════════════════════════════════════════════════════════╗
      ║          AI Command Generator - Coming Soon!             ║
      ╚══════════════════════════════════════════════════════════╝

      This kitten will convert natural language to shell commands.

      Example:
        "find all python files modified in the last week"
        → find . -name "*.py" -mtime -7

      Status: Planned for Phase 2
      """)

      input("\nPress Enter to close...")
    '';
  };

  # Smart Command Suggestions Kitten (Phase 2)
  home.file.".config/kitty/kittens/ai-suggest.py" = {
    executable = true;
    text = ''
      #!/usr/bin/env python3
      """
      AI Smart Suggestions Kitten - Coming in Phase 2
      Context-aware command suggestions
      Keybinding: ctrl+shift+s
      """

      print("""
      ╔══════════════════════════════════════════════════════════╗
      ║          AI Smart Suggestions - Coming Soon!             ║
      ╚══════════════════════════════════════════════════════════╝

      This kitten will analyze your current directory and suggest
      relevant commands based on:
      - Git status
      - Project type (Nix, Node, Python, etc.)
      - Available files and tools

      Status: Planned for Phase 2
      """)

      input("\nPress Enter to close...")
    '';
  };

  # Error Helper Kitten (Phase 2)
  home.file.".config/kitty/kittens/ai-error.py" = {
    executable = true;
    text = ''
      #!/usr/bin/env python3
      """
      AI Error Helper Kitten - Coming in Phase 2
      Diagnoses errors and suggests fixes
      Keybinding: ctrl+shift+f
      """

      print("""
      ╔══════════════════════════════════════════════════════════╗
      ║            AI Error Helper - Coming Soon!                ║
      ╚══════════════════════════════════════════════════════════╝

      This kitten will:
      - Capture the last command output from scrollback
      - Detect error patterns
      - Send to Claude for diagnosis
      - Suggest fixes

      Status: Planned for Phase 2
      """)

      input("\nPress Enter to close...")
    '';
  };
}
