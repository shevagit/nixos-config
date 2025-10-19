{ config, pkgs, lib, ... }:

{
  services.nginx = {
    enable = true;

    recommendedGzipSettings = true;
    recommendedOptimisationSettings = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    # Additional nginx settings
    appendHttpConfig = ''
      # Rate limiting (from your config: limit_req_zone $binary_remote_addr zone=mylimit:10m rate=20r/s)
      limit_req_zone $binary_remote_addr zone=mylimit:10m rate=20r/s;

      # SSL protocols (matching your config)
      ssl_protocols TLSv1.2 TLSv1.3;
      ssl_prefer_server_ciphers on;
    '';

    # Virtual hosts will be configured per-deployment
    # Example commented out - customize for your needs:
    # virtualHosts."example.domain.eu" = {
    #   enableACME = true;
    #   forceSSL = true;
    #   locations."/" = {
    #     proxyPass = "http://localhost:8080";
    #     extraConfig = ''
    #       limit_req zone=mylimit burst=10 nodelay;
    #     '';
    #   };
    # };
  };

  # Open firewall for HTTP/HTTPS
  networking.firewall.allowedTCPPorts = [ 80 443 ];
}
