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

    # dms-shell: make the DankMaterialShell bar work under Hyprland's Lua config
    # backend (wayland.windowManager.hyprland.configType = "lua").
    #
    # DMS switches workspaces via Quickshell's Hyprland singleton, which sends
    # `dispatch <string>` over the Hyprland IPC socket. Under the Lua backend that
    # message is evaluated as Lua (`return hl.dispatch(<string>)`), so the classic
    # `workspace N` / `focuswindow address:X` forms are a syntax error and the
    # click/scroll silently do nothing. There is NO string-dispatch compat shim
    # (verified: `hl.dispatch("workspace N")` errors "expected a dispatcher"), so
    # every call site must be hand-translated to its `hl.dsp.*` form. See
    # project_hyprland_lua_backend memory.
    #
    # Translations verified empirically over the socket on Hyprland 0.55.4:
    #   workspace N               -> hl.dsp.focus({workspace=N})
    #   focuswindow address:X     -> hl.dsp.focus({window="address:X"})
    # NOTE: --replace-fail means a DMS version bump that touches these lines fails
    # the build loudly — that's the intended signal to re-check the translations.
    # Not yet translated (not part of the bar; left as-is, still no-ops under Lua):
    # OverviewWidget movetoworkspacesilent/closewindow, SessionService exit,
    # CompositorService dpms on/off.
    (final: prev: {
      dms-shell = prev.dms-shell.overrideAttrs (old: {
        postInstall = (old.postInstall or "") + ''
          qml=$out/share/quickshell/dms

          # Workspace switch — bar click + scroll (the visible breakage)
          substituteInPlace $qml/Modules/DankBar/DankBarContent.qml \
            --replace-fail '`workspace ''${realWorkspaces[nextIndex].id}`' \
                           '`hl.dsp.focus({workspace=''${realWorkspaces[nextIndex].id}})`'

          substituteInPlace $qml/Modules/DankBar/Widgets/WorkspaceSwitcher.qml \
            --replace-fail '`workspace ''${data.id}`' \
                           '`hl.dsp.focus({workspace=''${data.id}})`' \
            --replace-fail '`workspace ''${realWorkspaces[nextIndex].id}`' \
                           '`hl.dsp.focus({workspace=''${realWorkspaces[nextIndex].id}})`' \
            --replace-fail '`workspace ''${modelData.id}`' \
                           '`hl.dsp.focus({workspace=''${modelData.id}})`' \
            --replace-fail '`focuswindow address:''${winId}`' \
                           '`hl.dsp.focus({window="address:''${winId}"})`'

          # Overview grid (super+overview) — workspace click + app-icon focus
          substituteInPlace $qml/Modules/WorkspaceOverlays/OverviewWidget.qml \
            --replace-fail '`workspace ''${workspaceValue}`' \
                           '`hl.dsp.focus({workspace=''${workspaceValue}})`' \
            --replace-fail '`focuswindow address:''${windowData.address}`' \
                           '`hl.dsp.focus({window="address:''${windowData.address}"})`'

          substituteInPlace $qml/Modules/WorkspaceOverlays/HyprlandOverview.qml \
            --replace-fail '"workspace " + targetId' \
                           '`hl.dsp.focus({workspace=''${targetId}})`'
        '';
      });
    })
  ];
}
