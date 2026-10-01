---
name: subminer-live-test
description: Build and install SubMiner, then verify changes, features, or fixes in the live Hyprland desktop using hyprland-computer-use and local anime videos. Use only in a SubMiner checkout or worktree when the user requests live testing or an implementation needs real installed-app verification. Clean up test-created Anki notes and stats sessions through the supported app paths. Do not invoke for read-only questions or headless unit checks.
---

# SubMiner live testing

This is a machine-specific user skill for SubMiner. Keep it under `~/.agents/skills/subminer-live-test/` so it is available across SubMiner checkouts and worktrees without being tracked in Git. Keep local paths and testing instructions here. Do not add them to tracked `AGENTS.md` or shared workflow docs.

Run all repository commands and resolve all repository paths against the SubMiner checkout or worktree being tested. Do not build from the original checkout when testing another worktree. All worktrees share the installed app, Anki collection, and stats database on this machine. Run one live testing session at a time and coordinate with any other agent using these resources.

The user authorizes building and installing the app for this workflow, and deleting the Anki notes and stats sessions created by the test. This applies to both user invocation and agent-selected live verification during implementation. Limit cleanup to artifacts whose ownership you can prove. Follow tool and sandbox approval requirements.

## Prepare

1. Resolve the requested SubMiner checkout or worktree with `git rev-parse --show-toplevel` and confirm its `package.json` and repository instructions identify SubMiner. If invoked outside SubMiner without a specified checkout, ask which checkout to test. State the behavior to verify and the observable result that would demonstrate success. Inspect `git status --short` and the relevant diff in that checkout. Read `docs/workflow/verification.md` and use `subminer-change-verification` for the appropriate cheap checks before packaging.
2. Read and follow the `hyprland-computer-use` skill at `/home/sudacode/.agents/skills/hyprland-computer-use/SKILL.md`. Discover `hyprland_desktop` tools and call `desktop_state` before assuming desktop access is unavailable. Use those tools for native SubMiner, mpv, and Anki interactions. If the workflow opens a browser page, use this session's preferred browser tools for that page.
3. Inspect running SubMiner/mpv processes and windows. Do not attach the test to an existing personal watch session or terminate unrelated playback. If personal playback prevents an isolated test, ask the user to finish or pause it before proceeding with dependent work.
4. Read the effective local configuration without exposing secrets. Usual locations on this machine are `~/.config/SubMiner/config.jsonc`, `~/.local/bin/subminer`, and `~/.local/bin/SubMiner.AppImage`. Resolve overrides instead of assuming these paths. Check the stats port, `immersionTracking.dbPath`, and AnkiConnect URL. An empty database path uses `immersion.sqlite` in the app's config directory.
5. Create a journal in a unique `/tmp/subminer-live-test-*` directory. Record build identity, test start/end times, media paths, process/window identities, actions, evidence, exact session IDs, and new Anki note IDs as you go. Keep the journal if testing fails or cleanup is incomplete so another turn can finish it.
6. Before launching test playback, capture existing session IDs and the stats that the test will affect. Include relevant daily/monthly rollups, lifetime global/media/anime totals, and vocabulary/kanji counts. Read through the stats API and, where needed, read-only SQLite queries. The sessions endpoint is capped at 500 results, so do not treat that response as a complete database inventory. Record the selected episode's watched flag too.
7. Before any mining, verify AnkiConnect and capture existing note IDs with `findNotes`, plus `notesInfo` for any existing note that the test is intended to update. Establish ownership before creating artifacts. If Anki or stats cleanup cannot be supported, resolve that before creating notes or watch sessions.

## Choose a video

