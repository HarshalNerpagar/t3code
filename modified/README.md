# T3 Code Modified

Official T3 Code plus a few personal tweaks. It always tracks the latest official code.

## How it works

```
pingdotgg/t3code (official)  →  main      (exact mirror, never edited)
                                   ↓ rebase
                                my-build   (official + your "mod:" commits)
                                   ↓ modified/build.sh
                     /Applications/T3 Code Modified.app
```

- **Same data as the official app.** Both apps use `~/.t3/userdata`, so you get the same threads,
  projects, settings, and provider logins. Only one of them can run at a time; the app's own
  single-instance lock enforces this.
- **No auto-update.** The modified app is built without an update feed, so it never replaces itself
  with the stock nightly or downloads anything. You update it with `modified/update.sh`.
- **Keep the official T3 Code (Nightly) installed** as a fallback. It keeps auto-updating as usual.
- **Backups.** Before each install, `~/.t3/userdata/statev2.sqlite` is copied to
  `~/.t3/modified-backups/` (last 2 kept).

## Day to day

| I want to…                                       | Do this                                                                                          |
| ------------------------------------------------ | ------------------------------------------------------------------------------------------------ |
| Get the latest official updates (with my tweaks) | Run `modified/update.sh`, quit T3 Code, double-click `modified/Install T3 Code Modified.command` |
| Make a new tweak                                 | In the "T3 Code Modified" project, ask Claude for it. It commits it as `mod: …` on `my-build`    |
| Preview a tweak before installing                | `vp run dev:desktop` (uses separate dev data)                                                    |
| Install after a tweak                            | Run `modified/build.sh`, quit T3 Code, double-click the `.command` file                          |
| Go back to the stock app                         | Quit Modified, open T3 Code (Nightly)                                                            |
| See my tweaks                                    | `git log --oneline upstream/main..my-build`                                                      |

If `update.sh` says a modification conflicts, nothing has changed. Ask Claude to "update from upstream
and resolve the rebase conflicts".

The first time you open the modified app, macOS may ask for keychain access for "T3 Code Nightly
Safe Storage". Click **Always Allow**. This happens because local builds aren't signed by T3.

## Modifications

<!-- One line per mod: commit, what it does. -->

_None yet._
