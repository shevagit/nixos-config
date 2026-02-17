.PHONY: all build switch diff update upgrade gc deep-gc nuke-gc home-build home-switch check

HOSTNAME := $(shell hostname)

# Default target: upgrade the system
all: upgrade

# Validate flake configuration
check:
	nix flake check

# Build the system without applying it
build:
	nixos-rebuild build --flake ./#$(HOSTNAME)

# Apply the system configuration
switch:
	sudo nixos-rebuild switch --flake ./#$(HOSTNAME)

# Build only home-manager configuration
home-build:
	nix build .#homeConfigurations-$(HOSTNAME)

# Apply only home-manager configuration
home-switch: home-build
	./result/activate

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
	nix-env --delete-generations +3
	sudo nix-env --delete-generations +3 --profile /nix/var/nix/profiles/system
	nix-collect-garbage

nuke-gc:
	sudo nix-collect-garbage -d

# List all available system profiles
list-generations:
	sudo nix-env --list-generations --profile /nix/var/nix/profiles/system
