{ 
  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true;
    liveRestore = false;
    daemon.settings = {
      "min-api-version" = "1.24";
      };
  };

  users.users.sheva.extraGroups = ["docker"];
}