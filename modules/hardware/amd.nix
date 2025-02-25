{ config, pkgs, ... }:

{
    hardware = {
        enableRedistributableFirmware = true;
        amdgpupro = {
            enable = true;
            extraPackages = with pkgs; [
                rocm-opencl-runtime
                rocm-smi
            ];
        };
    };

    services.xserver.videoDrivers = [ "amdgpu" ];
}