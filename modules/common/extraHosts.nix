{
  networking.extraHosts = ''

    # add hosts

  '';

  services.dnsmasq = {
    enable = true;
    settings = {
      address = "/learnworlds.develop/127.0.0.1"; 
      listen-address = "127.0.0.1";
      bind-interfaces = true;
      server = [ "192.168.1.1" ];
    };
  };

  networking = {
    nameservers = [ "127.0.0.1" ];
  };
}