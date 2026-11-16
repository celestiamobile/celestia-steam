# celestia.mobi to Steam Workshop synchronization

> [!IMPORTANT]
> celestia.mobi remains independently operated. Its website, backend,
> CloudKit container, Apple developer account, credentials, and publication
> pipeline are not transferred to the new Steam maintainer. This document
> explains the current synchronization behavior and the public API available
> for a replacement crawler; it does not grant access to or control over mobi
> systems.

## Overview

The add-on synchronization is a separate system from `celestia-steam`. The
current implementation is a one-way publishing pipeline:

```text
celestia.mobi submission
        |
        v
celestia-addon-validator pull request and validation
        |
        v
Celestia production CloudKit ResourceItem
        |
        v
daily CelestiaWorkshopSyncApp job
        |
        +----> private Git state: add-on ID <-> Workshop item ID
        |
        v
SteamCMD -> Steam Workshop
        |
        v
subscriber's Steam client -> Celestia loads item at startup
```

Steam Workshop is not a source of truth. Changes made directly to a managed
Workshop item's title, description, preview, content, or visibility do not
flow back to celestia.mobi and may be overwritten by a later sync. Add-on
changes should enter through the celestia.mobi submission process.

The replacement sync should preserve that one-way model while reading the
public celestia.mobi API instead of accessing CloudKit directly:

```text
https://celestia.mobi/api/2/resource/*
        |
        v
replacement catalog crawler and state comparison
        |
        v
SteamCMD -> replacement app's Steam Workshop
```

The current implementation lives in these companion repositories:

