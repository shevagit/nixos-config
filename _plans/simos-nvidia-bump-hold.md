# simos — graphics PIN RETIRED, back on unpinned upstream (history below)

**Status:** PIN RETIRED as of 2026-09-18. simos now runs the unpinned upstream graphics stack
again — **kernel 7.2.6 / nvidia 595.99.02 / mesa 26.2.2** — switched, rebooted, and
login-confirmed with no login loop and a clean kernel log (no Xid / GP-fault this boot). The
`nixpkgs-simos-gfx` input and all `gfxPkgs` plumbing are removed; simos is on the shared lock
like every other host.
**Host affected:** simos only (NVIDIA RTX 4070). nontas is AMD and was never affected.

## Pin retired (2026-09-18)

`nix eval` of the unpinned path showed nvidia had advanced to **595.99.02** (8 patch releases
past the bad `595.91.07`, and past the last-good `595.84`), clearing the decision rule's
"nvidia > 595.84" bar. Reverted the 2026-09-02 pin:
- `flake.nix`: removed the `nixpkgs-simos-gfx` input, its arg, the `gfxPkgs` let-binding and the
  `nixosSpecialArgs`.
- `hosts/simos/hardware-configuration.nix`: `boot.kernelPackages` back to `pkgs.linuxPackages_latest`;
  dropped the `gfxPkgs` module arg and the pin comment.
- `nix flake lock` removed only `nixpkgs-simos-gfx`; no other input touched.
- `nixos-rebuild build` clean; user did the switch + reboot; login confirmed.

**Why it works now — best-effort, NOT definitively pinned to a documented fix.** Both variables
moved together (nvidia `595.91.07 → 595.99.02`, kernel `7.2 → 7.2.6`). `595.99.02` is a
bugfix-only release, but its *published* fixes don't cleanly match our failure:
- "Linux 7.0+ compat where DRM fbdev support is **disabled**" → not us; simos has
  `CONFIG_DRM_FBDEV_EMULATION=y` (enabled).
- Blackwell output-scaling corruption → not us (RTX 4070 is Ada, not Blackwell).
- TTY/console black screen, resume-from-hibernation → don't match a compositor-startup GP-fault
  at login.

Our original 2026-08 diagnosis was by **closure-diff elimination**, not a captured Xid / bug ID
(the coredump was `.Hyprland-wrapped`, a *symptom*). Without that fingerprint we can't map it to
a changelog line. Most plausible: a driver-side regression in the `595.9x` line, quietly ironed
out by `595.99.02` (possibly with a kernel `7.2.x` assist). Exact upstream commit UNCONFIRMED.
Refs: linuxiac.com/nvidia-595-99-linux-driver-improves-linux-7-0-compatibility,
gamingonlinux 2026/08 595.99.02 release, linuxcompatible.org 595.99.02 story.

**If a login loop ever returns after a future bump:** re-pin via the Option A recipe preserved
below (git history has the exact diff at the 2026-09-18 retirement commit's parent).

## History — the pin (2026-09-02 → 2026-09-18)

Took **Option A**: an additive flake input pinned to the last known-good nixpkgs rev, sourcing
only simos's kernel from it (nvidia followed automatically). Ran clean on kernel 7.1.5 /
nvidia 595.84 for ~2 weeks until upstream advanced and the pin was retired (above).

## What was done (2026-09-02)

Took **Option A**. Added an additive flake input pinned to the last known-good nixpkgs rev
and sourced only simos's kernel from it; nvidia follows automatically:

**Re-pin recipe (if a future bump login-loops simos again):**
- `flake.nix`: add `nixpkgs-simos-gfx.url = "github:nixos/nixpkgs/<last-known-good-rev>"`,
  import with `allowUnfree`, pass to simos as the `gfxPkgs` nixosSpecialArg.
- `hosts/simos/hardware-configuration.nix`: take the `gfxPkgs` module arg and set
  `boot.kernelPackages = gfxPkgs.linuxPackages_latest;`. Because `hardware.nvidia.package =
  config.boot.kernelPackages.nvidiaPackages.stable` (modules/hardware/nvidia.nix, unchanged),
  pinning the kernel pins the driver too.
- The pin is purely additive — main `nixpkgs-unstable` stays put, so AMD hosts are unaffected.
  Mesa was left floating on purpose (never the fingered culprit; pinning it across two nixpkgs
  risks GL/libglvnd skew). Pin mesa from `gfxPkgs` too only if a future loop implicates it.
- Exact diff is in git history at the 2026-09-18 retirement commit's parent (the pin was live
  2026-09-02 → 2026-09-18, known-good rev `624af665418d3c65d544145b4d34ad696439570e`).

