{ config, pkgs, ... }:

{
  imports = [
    ../../modules/hardware/nvidia.nix # Import NVIDIA config
  ];

  # Host-specific settings
  networking.hostName = "simos";
}
