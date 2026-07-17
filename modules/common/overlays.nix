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

    # mongodb-compass: broken on nixpkgs since e858e80fb1 ("wrapGAppsHook: only
    # wrap $outBin by default", 2026-06-15). The hook now guards with
    # wrapGAppsHookHasRunForOutput["$output"], but mongodb-compass calls
    # wrapGAppsHook manually inside buildCommand where $output is unset ->
    # "bad array subscript" kills the build. prefix and outputBin are already
    # "out" at that point, so defining output=out restores the old behavior.
    # Remove once upstream fixes the package (the assert fails loudly when the
    # manual wrapGAppsHook call disappears from buildCommand).
    (final: prev: {
      mongodb-compass = prev.mongodb-compass.overrideAttrs (old: {
        buildCommand =
          assert prev.lib.hasInfix "wrapGAppsHook $out/bin/mongodb-compass" old.buildCommand;
          "output=out\n" + old.buildCommand;
      });
    })
  ];
}
