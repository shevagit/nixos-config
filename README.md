# nixos-config
NixOS files for multi-setup

flake.nix: Defines your flake's inputs and outputs. It references hosts/<hostname> for specific machines.

hosts/<hostname>:
Each machine has its own directory with configuration.nix and hardware-configuration.nix.
Host-specific modules are placed under modules/ inside the host's directory.

modules/:
Shared configurations are organized into categories (common, hardware, services).

For example, nvidia.nix under hardware/ can contain your NVIDIA driver setup and be imported by any machine requiring it.

not: when enabling extensions/hyprland the cursor theme is changed, reset with:

```
dconf reset /org/gnome/desktop/interface/cursor-theme
```
