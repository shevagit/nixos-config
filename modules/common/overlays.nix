# Shared nixpkgs overlays.
{ ... }:
{
  nixpkgs.overlays = [
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
