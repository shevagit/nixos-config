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

          # Check for API key - try multiple sources
          api_key = os.environ.get('ANTHROPIC_API_KEY')

          if not api_key:
              # Try sops-managed secret (preferred method)
              sops_secret = '/run/secrets/anthropic_api_key'
              if os.path.exists(sops_secret):
                  try:
                      with open(sops_secret, 'r') as f:
                          api_key = f.read().strip()
                  except:
                      pass

          if not api_key:
              # Fallback: Try to load from old secrets.env file
              secrets_file = os.path.expanduser('~/.config/secrets.env')
              if os.path.exists(secrets_file):
                  try:
                      with open(secrets_file, 'r') as f:
                          for line in f:
                              line = line.strip()
                              if line.startswith('export ANTHROPIC_API_KEY='):
                                  api_key = line.split('=', 1)[1].strip().strip('"').strip("'")
                                  break
                              elif line.startswith('ANTHROPIC_API_KEY='):
                                  api_key = line.split('=', 1)[1].strip().strip('"').strip("'")
                                  break
                  except:
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

              # Call Claude API (using Haiku for cost efficiency)
              response = client.messages.create(
                  model="claude-haiku-4-5-20251001",
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

  # Natural Language to Command Kitten
  home.file.".config/kitty/kittens/ai-command.py" = {
    executable = true;
    text = ''
      #!/usr/bin/env python3
      """
      AI Command Generator Kitten
      Converts natural language to shell commands
      Keybinding: ctrl+shift+a
      """

      import sys
      import os
      import subprocess

      def main():
          # Clear screen and show prominent overlay indicator
          print("\033[2J\033[H", end="")  # Clear screen

          # Prominent overlay indicator
          print("\033[48;5;53m" + " " * 70 + "\033[0m")
          print("\033[48;5;53m\033[1;97m" + "  🪟  OVERLAY WINDOW - Press Enter when done to return to terminal  " + "\033[0m")
          print("\033[48;5;53m" + " " * 70 + "\033[0m")
          print()

          print("\n╔══════════════════════════════════════════════════════════╗")
          print("║        AI Command Generator (Natural Language)          ║")
          print("╚══════════════════════════════════════════════════════════╝\n")
          print("Describe what you want to do in plain English:")
          print("(e.g., 'find all python files modified in the last week')\n")
          print("→ ", end="", flush=True)

          try:
              query = input().strip()
          except (KeyboardInterrupt, EOFError):
              print("\nCancelled.")
              return

          if not query:
              print("Error: No query provided")
              return

          # Get current working directory for context
          try:
              cwd = os.getcwd()
          except:
              cwd = "~"

          # Check for API key - try multiple sources
          api_key = os.environ.get('ANTHROPIC_API_KEY')

          if not api_key:
              # Try sops-managed secret (preferred method)
              sops_secret = '/run/secrets/anthropic_api_key'
              if os.path.exists(sops_secret):
                  try:
                      with open(sops_secret, 'r') as f:
                          api_key = f.read().strip()
                  except:
                      pass

          if not api_key:
              # Fallback: Try to load from old secrets.env file
              secrets_file = os.path.expanduser('~/.config/secrets.env')
              if os.path.exists(secrets_file):
                  try:
                      with open(secrets_file, 'r') as f:
                          for line in f:
                              line = line.strip()
                              if line.startswith('export ANTHROPIC_API_KEY='):
                                  api_key = line.split('=', 1)[1].strip().strip('"').strip("'")
                                  break
                              elif line.startswith('ANTHROPIC_API_KEY='):
                                  api_key = line.split('=', 1)[1].strip().strip('"').strip("'")
                                  break
                  except:
                      pass

          if not api_key:
              print("\n❌ Error: ANTHROPIC_API_KEY not set!")
              print("Edit ~/.config/secrets.env to add your API key")
              print("\n\033[48;5;53m" + " " * 70 + "\033[0m")
              print("\033[48;5;53m\033[1;97m" + "  🪟  OVERLAY - Press Enter to close and return to terminal     " + "\033[0m")
              print("\033[48;5;53m" + " " * 70 + "\033[0m")
              try:
                  input()
              except:
                  pass
              return

          try:
              from anthropic import Anthropic

              print("\n🤔 Thinking... Generating command...\n", flush=True)

              client = Anthropic(api_key=api_key)

              prompt = f"""Generate a shell command for this task: {query}

      Current directory: {cwd}

      Provide:
      1. The exact command to run (just the command, no explanation yet)
      2. A brief explanation of what it does
      3. Any important warnings or notes

      Format your response as:
      COMMAND: <the actual command>
      EXPLANATION: <explanation>
      NOTES: <any warnings or tips>"""

              response = client.messages.create(
                  model="claude-haiku-4-5-20251001",
                  max_tokens=512,
                  messages=[{"role": "user", "content": prompt}]
              )

              result = response.content[0].text

              print("╔══════════════════════════════════════════════════════════════════╗")
              print("║                    Generated Command                             ║")
              print("╚══════════════════════════════════════════════════════════════════╝\n")
              print(result)
              print()

              # Try to extract just the command for clipboard
              command_line = ""
              for line in result.split('\n'):
                  if line.strip().startswith('COMMAND:'):
                      command_line = line.split('COMMAND:', 1)[1].strip()
                      break

              if command_line:
                  # Try to copy to clipboard
                  try:
                      subprocess.run(['wl-copy'], input=command_line.encode(), timeout=1)
                      print("✅ Command copied to clipboard!")
                  except:
                      try:
                          subprocess.run(['xclip', '-selection', 'clipboard'], input=command_line.encode(), timeout=1)
                          print("✅ Command copied to clipboard!")
                      except:
                          print("ℹ️  Could not copy to clipboard automatically")

              print("\n\033[48;5;53m" + " " * 70 + "\033[0m")
              print("\033[48;5;53m\033[1;97m" + "  🪟  OVERLAY - Press Enter to close and return to terminal     " + "\033[0m")
              print("\033[48;5;53m" + " " * 70 + "\033[0m")

              try:
                  input()
              except:
                  pass

          except ImportError:
              print("\n❌ Error: anthropic package not found")
              print("Try: home-manager switch --flake .#sheva@nixsimos")
              print("\n\033[48;5;53m" + " " * 70 + "\033[0m")
              print("\033[48;5;53m\033[1;97m" + "  🪟  OVERLAY - Press Enter to close and return to terminal     " + "\033[0m")
              print("\033[48;5;53m" + " " * 70 + "\033[0m")
              try:
                  input()
              except:
                  pass

          except Exception as e:
              print(f"\n❌ Error: {str(e)}")
              print("\n\033[48;5;53m" + " " * 70 + "\033[0m")
              print("\033[48;5;53m\033[1;97m" + "  🪟  OVERLAY - Press Enter to close and return to terminal     " + "\033[0m")
              print("\033[48;5;53m" + " " * 70 + "\033[0m")
              try:
                  input()
              except:
                  pass

      if __name__ == '__main__':
          main()
    '';
  };

  # Smart Command Suggestions Kitten
  home.file.".config/kitty/kittens/ai-suggest.py" = {
    executable = true;
    text = ''
      #!/usr/bin/env python3
      """
      AI Smart Suggestions Kitten
      Context-aware command suggestions based on current directory
      Keybinding: ctrl+shift+s
      """

      import sys
      import os
      import subprocess
      from pathlib import Path

      def get_context():
          """Gather context about current directory"""
          context = {}
          cwd = os.getcwd()
          context['cwd'] = cwd

          # Check if git repo
          try:
              result = subprocess.run(
                  ['git', 'rev-parse', '--is-inside-work-tree'],
                  capture_output=True,
                  timeout=2,
                  cwd=cwd
              )
              context['is_git_repo'] = result.returncode == 0
              if context['is_git_repo']:
                  # Get git status summary
                  status = subprocess.run(
                      ['git', 'status', '--short'],
                      capture_output=True,
                      text=True,
                      timeout=2,
                      cwd=cwd
                  ).stdout.strip()
                  context['git_status'] = status if status else 'clean'
          except:
              context['is_git_repo'] = False

          # Detect project type by looking for common files
          project_indicators = {
              'package.json': 'Node.js/JavaScript',
              'Cargo.toml': 'Rust',
              'flake.nix': 'Nix Flake',
              'pyproject.toml': 'Python (Poetry)',
              'requirements.txt': 'Python',
              'go.mod': 'Go',
              'pom.xml': 'Java (Maven)',
              'build.gradle': 'Java (Gradle)',
              'Makefile': 'Make project',
              'docker-compose.yml': 'Docker Compose',
              'Dockerfile': 'Docker',
          }

          detected_types = []
          for file, ptype in project_indicators.items():
              if Path(cwd) / file in Path(cwd).iterdir() if (Path(cwd) / file).exists() else []:
                  detected_types.append(ptype)

          # Simpler check
          for file, ptype in project_indicators.items():
              if os.path.exists(os.path.join(cwd, file)):
                  detected_types.append(ptype)

          context['project_types'] = detected_types if detected_types else ['General']

          # List some files (not too many)
          try:
              files = os.listdir(cwd)[:20]  # First 20 files
              context['files'] = files
          except:
              context['files'] = []

          return context

      def main():
          # Clear screen and show prominent overlay indicator
          print("\033[2J\033[H", end="")

          print("\033[48;5;53m" + " " * 70 + "\033[0m")
          print("\033[48;5;53m\033[1;97m" + "  🪟  OVERLAY WINDOW - Press Enter when done to return to terminal  " + "\033[0m")
          print("\033[48;5;53m" + " " * 70 + "\033[0m")
          print()

          print("\n╔══════════════════════════════════════════════════════════╗")
          print("║           AI Smart Command Suggestions                  ║")
          print("╚══════════════════════════════════════════════════════════╝\n")
          print("🔍 Analyzing current directory...\n", flush=True)

          # Gather context
          context = get_context()

          print(f"📁 Directory: {context['cwd']}")
          print(f"📦 Project type: {', '.join(context['project_types'])}")
          if context['is_git_repo']:
              print(f"🔀 Git repo: Yes (status: {context['git_status'][:50] if context['git_status'] != 'clean' else 'clean'})")
          else:
              print("🔀 Git repo: No")
          print()

          # Check for API key - try multiple sources
          api_key = os.environ.get('ANTHROPIC_API_KEY')

          if not api_key:
              # Try sops-managed secret (preferred method)
              sops_secret = '/run/secrets/anthropic_api_key'
              if os.path.exists(sops_secret):
                  try:
                      with open(sops_secret, 'r') as f:
                          api_key = f.read().strip()
                  except:
                      pass

          if not api_key:
              # Fallback: Try to load from old secrets.env file
              secrets_file = os.path.expanduser('~/.config/secrets.env')
              if os.path.exists(secrets_file):
                  try:
                      with open(secrets_file, 'r') as f:
                          for line in f:
                              line = line.strip()
                              if line.startswith('export ANTHROPIC_API_KEY='):
                                  api_key = line.split('=', 1)[1].strip().strip('"').strip("'")
                                  break
                              elif line.startswith('ANTHROPIC_API_KEY='):
                                  api_key = line.split('=', 1)[1].strip().strip('"').strip("'")
                                  break
                  except:
                      pass

          if not api_key:
              print("\n❌ Error: ANTHROPIC_API_KEY not set!")
              print("Edit ~/.config/secrets.env to add your API key")
              print("\n\033[48;5;53m" + " " * 70 + "\033[0m")
              print("\033[48;5;53m\033[1;97m" + "  🪟  OVERLAY - Press Enter to close and return to terminal     " + "\033[0m")
              print("\033[48;5;53m" + " " * 70 + "\033[0m")
              try:
                  input()
              except:
                  pass
              return

          try:
              from anthropic import Anthropic

              print("🤔 Asking Claude for suggestions...\n", flush=True)

              client = Anthropic(api_key=api_key)

              prompt = f"""Based on this directory context, suggest 5-8 useful shell commands:

      Directory: {context['cwd']}
      Project types: {', '.join(context['project_types'])}
      Git repo: {context['is_git_repo']}
      {f"Git status: {context['git_status']}" if context['is_git_repo'] else ""}

      Sample files: {', '.join(context['files'][:10])}

      Suggest practical commands I might want to run in this context.
      For each command, provide a one-line description.

      Format as:
      1. command - description
      2. command - description
      etc."""

              response = client.messages.create(
                  model="claude-haiku-4-5-20251001",
                  max_tokens=512,
                  messages=[{"role": "user", "content": prompt}]
              )

              suggestions = response.content[0].text

              print("╔══════════════════════════════════════════════════════════════════╗")
              print("║                  Suggested Commands                              ║")
              print("╚══════════════════════════════════════════════════════════════════╝\n")
              print(suggestions)

              print("\n\033[48;5;53m" + " " * 70 + "\033[0m")
              print("\033[48;5;53m\033[1;97m" + "  🪟  OVERLAY - Press Enter to close and return to terminal     " + "\033[0m")
              print("\033[48;5;53m" + " " * 70 + "\033[0m")

              try:
                  input()
              except:
                  pass

          except ImportError:
              print("\n❌ Error: anthropic package not found")
              print("Try: home-manager switch --flake .#sheva@nixsimos")
              print("\n\033[48;5;53m" + " " * 70 + "\033[0m")
              print("\033[48;5;53m\033[1;97m" + "  🪟  OVERLAY - Press Enter to close and return to terminal     " + "\033[0m")
              print("\033[48;5;53m" + " " * 70 + "\033[0m")
              try:
                  input()
              except:
                  pass

          except Exception as e:
              print(f"\n❌ Error: {str(e)}")
              print("\n\033[48;5;53m" + " " * 70 + "\033[0m")
              print("\033[48;5;53m\033[1;97m" + "  🪟  OVERLAY - Press Enter to close and return to terminal     " + "\033[0m")
              print("\033[48;5;53m" + " " * 70 + "\033[0m")
              try:
                  input()
              except:
                  pass

      if __name__ == '__main__':
          main()
    '';
  };

  # Error Helper Kitten
  home.file.".config/kitty/kittens/ai-error.py" = {
    executable = true;
    text = ''
      #!/usr/bin/env python3
      """
      AI Error Helper Kitten
      Diagnoses errors and suggests fixes
      Keybinding: ctrl+shift+f
      """

      import sys
      import os
      import subprocess

      def main():
          # Clear screen and show prominent overlay indicator
          print("\033[2J\033[H", end="")

          print("\033[48;5;53m" + " " * 70 + "\033[0m")
          print("\033[48;5;53m\033[1;97m" + "  🪟  OVERLAY WINDOW - Press Enter when done to return to terminal  " + "\033[0m")
          print("\033[48;5;53m" + " " * 70 + "\033[0m")
          print()

          print("\n╔══════════════════════════════════════════════════════════╗")
          print("║              AI Error Helper & Debugger                  ║")
          print("╚══════════════════════════════════════════════════════════╝\n")

          # Try to get error from clipboard first
          error_text = ""
          try:
              try:
                  error_text = subprocess.run(
                      ['wl-paste'],
                      capture_output=True,
                      text=True,
                      timeout=1
                  ).stdout.strip()
              except:
                  try:
                      error_text = subprocess.run(
                          ['xclip', '-selection', 'clipboard', '-o'],
                          capture_output=True,
                          text=True,
                          timeout=1
                      ).stdout.strip()
                  except:
                      error_text = ""
          except:
              error_text = ""

          # If clipboard has something that looks like an error (contains common error keywords), use it
          error_keywords = ['error', 'failed', 'exception', 'traceback', 'fatal', 'warning', 'not found', 'permission denied', 'cannot']
          has_error_keywords = any(keyword in error_text.lower() for keyword in error_keywords)

          if error_text and has_error_keywords and len(error_text) < 3000:
              print("📋 Found error text in clipboard:\n")
              preview = error_text[:200] + "..." if len(error_text) > 200 else error_text
              print(f"  {preview}\n")
              print("Use this error? [Y/n]: ", end="", flush=True)
              try:
                  choice = input().strip().lower()
                  if choice and choice != 'y' and choice != 'yes' and choice != ''':
                      error_text = ""
              except:
                  pass
          else:
              error_text = ""

          if not error_text:
              print("Paste your error message or command output below.")
              print("(Paste and press Ctrl+D when done, or Ctrl+C to cancel)\n")
              print("→ ", end="", flush=True)

              try:
                  lines = []
                  while True:
                      try:
                          line = input()
                          lines.append(line)
                      except EOFError:
                          break
                  error_text = '\n'.join(lines)
              except KeyboardInterrupt:
                  print("\nCancelled.")
                  return

          if not error_text or not error_text.strip():
              print("Error: No error text provided")
              print("\n\033[48;5;53m" + " " * 70 + "\033[0m")
              print("\033[48;5;53m\033[1;97m" + "  🪟  OVERLAY - Press Enter to close and return to terminal     " + "\033[0m")
              print("\033[48;5;53m" + " " * 70 + "\033[0m")
              try:
                  input()
              except:
                  pass
              return

          # Get current directory for context
          try:
              cwd = os.getcwd()
          except:
              cwd = "~"

          # Check for API key - try multiple sources
          api_key = os.environ.get('ANTHROPIC_API_KEY')

          if not api_key:
              # Try sops-managed secret (preferred method)
              sops_secret = '/run/secrets/anthropic_api_key'
              if os.path.exists(sops_secret):
                  try:
                      with open(sops_secret, 'r') as f:
                          api_key = f.read().strip()
                  except:
                      pass

          if not api_key:
              # Fallback: Try to load from old secrets.env file
              secrets_file = os.path.expanduser('~/.config/secrets.env')
              if os.path.exists(secrets_file):
                  try:
                      with open(secrets_file, 'r') as f:
                          for line in f:
                              line = line.strip()
                              if line.startswith('export ANTHROPIC_API_KEY='):
                                  api_key = line.split('=', 1)[1].strip().strip('"').strip("'")
                                  break
                              elif line.startswith('ANTHROPIC_API_KEY='):
                                  api_key = line.split('=', 1)[1].strip().strip('"').strip("'")
                                  break
                  except:
                      pass

          if not api_key:
              print("\n❌ Error: ANTHROPIC_API_KEY not set!")
              print("Edit ~/.config/secrets.env to add your API key")
              print("\n\033[48;5;53m" + " " * 70 + "\033[0m")
              print("\033[48;5;53m\033[1;97m" + "  🪟  OVERLAY - Press Enter to close and return to terminal     " + "\033[0m")
              print("\033[48;5;53m" + " " * 70 + "\033[0m")
              try:
                  input()
              except:
                  pass
              return

          try:
              from anthropic import Anthropic

              print("\n🤔 Analyzing error... Asking Claude for help...\n", flush=True)

              client = Anthropic(api_key=api_key)

              prompt = f"""Analyze this error/output and help debug it:

      Current directory: {cwd}

      Error output:
      ```
      {error_text}
      ```

      Please provide:
      1. What the error means (explain in simple terms)
      2. The likely root cause
      3. Step-by-step fix suggestions
      4. Any relevant commands to try

      Be concise but thorough."""

              response = client.messages.create(
                  model="claude-haiku-4-5-20251001",
                  max_tokens=1024,
                  messages=[{"role": "user", "content": prompt}]
              )

              diagnosis = response.content[0].text

              print("╔══════════════════════════════════════════════════════════════════╗")
              print("║                    Error Analysis & Fix                          ║")
              print("╚══════════════════════════════════════════════════════════════════╝\n")
              print(diagnosis)

              print("\n\033[48;5;53m" + " " * 70 + "\033[0m")
              print("\033[48;5;53m\033[1;97m" + "  🪟  OVERLAY - Press Enter to close and return to terminal     " + "\033[0m")
              print("\033[48;5;53m" + " " * 70 + "\033[0m")

              try:
                  input()
              except:
                  pass

          except ImportError:
              print("\n❌ Error: anthropic package not found")
              print("Try: home-manager switch --flake .#sheva@nixsimos")
              print("\n\033[48;5;53m" + " " * 70 + "\033[0m")
              print("\033[48;5;53m\033[1;97m" + "  🪟  OVERLAY - Press Enter to close and return to terminal     " + "\033[0m")
              print("\033[48;5;53m" + " " * 70 + "\033[0m")
              try:
                  input()
              except:
                  pass

          except Exception as e:
              print(f"\n❌ Error: {str(e)}")
              print("\n\033[48;5;53m" + " " * 70 + "\033[0m")
              print("\033[48;5;53m\033[1;97m" + "  🪟  OVERLAY - Press Enter to close and return to terminal     " + "\033[0m")
              print("\033[48;5;53m" + " " * 70 + "\033[0m")
              try:
                  input()
              except:
                  pass

      if __name__ == '__main__':
          main()
    '';
  };
}
