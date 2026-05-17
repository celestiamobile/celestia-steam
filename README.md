# celestia-steam

Build orchestration and Steam-specific patches for shipping Celestia on Steam.

This repository does not contain Celestia source code. It checks out upstream
[Celestia](https://github.com/CelestiaProject/Celestia) and
[CelestiaContent](https://github.com/CelestiaProject/CelestiaContent), applies
the patches in `patches/`, builds for each Steam-supported platform, and
uploads the result via SteamPipe.

## Layout

```
patches/                 quilt-style patches against upstream Celestia
steampipe/               SteamPipe app/depot configuration (.vdf)
scripts/                 helper scripts (patch application, build, upload)
steamworks_sdk/          (gitignored) place the SDK here locally; CI fetches it
.github/workflows/       build + upload pipeline
```

## Steamworks SDK

CI checks out the SDK from the community mirror
[rlabrecque/SteamworksSDK](https://github.com/rlabrecque/SteamworksSDK),
pinned by commit SHA. The mirror is widely used by open-source Steam projects
but is not an official Valve distribution; users of this build pipeline remain
bound by Valve's
[Steamworks SDK Access Agreement](https://partner.steamgames.com/documentation/sdk_access_agreement)
regardless of the source.

For local builds, either download the latest SDK from the
[Steamworks SDK downloads page](https://partner.steamgames.com/downloads/list)
(requires partner login) and extract into `steamworks_sdk/`, or clone the
mirror at the same path.

## Patches

Patches are kept minimal — Celestia upstream is intentionally not modified for
Steam concerns. Each patch in `patches/` is numbered and applied in order via
`scripts/apply-patches.sh`.

Current patches:

- *(none yet)*

## SteamPipe

The Steam App ID is configured in `steampipe/app_build.vdf`. Until the app is
created in the Steamworks partner dashboard, the placeholder `APPID_PLACEHOLDER`
is used and CI's upload step is disabled.

Depot IDs are placeholders likewise.

## Building locally

Follow upstream Celestia's normal build instructions, but apply the patches in
`patches/` first:

```sh
git clone https://github.com/CelestiaProject/Celestia.git
cd Celestia
../celestia-steam/scripts/apply-patches.sh
cmake -B build -S . -DENABLE_STEAM=ON -DSTEAMWORKS_SDK_ROOT=/path/to/sdk
cmake --build build
```

## License

Patches in `patches/` are derivative of GPL-2.0-or-later Celestia source and
inherit that license. Build scripts, SteamPipe configuration, and CI workflows
in this repository are MIT-licensed unless noted otherwise.
