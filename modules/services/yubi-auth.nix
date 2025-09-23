{ pkgs, lib, ... }:
{
  # 1) Enable the U2F PAM module system-wide
  security.pam.u2f = {
    enable = true;
    cue = true;          # shows "Please touch the device"
    control = "sufficient"; 
    # "sufficient" = either YubiKey OR password works (safer while testing).
    # Later, switch to "required" to make the key mandatory.
  };

  # 2) Turn on U2F auth only for sudo (not for login, su, etc.)
  security.pam.services.sudo.u2fAuth = true;
}
