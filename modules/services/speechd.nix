{ config, lib, ... }:

{
  services.speechd.enable = lib.mkForce false;
  services.orca.enable = lib.mkForce false;
}