- Use an actual video under `/truenas/jellyfin/anime`, with a Japanese subtitle track suitable for the behavior being tested. Check that the mount and selected file are readable. Quote media paths with spaces or punctuation.
- Prefer a show already in the loaded character dictionary. Inspect `~/.config/SubMiner/character-dictionaries/auto-sync-state.json` for `activeMediaIds`, check the corresponding `snapshots/anilist-<id>.json`, and use `anilist-resolution-cache.json` to match its series to a local file. Confirm the current loaded state in the character dictionary manager if needed. A snapshot alone does not prove the show is loaded.
- Resolve this afresh each run. Do not hard-code a title or trust an old filename match. Use dialogue away from openings/signs when it gives a clearer test.
- When testing new dictionary generation/import, deliberately choose a show that exercises that path. Record the dictionary state before the test. Avoid generating or evicting dictionaries as an incidental part of an unrelated test.
- If a relevant scenario needs different media or a missing subtitle track, report the limitation or ask for the needed input. Do not silently claim the selected episode covers it.

## Build and install

Every live test invocation builds and installs the current checkout before testing.

1. Read the current `Makefile` and `package.json` build/install targets. Ensure dependencies are available using the repo's pinned Bun version. Do not update submodules or lockfiles incidentally.
2. Run `bun run build:appimage`. It includes `bun run build` and packages Linux without publishing. Record the start time and the exact AppImage produced by this successful run. Do not select the first matching artifact from an old `release/` directory.
3. Gracefully stop the identified old SubMiner instance and any old stats daemon that would otherwise serve the previous build, after confirming no personal playback depends on them. Use the current supported stop commands. Avoid broad process kills. Keep playback stopped through install and baseline capture.
4. Install using `make install-linux APPIMAGE_SRC="/absolute/path/to/the/fresh.AppImage"`, with the existing install-prefix overrides if applicable. The explicit `APPIMAGE_SRC` prevents the Makefile's wildcard from installing a stale version. This installs the launcher and support files as well as the AppImage. Do not use `make clean`, the stale repo-root `./subminer`, or hand-edit generated artifacts.
5. Verify that the installed AppImage matches the freshly built artifact by checksum, and verify the installed launcher path. Start the installed app and stats service as needed, then capture the baseline before test playback. Launch the chosen video with the installed `subminer` command, explicitly resolving `SUBMINER_BINARY_PATH` if it would point elsewhere.
6. Confirm the running process is the new installed build. Version alone is insufficient when the version did not change. Single-instance forwarding or an old AppImage mount can leave the old build running. Check process identity/start time and the app's startup evidence before counting any result as verification.

If packaging or installation fails, report the exact failing step. A development launch cannot satisfy this skill's installed-app requirement.

## Exercise the change

Follow the Hyprland skill's sequence for each target window: list windows, focus the exact address, capture a screenshot, inspect it, send input, then capture and inspect the outcome. Keep focus/input operations sequential. Reacquire the address for dialogs and replacement overlay windows. Stop sending input when the user takes over or focus changes unexpectedly.

Exercise the actual UI behavior relevant to the change, including the original failure trigger when testing a fix. Check rendered subtitles, dictionary popups, focus, shortcuts, settings, sidebar, or mining only when relevant. Use screenshots for visible outcomes and logs/API reads for persistence. API calls alone cannot prove a desktop interaction works. If an essential interaction is unavailable, such as hover-only input, report it instead of substituting a different interaction and calling it a pass.

Record every session created by playback, reloads, media changes, or app restarts. Correlate new IDs with test-owned playback, media path, and start time. A timestamp or ID difference alone does not establish ownership when another activity is occurring.

When mining:

- Mine only what the scenario requires. For ordinary creation checks, choose a word that will create a new note instead of merging into a personal note. Include sentence, audio, and screenshot checks when they are part of the claimed behavior.
- Capture the exact returned note IDs or establish them using before/after `findNotes` and verified `notesInfo` matching the test's expression, sentence, and media. A unique temporary test tag can help, but only add it to notes already proven to belong to the test.
- Wait for asynchronous card enrichment and duplicate handling to settle before determining final ownership. Follow any merge/redirect to the surviving note. Record fields/tags before an intentional update test and restore test-made changes through supported APIs afterward. Do not delete a surviving pre-existing personal note.
- Avoid personal-note merge tests unless the task calls for them and the affected state can be restored. Prefer test-owned notes for merge scenarios.

