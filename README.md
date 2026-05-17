# celestia-steam

Build orchestration and Steam-specific patches for shipping Celestia on Steam.

This repository is a build orchestrator. It pins upstream
[Celestia](https://github.com/CelestiaProject/Celestia) and
[CelestiaContent](https://github.com/CelestiaProject/CelestiaContent) at
known-good commits via submodules, applies the patches in `patches/`, builds
the Windows x64 binary, and uploads the result via SteamPipe. Windows is the
only target platform.

## Layout

```
patches/                 quilt-style patches against upstream Celestia
steampipe/               SteamPipe app/depot configuration (.vdf)
scripts/                 helper scripts (patch application, build, upload)
celestia/                submodule — upstream CelestiaProject/Celestia
content/                 submodule — upstream CelestiaProject/CelestiaContent
steamworks_sdk/          submodule — community mirror of the Steamworks SDK
.github/workflows/       build + upload pipeline
```

## Upstream pinning

`celestia/` and `content/` are submodules pinned to specific commits of the
upstream repos. Bumping upstream is a deliberate operation:

```sh
git submodule update --remote celestia content
# re-test the patches against the new commits
git commit -am "Bump upstream celestia/content"
```

Pinning matters because the patches in `patches/` target specific upstream
files — a silent upstream refactor can desync them without breaking the
patch-apply step.

## Steamworks SDK

The SDK is included as a git submodule pointing at the community mirror
[rlabrecque/SteamworksSDK](https://github.com/rlabrecque/SteamworksSDK).
Clone this repo with `--recursive` (or run `git submodule update --init` after
cloning) to fetch it. Bumping the SDK version is a normal git operation —
update the submodule pointer and commit.

The mirror is widely used by open-source Steam projects but is not an
official Valve distribution; users of this build pipeline remain bound by
Valve's
[Steamworks SDK Access Agreement](https://partner.steamgames.com/documentation/sdk_access_agreement)
regardless of the source. To use a partner-site download instead, deinit the
submodule and drop the unpacked SDK into `steamworks_sdk/`.

## Patches

Patches are kept minimal — Celestia upstream is intentionally not modified for
Steam concerns. Each patch in `patches/` is numbered and applied in order via
`scripts/apply-patches.sh`.

Current patches:

- `0001-integrate-steamworks-sdk-in-qt6-build.patch` — adds the
  `ENABLE_STEAM` CMake option, a `FindSteamworks.cmake` module, and wires
  the SDK (headers, import library, runtime DLL install) into the qt6
  target.
- `0002-init-steamsdk-and-append-workshop-extras-dirs.patch` — adds
  `src/celestia/qt/steamintegration.{cpp,h}` which initialises the
  Steamworks SDK at startup and enumerates the user's subscribed Workshop
  items. Each Workshop item is expected to contain a single top-level
  UUID-named directory; those directories are appended to the
  `extrasDirectories` list passed to `CelestiaCore::initSimulation`,
  ordered by UUID ascending for deterministic load order.

## SteamPipe

The Steam App ID is configured in `steampipe/app_build.vdf`. Until the app is
created in the Steamworks partner dashboard, the placeholder `APPID_PLACEHOLDER`
is used and CI's upload step is disabled.

Depot IDs are placeholders likewise.

## Building locally

```sh
git clone --recursive https://github.com/celestiamobile/celestia-steam.git
cd celestia-steam
scripts/apply-patches.sh         # applies patches/*.patch to celestia/
cmake -B build -S celestia -DENABLE_STEAM=ON \
    -DSTEAMWORKS_SDK_ROOT=../steamworks_sdk
cmake --build build
```

## License

Patches in `patches/` are derivative of GPL-2.0-or-later Celestia source and
inherit that license. Build scripts, SteamPipe configuration, and CI workflows
in this repository are MIT-licensed unless noted otherwise.
