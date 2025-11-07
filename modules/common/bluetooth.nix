{ pkgs, ... }:

{
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  environment.systemPackages = with pkgs; [
    linux-firmware # Includes Intel firmware but still doesn't work on 6.6.72
  ];
}
