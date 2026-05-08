{ pkgs, ... }:

{
  sops.secrets.uptime_push_token = {
    sopsFile = ../../secrets/hosts/kaleipo/monitoring.yaml;
  };

  systemd.services.glances = {
    description = "Glances system monitor API";
    after = [ "network.target" "tailscaled.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.glances}/bin/glances -w --port 61208";
      Restart = "on-failure";
      RestartSec = "5s";
    };
  };

  # Allow Glances only from the Tailscale network
  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ 61208 ];

  systemd.services.uptime-heartbeat = {
    description = "Uptime Kuma heartbeat";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "uptime-heartbeat" ''
        token=$(cat /run/secrets/uptime_push_token)
        exec ${pkgs.curl}/bin/curl -fsS --max-time 10 \
          "https://uptime.xamal.eu/api/push/$token?status=up&msg=OK&ping="
      '';
    };
  };

  systemd.timers.uptime-heartbeat = {
    description = "Uptime Kuma heartbeat timer";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "2min";
      OnUnitActiveSec = "30s";
      AccuracySec = "1s";
    };
  };
}
