{
  services.tailscale = {
    enable = false;
    # optional flags:
    extraUpFlags = [
        "--accept-routes"
    ];
  };
  
  # Optional: Open the firewall for Tailscale
  networking.firewall = {
    # Allow Tailscale traffic
    trustedInterfaces = [ "tailscale0" ];
    # Allow incoming connections on Tailscale interface
    allowedUDPPorts = [ 41641 ]; # Tailscale port
  };
  
  # Optional: Enable systemd-resolved for MagicDNS
  services.resolved.enable = true;
}