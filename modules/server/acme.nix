{ config, pkgs, lib, ... }:

{
  # ACME/Let's Encrypt configuration for SSL certificates
  # Note: NixOS has built-in ACME support via security.acme

  security.acme = {
    acceptTerms = true;
    defaults = {
      email = "admin@domain.eu";  # Change this to your email
      # Use Let's Encrypt by default (NixOS doesn't have native ZeroSSL support)
      # server = "https://acme-v02.api.letsencrypt.org/directory"; # Production
      # server = "https://acme-staging-v02.api.letsencrypt.org/directory"; # Staging for testing
    };
  };

  # Wildcard certificates require DNS challenge
  # For Cloudflare DNS:
  # security.acme.certs."domain.eu" = {
  #   domain = "*.domain.eu";
  #   extraDomainNames = [ "domain.eu" ];
  #   dnsProvider = "cloudflare";
  #   environmentFile = "/run/secrets/cloudflare-api"; # Contains CF_API_KEY and CF_EMAIL
  #   group = "nginx";
  # };

}