## Original problem (kept for history)

The committed `flake.lock` (commit `a847d2d`, "update(flake): 260826") drags simos's
graphics stack to the **exact versions that login-looped simos on 2026-08-21** (nvidia
595.91.07 / kernel 7.2). The pin above is what lets simos take that lock safely.

## The version comparison (checked 2026-08-28)

| Component | Current flake.lock (`a847d2d` / 260826) | Known-BAD (login loop 2026-08-21) | Known-GOOD (running now) |
|-----------|------------------------------------------|-----------------------------------|--------------------------|
| nvidia    | `595.91.07`  ⚠️ identical to bad          | `595.91.07`                       | `595.84`                 |
| kernel    | `7.2`        ⚠️ identical to bad          | `7.2`                             | `7.1.5`                  |
| mesa      | `26.2.1`                                 | `26.2.0`                          | `26.1.5`                 |

- nixpkgs-unstable in the current lock: `56c02bc00adc`
- Running system generation: `nixos-system-simos-26.11.20260726.624af66`

The nvidia driver is the **identical version** (`595.91.07`) that caused the loop, on the
identical kernel (`7.2`). Only mesa moved (`26.2.0 → 26.2.1`). Nothing in this closure moved
the nvidia driver forward, so there is no reason to expect the loop is fixed. nontas built the
same bump cleanly because it is AMD — this is purely an nvidia-driver-vs-RTX-4070 problem.

## Why a build alone won't tell us anything

- `nixos-rebuild build` (no activation) is safe but does **not** reproduce the loop — the loop
  only appears on `switch` + reboot, when SDDM and the nvidia kernel module actually come up.
- The version match already predicts the outcome: switching would very likely reproduce the
  same login loop.

## How the versions get dragged forward

simos floats both, so a plain flake update silently pulls the driver + kernel forward:
- `boot.kernelPackages = pkgs.linuxPackages_latest`  — `hosts/simos/hardware-configuration.nix`
- `hardware.nvidia.package = ...nvidiaPackages.stable` — `modules/hardware/nvidia.nix`

## How to re-check when revisiting (in a few days)

From the repo root, evaluate what the *current* lock would install for simos — no build, no switch:

```sh
nix eval --raw '.#nixosConfigurations.simos.config.hardware.nvidia.package.version'
nix eval --raw '.#nixosConfigurations.simos.config.boot.kernelPackages.kernel.version'
nix eval --raw '.#nixosConfigurations.simos.config.hardware.graphics.package.version'
```

Decision rule:
- If **nvidia > 595.84** appears (a genuinely newer driver than the last-good one) → worth a
  careful attempt: `nixos-rebuild switch`, then smoke-test login (log out / reboot) **before**
  committing. Have a rollback ready (see below).
- If it still shows **595.91.07** → keep holding, or take the pin path (Option A below).

## Two ways off the hold

### Option A — pin nvidia + kernel to known-good, let the rest of nixpkgs move (recommended)
Pin the driver to `595.84` and kernel to the `7.1.5` series on simos so it can accept the
`260826` bump for everything *except* the graphics stack. This unfreezes simos from Jul 26
without risking the loop. (Not yet implemented — do this when we come back if the driver
hasn't advanced.)

### Option B — wait for a newer nvidia driver
Just keep re-running the `nix eval` checks above every few days until nvidia advances past
`595.84`, then attempt a normal switch with login smoke-test before commit.

## If a switch is attempted and it login-loops again — rollback

Per `recovery_flake_pin_rollback.md` (prior art commit `dfb78a2`):

```sh
# roll flake.lock back to the last-good flake update commit, then rebuild
git checkout f0b9f46 -- flake.lock   # 270726 lock = nixpkgs-unstable 624af66
sudo nixos-rebuild switch --flake .#simos
```

Or at the boot menu, select the previous known-good generation
(`...20260726.624af66`) to get back in immediately.

## Diagnosis method worth reusing

When a rebuild login-loops, compare system-closure package versions across generations to find
the real delta:

```sh
nix-store -qR $(readlink -f /nix/var/nix/profiles/system-<N>-link) \
  | sed 's#.*/[a-z0-9]*-##' | sort -u
```

Diff good vs bad generation, filtered to `nvidia|mesa|linux-|aquamarine|hyprland|wayland|libglvnd|egl`.
`coredumpctl list` shows which binary segfaulted — note it misled us toward hyprland last time
(the `.Hyprland-wrapped` crash was a *symptom* of the GP-fault, not the cause).
