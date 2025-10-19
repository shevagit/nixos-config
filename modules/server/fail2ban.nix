{ config, pkgs, lib, ... }:

{
  services.fail2ban = {
    enable = true;
    maxretry = 3;
    bantime = "3600"; # 1 hour
    bantime-increment = {
      enable = true;
      multipliers = "1 2 4 8 16 32 64";
      maxtime = "48h";
      overalljails = true;
    };

    # Ignore trusted IPs
    ignoreIP = [
      "127.0.0.0/8"
      "::1"
      "xxxx"  # Your trusted IP
    ];

    jails = {
      # SSH protection
      sshd = {
        enabled = true;
        filter = "sshd";
        maxretry = 3;
      };

      # Nginx HTTP Auth
      nginx-http-auth = {
        enabled = true;
        filter = "nginx-http-auth";
        logpath = "/var/log/nginx/error.log";
        maxretry = 2;
      };

      # Additional nginx protections
      nginx-botsearch = {
        enabled = true;
        filter = "nginx-botsearch";
        logpath = "/var/log/nginx/access.log";
      };

      nginx-limit-req = {
        enabled = true;
        filter = "nginx-limit-req";
        logpath = "/var/log/nginx/error.log";
      };
    };
  };

  # Create custom nginx-http-auth filter
  # This matches 401, 403, 404, and 444 status codes
  environment.etc."fail2ban/filter.d/nginx-http-auth-custom.conf".text = ''
    [Definition]
    failregex = ^<HOST> -.*"(GET|POST|HEAD).*HTTP.*" (401|403|404|444) .*$
    ignoreregex =
  '';
}
