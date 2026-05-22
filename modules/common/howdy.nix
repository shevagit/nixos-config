{ ... }: {
  services.howdy = {
    enable = true;
    # "sufficient": face-unlock alone is enough; falls back to password on failure.
    # Default "required" would force face *and* password for every PAM service.
    control = "sufficient";
  };
}