## Clean up, including after a failed test

Do cleanup before handing off. When interrupted, preserve the journal and resume cleanup at the next opportunity. Do not create more artifacts while ownership or deletion is unresolved.

1. Stop new mining and gracefully close only test-owned playback. Wait for the tracker to finalize its sessions and for queued writes/enrichment to finish. Keep or restart the installed stats service without opening another video. Inspect final session state before deleting. The tracker ignores deletion of an active session, even when the HTTP response reports success.
2. Delete only the exact test-created Anki note IDs, preferably through AnkiConnect `deleteNotes` so their cards are removed together. Use the configured AnkiConnect upstream, not the SubMiner mining proxy, for cleanup. Requests use version 6 and must be checked for both HTTP failures and a non-null `error` value. Verify the recorded IDs no longer exist with `findNotes`/`notesInfo`, and restore any intentionally modified personal notes. Do not delete a deck, all notes tagged `SubMiner`, all recent notes, or globally purge media.
3. Remove every finalized test session using the stats app's session deletion flow. The UI or its HTTP endpoint is appropriate. Use the configured loopback stats server and either `DELETE /api/stats/sessions/<id>` or bulk `DELETE /api/stats/sessions` with JSON `{"sessionIds":[exact_test_ids]}` and `Content-Type: application/json`. Await completion and verify the IDs are gone. Re-read the route contract if it has changed.
4. Use the production route/service/maintenance chain. Do not run raw SQL `DELETE`, manually edit aggregates, restore an entire old database over current history, or delete whole media/anime entries to remove test sessions. The maintained chain drains queued writes, deletes session data, updates rollups and lexical counts, and removes lifetime contributions in its transaction.
5. Re-query stats after deletion completes and refresh the stats UI. Verify that the test session IDs and associated timelines/events are absent, test watch time/cards/lines no longer contribute to daily/monthly and lifetime totals, and affected vocabulary/kanji counts reflect surviving history. Compare with the pre-test baseline. Allow legitimate concurrent activity and explain any difference; do not blindly reset totals to old numbers.
6. If testing changed the episode's watched flag, restore the recorded value through the supported UI or `PATCH /api/stats/media/<videoId>/watched` with `{"watched":false}` or `true` as recorded. Preserve existing library entries and personal history.
7. If aggregates remain wrong, record the mismatch and inspect the maintenance implementation. Do not use a broad lifetime repair as a substitute for session deletion. Recompute or repair only through the current supported app path when justified, then repeat the affected checks. Report an unresolved mismatch as incomplete cleanup.
8. Restore temporary settings and close test-owned windows/processes. Leave the newly installed app in place. Keep evidence until the result is reported. Never claim cleanup succeeded solely from an HTTP 200 or a cleared UI list.

The production deletion path currently lives in:

- `stats/src/lib/api-client.ts`
- `src/core/services/stats-server/library-routes.ts`
- `src/core/services/immersion-tracker-service.ts`
- `src/core/services/immersion-tracker/query-delete-maintenance.ts`
- `src/core/services/immersion-tracker/lifetime.ts` and `lexical-rollups.ts`

Read these when deletion or recomputation behavior is uncertain. Use `docs-site/immersion-tracking.md`, `docs-site/character-dictionary.md`, and `docs-site/anki-integration.md` for current app behavior.

## Report

Report the installed artifact/build, selected video, behavior exercised, observed pass/fail evidence, and blockers. Include exact deleted Anki note IDs and stats session IDs, aggregate verification results, restored settings, and the journal/evidence location. Explicitly identify any artifacts or changed state that remain. Keep claims limited to the flows actually exercised.