- [`celestiamobile/celestia-addon-validator`](https://github.com/celestiamobile/celestia-addon-validator):
  validation, CloudKit upload, `CelestiaWorkshopSyncApp`, and the scheduled
  workflow.
- `celestiamobile/celestia-steam-workshop-history`: private synchronization
  state and add-on-to-Workshop ID mappings.

The companion repositories are not transferred by this handoff. The incoming
maintainer must obtain any required reuse permission or independently
implement equivalent synchronization using the public API. Public visibility
of source code does not by itself grant credentials, operational control, or
permission to republish it. The replacement Steam app must use a new private
state repository regardless of which implementation is selected.

## Submission and celestia.mobi publication

An add-on author starts at
[celestia.mobi/submit-addon](https://celestia.mobi/submit-addon). The site
creates a pull request in `celestia-addon-validator` containing a pending
record ID, zip, or remote-zip URL. The pull request workflow builds the Swift
validator and checks the proposed add-on.

After a collaborator reviews and merges a valid pull request, the main-branch
workflow uploads the add-on to the production CloudKit container
`iCloud.space.celestia.Celestia`. celestia.mobi reads the resulting
`ResourceItem`. The site may take up to about an hour to display a merged
change.

The Workshop job does not read the website or validator pull requests. It
queries the production CloudKit public database directly, so only data that
has reached CloudKit can be synchronized.

That direct CloudKit access is an implementation detail of the current job,
not a requirement for its replacement.

## Public API for the replacement crawler

The live public API base URL is:

```text
https://celestia.mobi/api/2/
```

No CloudKit credential is required for these read-only catalog calls.

### List published categories

```sh
curl --fail --retry 3 --get \
  'https://celestia.mobi/api/2/resource/categories' \
  --data-urlencode 'lang=en' \
  --data-urlencode 'pageStart=0' \
  --data-urlencode 'pageSize=100'
```

The response is a JSON array. Each category contains at least `id`, `name`,
`description`, and usually an `image` URL.

### List published items in a category

```sh
curl --fail --retry 3 --get \
  'https://celestia.mobi/api/2/resource/items' \
  --data-urlencode 'category=<category-id>' \
  --data-urlencode 'lang=en' \
  --data-urlencode 'pageStart=0' \
  --data-urlencode 'pageSize=100'
```

The response is a JSON array of published add-ons and scripts. Continue
increasing `pageStart` by `pageSize` until a page contains fewer than
`pageSize` entries. Repeat for every category and de-duplicate by item `id`.

### Fetch one item

```sh
curl --fail --retry 3 --get \
  'https://celestia.mobi/api/2/resource/item' \
  --data-urlencode 'item=<item-id>' \
  --data-urlencode 'lang=en'
```

The category-item response already contains the same publishing fields, so a
separate request per item is not required for a normal crawl. Use this endpoint
to refresh one item's signed asset URLs or inspect it independently.

The item response exposes the fields needed by the Workshop publisher:

```json
{
  "id": "<stable-item-id>",
  "name": "<title>",
  "type": "addon",
  "description": "<description>",
  "authors": ["<author>"],
  "image": "<temporary-preview-download-url>",
  "item": "<temporary-zip-download-url>",
  "checksum": "<stable-zip-checksum>",
  "publishTime": 0,
  "objectName": "<optional-object-path>"
}
```

`type` can be `addon` or `script`. Some optional fields may be absent.
The asset URLs are signed and temporary: download the zip and preview during
the same run and do not store those URLs as durable state. The `checksum`
field can detect zip changes. The public response does not expose a stable
preview checksum, so hash the downloaded image bytes locally. Exclude the
signed `item` and `image` URL strings from metadata hashes because they can
change even when the underlying assets do not.

### Safe full-crawl algorithm

The public API does not expose uncategorized/retired records or a deletion
feed. A replacement sync should therefore:

1. Fetch every page of categories.
2. Fetch every page of items for every category.
3. Fail the crawl if any category or item-page request fails after bounded
   retries.
4. De-duplicate items by stable `id` and record the set of categories in
   which each item was observed.
5. Use `checksum` to detect zip changes without downloading every zip. Download
   and hash each present preview image because the API does not expose a stable
   preview checksum; download the zip when creating or updating content.
6. Hash public metadata, the stable zip checksum, preview bytes, type, and
   observed category IDs, then compare them with the private state repository.
7. Create or update changed items through SteamCMD.
8. Only after the **entire crawl succeeds**, hide state-tracked Workshop items
   whose IDs were not observed anywhere in the current catalog.
9. Commit the new state and a crawl summary atomically after uploads finish.

Never interpret a partial crawl, timeout, HTTP error, malformed response, or
unexpectedly empty top-level category catalog as mass deletion. Keep the
previous state and skip the hide phase when completeness cannot be proven.

The API currently has no published delta contract, so perform a full crawl.
Use bounded concurrency, retries with backoff, an identifying User-Agent,
reasonable request pacing, and operator-provided rate-limit guidance. Cache
within a run, but refresh signed asset URLs when an upload is actually needed.

## CloudKit record mapping

The Workshop job scans every `ResourceItem` and reads:

| CloudKit field | Workshop use |
| --- | --- |
| Record name | Stable add-on ID and state filename |
| `item` | Zip archive uploaded as Workshop content |
| `image` | Optional Workshop preview image |
| `name` | Workshop title |
| `description` | Start of the Workshop description |
| `authors` | Appended as `By ...` in the description |
| `type` | `addon` or `script`; controls how Celestia loads it |
| `category` | Non-null means publish; null means hide |

The sync also appends the canonical celestia.mobi URL to each Workshop
description:

```text
https://celestia.mobi/resources/item/<addon-id>
```

## Workshop package format

For each item, the job downloads and unzips the CloudKit asset into a temporary
folder matching the Steam-enabled Celestia client's expected format:

```text
content/
├── description.json
└── <addon-id>/
    └── <unzipped add-on or script files>
```

`description.json` contains:

```json
{
  "id": "<addon-id>",
  "type": "addon"
}
```

The type is either `addon` or `script`. Celestia handles them differently:

- `addon` content is prepended to the application's extras directories during
  startup; command-line extras directories retain higher conflict precedence.
- `script` content is added to the Qt6 Scripts menu.

The preview image is staged outside the content folder and uploaded as
Workshop metadata. JPEG, PNG, GIF, and BMP signatures are recognized.
Steam Workshop requires the preview image to be below the **1 MiB
(1,048,576-byte)** limit. Keep comfortable headroom rather than targeting the
boundary; 950 KiB or less is a safer operational target.

Download remote previews before measuring them. Checking a remote URL's local
file metadata can silently produce no size and let an oversized image through.
Validate the downloaded byte count before invoking SteamCMD. If necessary,
create a resized or recompressed preview derivative without modifying the
source image on celestia.mobi. For JPEG conversion, flatten transparent PNG
pixels onto a deliberate background color and preserve the aspect ratio.

Do not submit an oversized file and rely on SteamCMD to explain the problem.
In prior production runs, Steam created the Workshop item shell and then
reported **`k_EResultLimitExceeded` / `Limit exceeded`** during submission.
That message looked like request throttling but was consistently caused by
previews over 1 MiB. Retrying every scheduled run did not fix it; replacing
the preview with a smaller baseline JPEG did.

On startup, the Steam-enabled client initializes Steamworks, enumerates
subscribed and installed items, validates `description.json`, and loads the
declared add-on directory or script. Missing or malformed descriptions and
missing ID directories are skipped.

## Change detection and lifecycle

The job compares CloudKit with one JSON state file per add-on. It tracks the
Workshop PublishedFile ID, content and preview checksums, hashes of selected
metadata fields, visibility, timestamps, and failure count.

| CloudKit/state condition | Result |
| --- | --- |
| Category set, no state | Create a public Workshop item |
| Category set, hashes changed | Update content and/or metadata |
| Category set, hashes unchanged | Skip |
| Category removed, item public | Hide the Workshop item |
| Category removed, item already hidden | Skip |
| Category restored, item hidden | Make it public and update it |

Removing a category hides an item instead of deleting it. The ID mapping stays
in state so restoring the category updates and unhides the same Workshop item.

The Steam change note identifies whether content, preview, title, description,
category, authors, or type changed. New items use `Initial upload`.

## Known failure signatures

These failure modes were confirmed during operation of the existing sync:

| SteamCMD/staging symptom | Proven cause | Response |
| --- | --- | --- |
| `k_EResultLimitExceeded` or `Limit exceeded` after an item ID was assigned | Preview image over 1 MiB, despite the rate-limit wording | Download and measure the preview; recompress below the limit with headroom, then retry the existing item |
| `KeyValues Error: RecursiveLoadFromBuffer: got } in key` followed by `Failed to parse build config` and exit code 9 | A literal ASCII `"` in a title or description broke SteamCMD's no-escape VDF parser | Replace paired ASCII quotes with typographic quotes before writing VDF values; do not use `\\\"` escaping |
| Permission error while creating a directory such as `textures/medres` | The source zip stored parent directories with read-only mode `0555` | Normalize extracted directories to `0755` and files to `0644` in the temporary staging tree, or repair the source archive |
| Workshop ID exists, but content checksum and metadata hashes remain empty | Steam created the item shell but the subsequent upload failed | Preserve the Workshop ID in partial state and update that item on retry; deleting the mapping creates duplicates |

SteamCMD can print unrelated `EOSType`, bootstrapper, or client assertions.
Treat the process exit status and the specific build/upload error as
authoritative rather than diagnosing from incidental client noise.

The VDF parser used by `workshop_build_item` has escape sequences disabled.
Raw newlines are accepted, but a backslash-escaped quote is interpreted as a
literal backslash followed by a string-ending quote. Sanitize every
user-controlled title, description, author string, and change note before VDF
generation.

## State repository

The private state repository contains:

```text
addons/
└── <addon-id>.json
last_run.json
```

Each add-on state file maps the stable CloudKit ID to Steam's
`PublishedFileId_t`. This mapping prevents duplicate Workshop items and allows
future updates to target the correct item. The Git history is also the upload
audit trail.

For the replacement Steam App ID, create a **new, empty, private state
repository**. Do not seed it with mappings from App ID `4753420`: Workshop
PublishedFile IDs belong to the old app and cannot be updated as items of the
new app. The first replacement-app sync must create new Workshop items.
Subscriptions, favorites, ratings, comments, and statistics from old items do
not transfer to the new App ID.

Once new items are created, preserve and back up the new state repository.
Losing a mapping can cause the next run to create a duplicate item. Do not
delete state merely to retry a failed upload; the code records a partially
created Workshop ID when SteamCMD reports one.

## Accounts and permissions

The API-based sync needs independently controlled Steam and GitHub services:

1. **Steam:** Use the dedicated publishing account described in
   `HANDOFF.md`. It must have the replacement app's Workshop permissions,
   accept any required Workshop legal agreement, and own the newly created
   items. Do not use the personal partner-owner account in CI.
2. **GitHub:** The workflow needs read/write access to the new private state
   repository. Prefer a GitHub App token or a fine-grained personal access
   token scoped only to that repository's Contents permission.

celestia.mobi remains a third service with independent ownership, but its
catalog endpoints are public and require no API secret. The Steam maintainer
should still coordinate crawl frequency, attribution, redistribution,
moderation, removals, and incident handling with the mobi operator. Public
read access does not override add-on licenses or author permissions.

## GitHub Actions secrets

Configure these secrets in the replacement API-based sync repository:

| Secret | Purpose |
| --- | --- |
| `GH_ACCESS_TOKEN` | Checks out and pushes the private state repository |
| `STEAM_USERNAME` | Dedicated Workshop publishing account |
| `STEAM_CONFIG_VDF` | Base64-encoded authenticated SteamCMD session |

Follow the `STEAM_CONFIG_VDF` procedure in `HANDOFF.md` using the same
dedicated account that will own the Workshop items. Treat the Steam session
and GitHub token as credentials and rotate them if exposed. No
`CLOUDKIT_KEY_ID` or `CLOUDKIT_KEY_BASE64` secret is needed when using the
public API.

## Adapting the workflow for the replacement app

Implement or place the permitted sync code in a repository controlled by the
Steam maintainer and update `.github/workflows/workshop-sync.yml`:

1. Change the state-repository checkout from
   `celestiamobile/celestia-steam-workshop-history` to the new private state
   repository.
2. Change `--app-id 4753420` to the replacement Steam App ID.
3. Replace `OpenCloudKit` and `WorkshopAddonRecord` fetching with the public
   category/item crawler described above.
4. Confirm the macOS runner and Swift package dependencies still build.
5. Configure all applicable secrets under the new repository.
6. Keep workflow concurrency enabled so two syncs cannot update the same
   Workshop items or state simultaneously.

The current workflow runs daily at 06:00 UTC. It also supports manual
dispatch:

| Input | Meaning |
| --- | --- |
| `limit` | Maximum uploads during the run; `0` means no cap |
| `dry_run` | Calculate and print actions without uploading or writing state |

The current default limit is 20 uploads per run. The replacement job should
still scan the complete public API catalog; the limit only caps
create/update/hide/unhide actions.

## First synchronization

Before the first run:

1. Test a complete, read-only crawl of the public mobi category and item APIs.
2. Enable and configure Steam Workshop for the replacement app.
3. Confirm the dedicated account has the required app permissions and has
   accepted the Workshop agreement.
4. Create the empty private state repository and verify that the workflow
   token can push to it.
5. Confirm SteamCMD can log in non-interactively with the cached session.
6. Run a dry run with a small limit:

   ```sh
   gh workflow run workshop-sync.yml \
     -f dry_run=true \
     -f limit=5
   ```

7. Review the planned creates, hides, updates, types, and record count.
8. Run a real sync with a small limit:

   ```sh
   gh workflow run workshop-sync.yml \
     -f dry_run=false \
     -f limit=5
   ```

9. Inspect every created Workshop item, its content layout, preview, title,
   description, visibility, owner, and celestia.mobi link.
10. Subscribe using a separate test account and verify both add-ons and scripts
    load in a build installed through Steam.
11. Increase the limit gradually. A fresh App ID recreates the full catalog,
    so initial publication may require many scheduled or manually dispatched
    runs.

Keep initial items hidden or restrict testing through Steamworks as necessary
until the new app and Workshop are ready for public use.

## Normal operation

For each daily run:

- inspect the Actions result;
- review the upload, skip, failure, hide, and unhide counts;
- verify that state changes were committed and pushed;
- investigate repeated failures rather than deleting their state files; and
- periodically test a subscribed item end to end.

When credentials expire, recreate the affected session or key and replace the
secret. When changing the dedicated Steam account, remember that Workshop item
ownership and update rights may prevent the replacement account from updating
items created by the old account; test the transition before disabling the old
publisher.

If celestia.mobi changes its CloudKit schema, asset format, container, or
publication process, update `WorkshopAddonRecord`, staging, hashing, and the
workflow together. If the Steam client changes its `description.json` contract,
update the publisher and client in the same release.

## Recovery rules

- **Dry run reports every item as new:** The state repository is missing,
  empty, or checked out from the wrong location. Stop before uploading unless
  this is the intentional first run for a new App ID.
- **SteamCMD requests a password or Steam Guard code:** Regenerate
  `STEAM_CONFIG_VDF`; CI must remain non-interactive.
- **SteamCMD reports a legal-agreement error:** Sign in to Steam with the
  dedicated account and accept the required Workshop agreement.
- **SteamCMD rejects a preview image:** Confirm it is a supported image format
  and comfortably below 1 MiB, then resize or recompress the staged
  derivative. Treat `k_EResultLimitExceeded` as a likely preview-size failure
  before assuming the account is being rate-limited.
- **A public API request fails or returns malformed data:** Retry with backoff,
  retain the previous state, and skip all absence-based hides for that run.
- **An upload creates an item and then fails:** Preserve the partial state so
  the next run updates that item instead of creating another one.
- **An item was edited manually on Steam:** Correct the source in
  celestia.mobi/CloudKit and allow the sync to reassert managed fields.
- **A source add-on is retired:** Remove its category through the normal mobi
  process; the sync hides rather than deletes its Workshop item.
