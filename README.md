# celestia-steam

Build orchestration for shipping Celestia on Steam.

This repository pins our [Celestia fork's `steam`
branch](https://github.com/celestiamobile/Celestia/tree/steam) and
[CelestiaContent](https://github.com/CelestiaProject/CelestiaContent) at
known-good commits via submodules, builds the Windows x64 binary, and
uploads the result via SteamPipe. Windows is the only target platform.

The Steam-specific source changes (Steamworks SDK integration, Workshop
content loading, Noto font replacement, localizable default fonts) live
as commits on the `steam` branch of the fork — not as patches in this
repo.

## Layout

```
steampipe/               SteamPipe app/depot configuration (.vdf)
triplets/                vcpkg overlay triplets used by CI
celestia/                submodule — celestiamobile/Celestia @ steam branch
content/                 submodule — CelestiaProject/CelestiaContent
steamworks_sdk/          submodule — community mirror of the Steamworks SDK
sentry-native/           submodule — getsentry/sentry-native (crash reporting)
.github/workflows/       build + upload pipeline
```

## Upstream pinning

`celestia/` and `content/` are submodules pinned to specific commits.
Bumping is a deliberate operation:

```sh
git submodule update --remote celestia content
git commit -am "Bump upstream celestia/content"
```

For the `celestia` submodule the tracked branch is `steam` on the fork,
not `master` on upstream — so the bump picks up the latest Steam-specific
commits plus whatever has been rebased on top of upstream master into
`steam`.

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

## Crash reporting (Sentry)

Crash reporting uses [sentry-native](https://github.com/getsentry/sentry-native)
(crashpad backend, with the Qt integration) and is pinned as the
`sentry-native/` submodule. The vcpkg port does not expose the Qt integration,
so CI builds sentry-native from source against vcpkg's Qt6 and installs it to a
prefix the main Celestia configure step consumes. Bumping the SDK is a normal
submodule pointer update.

The integration lives on the fork's `steam` branch behind `-DENABLE_SENTRY=ON`
and is a no-op when no DSN is baked in. The release is tagged
`celestia@<version>+<github-run-number>`. CI ships `crashpad_handler.exe` and
the sentry runtime alongside `celestia-qt6.exe`, and uploads all EXE/DLL/PDB
debug files to Sentry via `sentry-cli`.

Configure these on the repository:

- Secrets: **`SENTRY_DSN`** (baked into the build) and
  **`SENTRY_AUTH_TOKEN`** (used by `sentry-cli` to upload symbols). With the
  auth token unset, the symbol-upload step is skipped; with the DSN unset,
  crash reporting is disabled at runtime.
- Variables (non-secret): the `sentry-cli` upload target is set in the
  workflow as `SENTRY_ORG: celestia-for-steam` / `SENTRY_PROJECT: native-qt`.

## SteamPipe

The Steam App ID is **4753420** and the Windows depot is **4753421**, both
configured in `steampipe/app_build.vdf` and `steampipe/depot.vdf`. CI's
upload step is gated on a `workflow_dispatch` input plus the
`STEAM_USERNAME` and Steam Guard `config.vdf` secrets.

## Building locally

```sh
git clone --recursive https://github.com/celestiamobile/celestia-steam.git
cd celestia-steam
cmake -B build -S celestia -DENABLE_STEAM=ON \
    -DSTEAMWORKS_SDK_ROOT=../steamworks_sdk
cmake --build build
```

## License

The Celestia source on the fork's `steam` branch is GPL-2.0-or-later
(inherited from upstream). The build scripts, SteamPipe configuration,
and CI workflows in *this* repository are MIT-licensed unless noted
otherwise.
