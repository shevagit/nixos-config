{
  # Shokz Loop120 USB dongle (3511:2f06) HID interface sends a
  # sleep/power key event during pairing, causing a system shutdown.
  # Disabling the HID driver on the dongle keeps audio functional.
  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ATTR{bInterfaceClass}=="03", ATTRS{idVendor}=="3511", ATTRS{idProduct}=="2f06", ATTR{authorized}="0"
  '';
}
