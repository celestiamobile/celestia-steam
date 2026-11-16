# Maintainer handoff

## Project status

I am no longer maintaining `celestia-steam`. A new maintainer is welcome to
continue the project, but should operate it under infrastructure and accounts
they control.

In particular, the new maintainer must:

1. Use their own personal Steam account to create and own their
   [Steamworks partner account](https://partner.steamgames.com/).
2. Complete Valve's onboarding, agreements, identity/company, tax, bank, and
   payment requirements, then wait for Valve to verify the submitted
   information.
3. Pay Valve's **$100 USD Steam Direct fee** to register a new app, subject to
   Valve's current terms and any applicable taxes.
4. Register a new Steam app and Windows depot for publishing.
5. Create a separate Steam account for CI build uploads and publishing
   Workshop items.
6. Replace this repository's existing Steam App ID and depot ID with the newly
   assigned IDs.

The existing Steamworks app, depot, credentials, Steam Guard session, store
listing, financial account, and private service credentials are not part of
this handoff. Do not publish against App ID `4753420` or depot ID `4753421`.

The celestia.mobi website, backend, production CloudKit container, Apple
developer resources, and add-on publication infrastructure are also not part
of this handoff and will not be administered by the new Steam maintainer. The
new maintainer does not need direct CloudKit or backend access: the public API
under `https://celestia.mobi/api/2/` exposes the published add-on catalog and
download URLs needed to build a replacement Workshop crawler. The maintainer
is responsible for implementing and operating that sync without assuming
control of mobi infrastructure.

## What this repository contains

This repository orchestrates a Windows x64 build of Celestia with Steamworks
and Steam Workshop support. The main pieces are:

| Path | Purpose |
| --- | --- |
| `celestia/` | Celestia fork pinned to the Steam-specific `steam` branch |
| `content/` | Pinned Celestia content |
| `steamworks_sdk/` | Pinned community mirror of the Steamworks SDK |
| `sentry-native/` | Pinned native crash-reporting SDK |
| `triplets/` | vcpkg overlay used by the Windows CI build |
| `steampipe/` | SteamPipe app and depot manifests |
| `.github/workflows/build.yml` | Builds, tests, packages, and retains the Windows artifact |
| `.github/workflows/upload.yml` | Manually uploads a selected build artifact to Steam |

Steam-specific source changes are maintained in the `steam` branch of
`celestiamobile/Celestia`, not as patches in this repository. That branch will
also be deleted, so preserving only this orchestration repository is not
enough.

## First-time takeover checklist

### 1. Clone and republish the repositories

Do **not** rely on a GitHub fork of this repository. This repository will be
deleted, so the new maintainer should create an independent empty repository
under an account or organization they control, clone this repository, and push
the complete Git history to the new location before deletion.

One way to preserve all branches, tags, and other Git refs is:

```sh
git clone --mirror https://github.com/celestiamobile/celestia-steam.git
cd celestia-steam.git
git push --mirror https://github.com/NEW_OWNER/celestia-steam.git
```

A mirror only preserves data stored in Git. If GitHub issues, pull requests,
releases, Actions artifacts, package caches, or repository settings are
needed, export or recreate them separately before this repository is deleted.

The maintainer must create and maintain their own fork of Celestia and preserve
the current `steam` branch in it before the `celestiamobile/Celestia` fork is
deleted:

```sh
git clone https://github.com/celestiamobile/Celestia.git
cd Celestia
git switch steam
git remote rename origin old-origin
git remote add origin https://github.com/NEW_OWNER/Celestia.git
git push --set-upstream origin steam
```

The new fork can be created from the upstream Celestia repository, but the
`steam` branch must be pushed from the current `celestiamobile` clone; creating
a fresh upstream fork alone will not preserve these commits.

The fork-specific commits that need to remain in the maintained branch are:

| Commit | Responsibility |
| --- | --- |
| `7621c643e` | Adds `ENABLE_STEAM`, locates and links the Steamworks SDK, and deploys `steam_api64.dll` with the Qt6 application |
| `f833d2c79` | Initializes Steamworks and loads subscribed Workshop addons and scripts described by each item's `description.json` |
| `7eb95001e` | Replaces DejaVu with localized Noto font families, including Arabic, CJK, and Georgian variants |
| `c2920f3d1` | Adds optional Sentry Native crash reporting, release metadata, and runtime deployment for Qt6 |

Commit IDs may change if the branch is rebased, so preserve the behavior rather
than relying only on these hashes. In particular, Workshop items depend on a
root `description.json` containing an `id` and a `type` of either `addon` or
`script`, with the content stored in a sibling directory named by that ID.

The `steam` branch has historically incorporated upstream Celestia changes
while retaining these fork-only changes. The new maintainer is responsible for
continuing that integration, resolving conflicts, testing the Steam-specific
code after upstream changes, and ensuring CI continues to pin a known-good
commit.

After choosing the new repository locations:

- update the `celestia` URL and branch in `.gitmodules`;
- update repository and organization references in `README.md`;
- update the NuGet package source and username in
  `.github/workflows/build.yml`; and
- run `git submodule sync --recursive` followed by
  `git submodule update --init --recursive`.

Do not assume that the existing `celestiamobile` GitHub organization, package
feed, or credentials will remain available.

### 2. Create a new Steamworks app

Steamworks onboarding is not immediate. Valve must verify the submitted bank,
tax, identity, and company information before the maintainer can add users and
set up the first app. A straightforward review may complete in about one
business day, but this is not guaranteed; allow several business days in the
handoff schedule in case Valve requests further review or corrections. See
Valve's [Getting Started documentation](https://partner.steamgames.com/doc/gettingstarted)
for the current process.

After verification and payment of the $100 USD Steam Direct fee, register a
new app and create a Windows depot. Valve will assign both an app ID and a
depot ID. Configure the app's store presence, pricing, supported platforms,
launch options, depots, packages, release branches, and required
review/release steps in Steamworks.

Configure the new app as a **Steam Early Access** title and complete Valve's
Early Access questionnaire, disclosures, branding, and store-page
requirements. The existing App ID `4753420` was not marked as Early Access;
do not copy that aspect of its configuration to the replacement app. Keep the
store description accurate about the application's current state, remaining
work, update expectations, and pricing plans. See Valve's
[Early Access documentation](https://partner.steamgames.com/doc/store/earlyaccess)
for the current requirements.

The existing app's publicly available store copy, system requirements,
features, languages, pricing, ratings, Workshop description, and media URLs
are preserved in [the Steam Store metadata snapshot](STEAM_STORE_METADATA.md).
Use it as editable source material, then verify every field and replace all
legacy IDs, dates, contacts, and non-transferable settings.

Valve imposes a mandatory **30-day waiting period from payment of the Steam
Direct app fee before the app can be released**. The maintainer can configure
the app, upload builds, and test during that period, but cannot shorten or
skip the release hold. Valve also requires the public **Coming Soon** page to
be visible for at least two weeks before release. Plan the takeover and launch
schedule around both requirements and confirm the current rules in Valve's
[Steam Direct documentation](https://partner.steamgames.com/steamdirect/).

Then replace the legacy IDs in:

- `steampipe/app_build.vdf`: change `appid` and the depot map key; and
- `steampipe/depot.vdf`: change `DepotID`.

Search the repository for both legacy values to ensure none remain:

```sh
git grep -n -e 4753420 -e 4753421
```

The executable staged by CI is `celestia-qt6.exe`; configure the new
Steamworks app's Windows launch option accordingly. Use a private Steam branch
for initial upload and testing before making any build public.

### 3. Separate ownership from publishing credentials

Use two different Steam accounts:

| Account | Purpose |
| --- | --- |
| Personal Steam account | Owns and administers the Steamworks partner account; do not expose its credentials to CI |
| Dedicated publishing account | Uploads builds through CI and publishes Workshop items |

Invite the dedicated publishing account to the new Steamworks partner
organization and grant it only the app permissions required for build uploads
and Workshop publishing. Do not grant partner ownership, financial, user
management, or other administrative permissions unless they are demonstrably
required.

Enable Steam Guard on the dedicated account and authenticate SteamCMD once in
a trusted environment. Only this account's revocable session should be placed
in GitHub Actions. This limits the impact of a CI secret exposure and avoids
putting the maintainer's personal Steam credentials in automation.

Configure these GitHub Actions secrets:

| Secret | Purpose |
| --- | --- |
| `STEAM_USERNAME` | Username of the dedicated publishing account |
| `STEAM_CONFIG_VDF` | Base64-encoded SteamCMD `config.vdf` from the dedicated account's authenticated session |

To create `STEAM_CONFIG_VDF`:

1. Install SteamCMD in a trusted local environment. Do not generate the
   session on a shared machine or in CI.
2. Log in interactively with the dedicated publishing account:

   ```sh
   ./steamcmd.sh +login DEDICATED_STEAM_USERNAME +quit
   ```

   Enter that account's password and Steam Guard code when prompted. SteamCMD
   writes the authenticated session to `config.vdf`.
3. Locate the generated file. Common Linux locations are:

   ```text
   ~/Steam/config/config.vdf
   ~/.steam/steam/config/config.vdf
   ```

   The upload workflow restores the same file to both locations for
   compatibility.
4. Verify the cached session before storing it. Running the login again with
   only the username should complete without requesting a password or Steam
   Guard code:

   ```sh
   ./steamcmd.sh +login DEDICATED_STEAM_USERNAME +quit
   ```

5. From the new GitHub repository, store the username and pipe a single-line
   base64 encoding of the file directly into the repository secret:

   ```sh
   gh secret set STEAM_USERNAME --body "DEDICATED_STEAM_USERNAME"
   base64 -w 0 ~/.steam/steam/config/config.vdf |
     gh secret set STEAM_CONFIG_VDF
   ```

   On macOS, where `base64 -w` is unavailable, use:

   ```sh
   base64 < ~/.steam/steam/config/config.vdf | tr -d '\n' |
     gh secret set STEAM_CONFIG_VDF
   ```

   If the file exists only under `~/Steam/config/`, substitute that path.

Treat `STEAM_CONFIG_VDF` as a credential. Never commit it, print it in logs, or
reuse the previous maintainer's session. Rotate it immediately if exposed.
The upload workflow logs in with the username and cached Steam Guard session;
it deliberately does not store a Steam password. Steam may expire or revoke
the cached session; when that happens, repeat the interactive login and
replace the GitHub secret.

The separate daily pipeline that publishes celestia.mobi add-ons to Steam is
documented in [the Workshop synchronization runbook](WORKSHOP_SYNC.md). It is
provided as a description of the current implementation, not as access to
celestia.mobi. The runbook describes how to replace its direct CloudKit query
with the public celestia.mobi API, then connect it to the replacement App ID,
dedicated publisher account, and a fresh private state repository.

### 4. Optionally configure Sentry

Sentry crash reporting is optional. The application still builds and runs
without sending crash reports.

To use Sentry:

1. Create an account at [sentry.io](https://sentry.io/) and create an
   organization controlled by the new maintainer.
2. Create a project for the native Celestia application. Select the Native or
   C/C++ platform when available.
3. Copy the project's DSN from its client-key/project settings.
4. Create an organization-owned Sentry auth token with only the permissions
   required by `sentry-cli debug-files upload`. Avoid using a personal token
   when an organization integration token is available.
5. Update `SENTRY_ORG` and `SENTRY_PROJECT` in
   `.github/workflows/build.yml` to match the new organization and project
   slugs.
6. Add the following GitHub Actions secrets to the new repository:

| Secret | Purpose |
| --- | --- |
| `SENTRY_DSN` | Enables crash reporting in the built application |
| `SENTRY_AUTH_TOKEN` | Uploads debug symbols during CI |

Trigger a Build workflow and confirm that its debug-symbol upload completes,
then verify that a test crash resolves to readable function names and the
expected `celestia@<version>+<github-run-number>` release in the new project.
Review Sentry's data-retention, privacy, and user-disclosure requirements
before enabling reporting for users.

Without `SENTRY_AUTH_TOKEN`, symbol upload is skipped. Without `SENTRY_DSN`,
runtime reporting is disabled, although CI currently still builds and packages
the Sentry runtime.

If Sentry will not be retained, drop the fork-specific Sentry commit
`c2920f3d1` from the new fork's `steam` branch rather than carrying unused
integration code indefinitely. If the takeover branch has not been shared,
omit that commit while rewriting the branch. If the branch has already been
published or used by others, preserve history and revert it instead:

```sh
git revert c2920f3d1
```

Resolve and test any conflicts caused by later upstream merges. Also change
the CI configure step to `-DENABLE_SENTRY=OFF` and remove the Sentry SDK build,
runtime packaging, symbol-upload steps, secrets, and `sentry-native` submodule
from this orchestration repository.

Do not expect access to the existing Sentry organization, project, crash data,
or credentials.

### 5. Validate the replacement pipeline

1. Trigger the **Build** workflow manually.
2. Confirm its tests pass and download the `celestia-steam-build` artifact.
3. Run the artifact outside Steam and inspect the packaged files.
4. Run **Upload to Steam** with the successful Build run ID and no
   `release_branch`, so the build uploads without being promoted.
5. Inspect the build and depot in Steamworks.
6. Promote it only to a private test branch.
7. Install it through Steam and test startup, content, Steam overlay behavior,
   Workshop behavior, updates, and crash reporting if enabled.
8. Complete Valve's store and build review requirements before release.

## Normal maintenance

Upstream source and content are pinned submodules. Review upstream changes
before advancing either pointer:

```sh
git submodule update --remote celestia content
git diff --submodule=log
```

The `celestia` submodule follows the fork's `steam` branch, which must retain
the Steam-specific commits while incorporating suitable upstream Celestia
changes. Also periodically review and deliberately bump the Steamworks SDK,
Sentry Native, pinned vcpkg commit, GitHub Actions, and Windows runner image.

Every push to `main` runs the Windows build. Steam upload is manual and can
target a specific successful Build workflow run. Build artifacts are retained
for 10 days, so durable releases should be archived separately if required.

## Release responsibility

The incoming maintainer is responsible for licensing compliance, Valve's
agreements and policies, store disclosures, customer support, moderation,
security updates, privacy implications of telemetry/crash reporting, and all
commercial and tax obligations associated with their new Steamworks app.

The code is provided under the licenses described in `README.md` and the
included license files. This handoff transfers no trademark rights, private
accounts, credentials, customer data, or entitlement to the existing Steam
listing.
