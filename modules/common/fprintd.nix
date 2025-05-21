{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    fprintd
  ];

  services.fprintd = {
    enable = true;
  };

  services.fprintd.tod = {
    enable = true;
  };

  security.pam.services.login.fprintAuth = false;
}