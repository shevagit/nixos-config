{ pkgs, lib, ... }:
{
  # 1) Enable the U2F PAM module system-wide
  security.pam.u2f = {
    enable = true;
    control = "sufficient"; 
    settings = {
        cue = true;
    };
  };

  # 2) Turn on U2F auth only for sudo (not for login, su, etc.)
  security.pam.services.sudo.u2fAuth = true;
}

## Run the command to generate the keys file on every machine requiring yubikey auth

# mkdir -p ~/.config/Yubico
#pamu2fcfg -o pam://$HOSTNAME -i pam://$HOSTNAME > ~/.config/Yubico/u2f_keys
