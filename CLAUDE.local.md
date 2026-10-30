# T3 Code Modified (personal fork)

This checkout is a personal fork of official T3 Code (`pingdotgg/t3code`) with a few small
tweaks for one user's workflow. It is not meant for upstream PRs. `AGENTS.md` still applies,
but these fork rules override it where they conflict. Read `modified/README.md` for how syncing works.

## Branches and remotes

- `upstream` = official pingdotgg/t3code. `origin` = the user's fork (HarshalNerpagar/t3code).
- `main` mirrors `upstream/main` exactly. Never commit to it.
- `my-build` = official code + the user's modifications as a small stack of commits on top.
  All modification work goes here (or in a worktree branched from it, then merged back into it).

## Rules for modifications

1. **Keep every change small and isolated.** Upstream merges hundreds of PRs a week, and every
   modification is replayed onto it with `git rebase`. Touch as few files and lines as possible,
   and prefer adding a new file and importing it over rewriting existing code.
2. **One modification = one commit**, message prefixed `mod:`, for example `mod: wider sidebar`.
   Amend or fixup that commit when refining the same tweak, so `git log upstream/main..my-build`
   stays a readable list of modifications.
3. **No database migrations or schema changes, and no contract/wire changes.** The fork shares the
   user's live `~/.t3/userdata` database with the official app, so a fork-only migration would
   corrupt migration history when switching back. Stick to UI, styling, and client-side behavior.
4. **Never touch the live data.** Do not start dev servers against `~/.t3/userdata`, and do not edit
   it. `vp run dev` / `vp run dev:desktop` use `~/.t3/dev` and are the way to try changes.
5. **Never change update, signing, telemetry, auth, or network-origin code.** The installed build
   has no update feed by design (`-preview` version, no publish config); keep it that way.
6. After each modification, record it in the "Modifications" list in `modified/README.md`.

## Commands

- Try a change live: `vp run dev:desktop` (separate dev data; safe to run alongside the real app).
- Typecheck/tests for touched packages: see `AGENTS.md`.
- Sync with official + build + install: `modified/update.sh`
- Build + install only: `modified/build.sh`

`vp` lives in `~/.local/share/vite-plus/bin`; the scripts add it to PATH themselves. In an ad-hoc
shell, **including before any `git commit`**, run
`export PATH="$HOME/.local/share/vite-plus/bin:$HOME/.local/share/vite-plus/fallback-bin:$PATH"`.
It is deliberately not in the user's `.zshrc`. Without it the shell uses nvm's older Node and the
pre-commit hook fails. If a commit fails, check `git log` before pushing; don't use `--no-verify`.

## Resolving rebase conflicts during an update

When `modified/update.sh` reports a conflict: run `git rebase upstream/main`, and for each
conflicting `mod:` commit, re-apply the _intent_ of the tweak to the new upstream code (upstream may
have moved or rewritten it), `git add`, `git rebase --continue`. Then typecheck, push with
`git push --force-with-lease origin my-build`, and run `modified/build.sh`. If a tweak is now
obsolete because upstream shipped something equivalent, drop that commit and tell the user.
