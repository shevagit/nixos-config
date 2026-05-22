{ ... }: {
  services.howdy = {
    enable = true;
    # "sufficient": face-unlock alone is enough; falls back to password on failure.
    # Default "required" would force face *and* password for every PAM service.
    control = "sufficient";
  };

  # The T14s G6's IR camera (Luxvisions 30c9:00cd) needs an explicit USB
  # control packet at boot to turn on its IR LED illuminator. Without this,
  # the IR sensor sees almost no light under LED room lighting and howdy
  # captures dark frames. After first activation, run on the host:
  #   sudo linux-enable-ir-emitter configure
  # to discover the right packet for this camera; subsequent boots replay it.
  services.linux-enable-ir-emitter.enable = true;
}
