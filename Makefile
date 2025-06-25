.PHONY: all build switch diff update upgrade gc

HOSTNAME := $(shell hostname)

# Default target: upgrade the system
all: upgrade

# Build the system without applying it
build:
	nixos-rebuild build --flake ./#$(HOSTNAME)

# Apply the system configuration
switch:
	sudo nixos-rebuild switch --flake ./#$(HOSTNAME)

# Apply the system configuration on the next boot
boot:
	sudo nixos-rebuild boot --flake ./#$(HOSTNAME)

# Show differences between the current and built system
diff:
	nvd diff /run/current-system result

# Update flake inputs
update:
	nix flake update

# Update and apply system changes
upgrade: update switch

# Collect garbage to free disk space
gc:
	nix-collect-garbage -d

deep-gc:
	sudo nix-collect-garbage -d

# List all available system profiles
list-generations:
	sudo nix-env --list-generations --profile /nix/var/nix/profiles/system
