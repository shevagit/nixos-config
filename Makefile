.PHONY: all build switch diff update upgrade gc

# Default target: upgrade the system
all: upgrade

# Build the system without applying it
build:
	nixos-rebuild build --flake .#

# Apply the system configuration
switch:
	nixos-rebuild switch --flake .#

# Show differences between the current and built system
diff:
	nvd diff /run/current-system /nix/var/nix/profiles/system

# Update flake inputs
update:
	nix flake update

# Update and apply system changes
upgrade: update switch

# Collect garbage to free disk space
gc:
	nix-collect-garbage -d
