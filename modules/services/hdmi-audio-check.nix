{ pkgs, ... }:

{
  systemd.services.hdmi-audio-check = {
    description = "HDMI audio silence detection and recovery";
    after = [ "docker.service" ];
    requires = [ "docker.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "/opt/hdmi-stream/audio-health-check.sh";
      TimeoutStartSec = 300;
    };
    path = [ pkgs.docker pkgs.bash pkgs.gnugrep pkgs.coreutils ];
  };

  systemd.timers.hdmi-audio-check = {
    description = "Run HDMI audio health check after boot";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "60";
      AccuracySec = "10";
    };
  };
}
