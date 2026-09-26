# Shared nixpkgs overlays.
{ ... }:
{
  nixpkgs.overlays = [
    # SDDM login theme preset. Which of the presets bundled with
    # sddm-astronaut is used is decided by the ConfigFile= line in the theme's
    # metadata.desktop, and the package takes that as an `embeddedTheme`
    # argument.
    # Available: astronaut, black_hole, cyberpunk, japanese_aesthetic,
    # pixel_sakura_static, post-apocalyptic_hacker, purple_leaves,
    # pixel_sakura (animated gif), jake_the_dog (animated mp4),
    # hyprland_kath (animated mp4).
    #
    # This lives in an overlay rather than in the SDDM module because there are
    # two consumers: modules/common/display-manager.nix installs it as the
    # login theme, and home/common/hyprland.nix reads a background image out of
    # the same package for hyprlock. Pointing both at one derivation keeps a
    # single ~22M copy in the closure; when they referred to separate
    # derivations, both were pulled in.
    # Home-manager sees this because useGlobalPkgs = true. Safe to assume the
    # attribute exists in both places: the three hosts importing this module
    # (nontas, simos, athanasiou) are exactly the three importing home/common.
    (final: prev: {
      sddm-astronaut-themed = prev.sddm-astronaut.override {
        embeddedTheme = "purple_leaves";
      };
    })

    # sops-nix builds its sops-install-secrets with `buildGo125Module`, which
    # nixpkgs-unstable removed when Go 1.25 went end-of-life. The attribute
    # still exists but throws on evaluation, which breaks the unstable hosts
    # at `sops.package` (and `sops.validationPackage`, same default).
    # kaleipo is unaffected: it builds from nixpkgs-stable, which still has a
    # working buildGo125Module and no buildGo126Module — which is also why this
    # lives here, in a module kaleipo does not import, rather than in a shared
    # one.
    # sops-nix upstream HEAD (13616ff, 2026-09-09) has not caught up yet, so
    # there is no input bump that fixes this.
    # go.mod declares `go 1.25.0` as a *minimum*, so the default builder is
    # fine: pkgs.go is 1.26.7, and buildGoModule uses that same Go, which keeps
    # the package's separate `go` argument consistent with the builder.
    # Remove once sops-nix moves off buildGo125Module.
    (final: prev: {
      buildGo125Module = prev.buildGoModule;
    })

    # google-cloud-sdk: its extra components (e.g. gke-gcloud-auth-plugin) pull
    # in a `bundled-python3-unix` component built around a bundled CPython 3.14.
    # autoPatchelf fails on it because:
    #   - libpython3.14.so.1.0 is referenced via an $ORIGIN-relative RPATH that
    #     autoPatchelf can't resolve at build time (it's present at runtime), and
    #   - _tkinter wants libtcl9.0.so / libtcl9tk9.0.so, which gcloud never uses.
    # Tell autoPatchelf to ignore exactly these three so the component builds.
    # Remove once nixpkgs ships the fix upstream.
    (final: prev: {
      google-cloud-sdk =
        let
          patchedSrc = prev.runCommandLocal "google-cloud-sdk-src-patched" { } ''
            cp -r ${prev.path}/pkgs/by-name/go/google-cloud-sdk $out
            chmod -R +w $out
            substituteInPlace $out/components.nix \
              --replace-fail 'dontUnpack = true;' \
                'dontUnpack = true;
      autoPatchelfIgnoreMissingDeps = [ "libpython3.14.so.1.0" "libtcl9.0.so" "libtcl9tk9.0.so" ];'
          '';
        in
        prev.callPackage (patchedSrc + "/package.nix") { };
    })
  ];
}
