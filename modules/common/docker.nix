{ 
  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true;
    liveRestore = false;
  };

  users.users.sheva.extraGroups = ["docker"];
}