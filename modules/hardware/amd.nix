{ config, pkgs, ... }:

{
    hardware = {
        enableRedistributableFirmware = true;
    };

    services.xserver.videoDrivers = [ "amdgpu" ];
}