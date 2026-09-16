# Troubleshooting

Real failures from real migrations, with the fix.

## The copy "succeeded" but the destination is empty

**Cause:** macOS's bundled `rsync` (openrsync) does nothing when the destination folder doesn't exist, and still exits 0 with a plausible summary (`Number of files transferred: 0`).

**Fix:** create destination folders first, or use a `tar` stream. Always verify. See [`docs/02-transport.md`](02-transport.md).

## Files are missing from a repo after copying, and git says they were deleted

**Cause:** an exclude pattern matched at every depth. `--exclude=vendor` also drops `public/vendor/...` and similar tracked folders.

**Fix:** anchor excludes (`--exclude=/vendor`), then compare `git status` on both machines and re-copy the gaps.

## Composer/npm install fails on a paid or private package

**Cause:** the credentials file (`~/.composer/auth.json`, `~/.npmrc`) didn't come across, or the package server needs VPN.

**Fix:** treat those files as secrets and restore them before installing. See [`docs/04-secrets.md`](04-secrets.md).

## "Your PHP version does not satisfy the requirement", but the site is pinned to a newer PHP

**Causes, in order of likelihood:**
1. The machine's **default** PHP differs from the old Mac. Set it explicitly.
2. The project is served under **several hostnames** and only one is pinned.
3. The restore step **didn't match the site name's case** and silently skipped it.
4. The PHP version the site needs **isn't installed**.

**Fix:** set the default version first, then re-pin the site, then restart the service. Note that a bare `php` in the terminal may not use the site's version; use the tool's wrapper.

## An installer keeps dirtying my dotfiles repo

**Cause:** installers append their lines to `~/.zshrc`/`~/.zprofile` when they don't find their own markers, and your file is a symlink into the repo.

**Fix:** keep the installer's exact block (markers included) in your file and remove your hand-written equivalent. See [`docs/03-dotfiles.md`](03-dotfiles.md).

## Only the first item of a scripted loop gets installed

**Cause:** a command inside a `while read` loop (`npx`, `ssh`, `ffmpeg`, …) consumes the loop's stdin, so the loop ends after one iteration.

**Fix:** redirect that command's stdin: `npx … < /dev/null`, or `ssh -n`.

## My tool re-wrote its own "what to install" list, and now it's short

**Cause:** a setup script that installs from a list and then writes the list back from local state. After a partial run, the list shrinks and later runs think there's nothing to do.

**Fix:** keep the list in your repo as the source of truth; never write it back automatically. Restore it with `git checkout <file>`.

## Browser sync restored my spaces but not my profiles

**Cause:** browser sync doesn't sync profiles, and encrypted per-device data (cookies, logins) can never move.

**Fix:** re-create profiles, re-assign spaces/windows, re-install extensions and sign in again. Export bookmarks as HTML from the old browser first: if pinned tabs or bookmarks come back incomplete, import the HTML and move the items where they belong. See [`docs/06-apps.md`](06-apps.md).

## Database client has my connections but no passwords

**Cause:** passwords are in the Keychain, not in the connection file.

**Fix:** use the app's export-with-passwords feature (and keep its passphrase in your password manager), or re-enter each password.

## SSH works in the terminal but not from a GUI app

**Cause:** apps started from the Dock don't read your shell config, so an agent configured in `~/.ssh/config` isn't picked up by apps that look at `SSH_AUTH_SOCK` instead.

**Fix:** set that variable for GUI apps (your password manager's docs describe how), or point the app at a key file.

## The temporary transfer connection keeps dropping

**Cause:** the link-local address changes when the cable is unplugged, and the interface takes a few seconds to come up.

**Fix:** re-read the address (`arp -a | grep 169.254`), wait a moment after plugging in, and re-run. Scripts should be resumable: `tar` streams and `rsync --partial` can simply be run again.

## An app is running on defaults even though I imported its preferences

**Cause:** it was launched before the import, and wrote its own defaults.

**Fix:** quit the app, `defaults import <domain> <file>`, then reopen. Import **before** first launch when you can.

## `swift build` (or any build) works, but there's no app bundle

**Cause:** the `.app` is assembled by a project script (which may also create the `~/Applications` symlink), not by the plain build command.

**Fix:** look for a build script in the repo and run that instead.

## Homebrew refuses to install a cask because the app exists

**Fix:** `brew install --cask --adopt <name>` lets Homebrew take over the app you installed by hand.

## A tap fails to install

**Cause:** the tap was merged into Homebrew itself or retired.

**Fix:** remove it from your Brewfile. If its folder contains only a README, it's obsolete.
