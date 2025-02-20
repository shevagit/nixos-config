{
  networking.extraHosts = ''

    # lw devsetup hosts
    127.0.0.1 api.learnworlds.develop
    127.0.0.1 apitasks-scheduler.learnworlds.develop
    127.0.0.1 account.learnworlds.develop
    127.0.0.1 adminer.learnworlds.develop
    127.0.0.1 analytics.learnworlds.develop
    127.0.0.1 assets.learnworlds.develop
    127.0.0.1 aurora.learnworlds.develop
    127.0.0.1 client.learnworlds.develop
    127.0.0.1 client-canary.learnworlds.develop
    127.0.0.1 companion.learnworlds.develop
    127.0.0.1 kafka-ui.learnworlds.develop
    127.0.0.1 profiler.learnworlds.develop
    127.0.0.1 string-is.learnworlds.develop
    127.0.0.1 www.learnworlds.develop
    127.0.0.1 urlshortener.learnworlds.develop

    # local dev hosts
    127.0.0.1 pitstudentportal.learnworlds.develop
    127.0.0.1 testex-academy.learnworlds.develop
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