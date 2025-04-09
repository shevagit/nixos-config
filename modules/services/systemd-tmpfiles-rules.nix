{
  systemd.tmpfiles.rules = [
    "q /tmp 1777 root root 5d"
    "q /var/tmp 1777 root root 30d"
  ];
}
