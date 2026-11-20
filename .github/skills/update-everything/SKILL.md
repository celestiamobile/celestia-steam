---
name: update-everything
description: Fetch Celestia's Steam branch, merge upstream/master while preserving Steam integrations, refresh all four submodule pins, and adopt applicable upstream CI changes. Use when asked to update everything or update the Steam build's submodules.
---

# Update everything

## Scope and safeguards

- Read `.gitmodules`, both workflows, `README.md`, and the normal-maintenance
  and fork-preservation sections of `HANDOFF.md` before changing anything.
- Inspect the parent and all recursive submodule worktrees. Preserve existing
  edits; stop for conflicting edits rather than stashing or discarding them.
- Update Celestia from upstream while retaining the fork's Steam branch.
  Update content and Steamworks SDK to their configured remote branch tips,
  Sentry Native to the latest stable release tag. Steamworks SDK's branch tip
  should represent the latest SDK version, including any patch revision.
  Leave already-current pins unchanged.
- Do not independently advance nested submodules: initialize them at the
  revisions pinned by their owning dependency.
- Keep Steam app/depot IDs, release branches, credentials, Sentry targets,
  package feeds, and store metadata unchanged. Never upload or promote a
  Steam build as part of maintenance.
- Review upstream Celestia's CI and adopt corresponding changes where
  applicable to this Windows x64 Steam build, rather than independently
  upgrading unrelated tooling.
- Do not push, create a PR, or commit the parent repository unless requested.
  A local merge commit in the Celestia submodule is necessary to pin the
  integrated source. Explain when that commit still needs publishing.

## Resolve current versions

1. Fetch the configured remotes without changing worktree contents. Inspect
   remote default branches and `.gitmodules` branch settings rather than
   assuming every dependency follows `master`.
2. Fetch `CelestiaProject/Celestia`'s `master` into an upstream tracking ref
   inside `celestia/`. Compare it with the fork's current remote `steam` tip
   and the existing pin. Do not overwrite unpublished local work.
3. Query the latest stable Sentry Native release with `gh`, fetch its tag,
   and resolve the tag to a commit. Exclude prereleases such as beta tags
   rather than simply picking the highest-sorted tag.
4. Inspect Steamworks SDK's latest branch commits and version metadata to
   confirm the latest SDK version, including letter-suffixed patch releases.
5. Read `upstream/master:.github/workflows/ci.yml` and compare it with the
   previous Steam pin's CI and this repository's `.github/workflows/build.yml`.
   Review changes to vcpkg pins, dependencies/features, Actions, compiler and
   CMake options, tests, and deployment. Also check for upstream CI changes
   that were previously merged into the fork but not adopted here.

## Integrate the Steam fork

1. Start a new local integration branch in `celestia/` from the current
   remote `steam` tip, unless unpublished local work requires a different
   explicitly agreed base. Use a descriptive name containing the upstream
   revision; avoid modifying or rewriting an existing branch.
2. Merge the fetched upstream revision without immediately committing.
   If it is already an ancestor, no merge is needed.
3. Resolve conflicts by reading both sides and retaining upstream behavior
   alongside these fork-only invariants:
   - `ENABLE_STEAM`, Steamworks discovery/linking, and `steam_api64.dll`
     deployment;
   - Steam initialization and subscribed Workshop addon/script loading;
     each item's root `description.json` supplies `id` and `type`, and the
     content directory is named by that ID;
   - bundled Noto fonts and localized default font selection;
   - optional Sentry initialization, release metadata, Qt integration, and
     runtime/crashpad deployment, disabled at runtime without a DSN.
4. Inspect the merged diff against upstream to verify that these integrations
   survive. Avoid blanket conflict resolution using either side.
5. Initialize recursive submodules and run the applicable build/tests below.
   Once validated, create the local merge commit with any required session
   trailers. Point the parent gitlink at the resulting commit.
6. Before publishing the parent pin, the merge commit must be reachable from
   the fork URL in `.gitmodules` (normally its `steam` branch). If pushing was
   not authorized, leave the commit local and clearly identify this remaining
   publication step. Never force-push to make the histories fit.

## Refresh the orchestration

- Check out content and Steamworks at their resolved branch tips and Sentry
  Native at the selected stable release, then initialize their recursive
  submodules at the recorded revisions.
- The parent gitlinks must point to the validated Celestia merge commit,
  content's latest commit on its configured branch, Sentry's latest stable
  release-tag commit, and the latest Steamworks SDK version commit.
- Review the updated source's CMake dependencies and integration options.
  Adjust the workflow only where required for the dependency update; preserve
  the Windows x64 packaging, tests, Qt deployment, Steam runtime, Sentry
  runtime, and debug-symbol upload.
- Adopt relevant upstream CI updates, including Action major versions and
  their documented runner requirements. Keep upload/download Actions
  compatible across both workflows. Preserve intentional differences:
  Windows x64 only, the Steam-specific triplet and package feed, bundled ICU
  rather than Windows ICU, disabled tools, and Steam/Sentry build steps.
- Do not replace an upstream-matching vcpkg pin with an arbitrary newer tip.
  Do not copy upstream's platform matrix or publishing unrelated settings.

## Verification and handoff

- Run `git diff --check` in the parent and changed source worktrees; inspect
  `git diff --submodule=log` and recursive submodule status. Confirm that no
  nested dependency has drifted from its owner's pin.
- If a required compatibility fix changes a workflow, run the existing
  workflow linter. If absent, first attempt it, then install it only as
  necessary for validation.
- Build the merged Celestia source and run its existing unit and integration
  tests with CMake/CTest. On macOS, use available dependencies and an
  out-of-tree build; configure the Qt6 frontend and optional integrations
  when supported. Build Sentry from its pinned source when needed.
- Do not report a macOS/core-only build as Windows or Steam validation.
  The authoritative Windows check is `.github/workflows/build.yml`, including
  CTest, runtime staging, and artifact creation. Run it if repository changes
  have been published with permission; otherwise report that it remains
  unverified.
- Validate content configuration/installation when its pin changes.
- Do not modify docs solely to replace historical commit IDs; update references
  only when the documented procedure or preserved behavior actually changes.
- Remove only temporary artifacts created by this task. Summarize changed
  revisions, already-current dependencies, test outcomes, and any necessary
  fork publication or Windows CI step. Never claim tests passed without
  running them.
