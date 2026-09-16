# Apps: what syncs, what exports, what you re-do

Every app falls into one of four patterns. Identify which, and the work becomes obvious.

1. **Account sync.** Sign in, everything returns.
2. **Export/import.** The app makes a file; you carry it and import it.
3. **Config folder.** Copy a folder or plist, ideally before first launch.
4. **Re-do by hand.** Nothing is portable.

Below, the apps that commonly cause trouble.

## Browsers

**Sync restores less than you think.** Browser sync typically covers bookmarks, open tabs and settings, but **not profiles themselves**, and never the encrypted parts.

- **Profiles:** if you keep several (work, personal, client), expect to re-create them on the new Mac and re-assign spaces/windows to them. Note which spaces belonged to which profile **before** you start.
- **Pinned tabs / bookmarks:** verify the count after syncing. It's common to find part of them missing. Export as an HTML bookmarks file from the old browser as a safety net, since every browser can import that format.
- **Cookies, sessions and saved passwords:** encrypted per device. You will sign in to everything again. Use a password manager and it's quick.
- **Extensions:** re-installed per profile; their own settings usually don't sync.

**Before switching:** write down (or screenshot) your profile list, which spaces/windows belong to which profile, and the extensions per profile.

## IDEs and editors

**JetBrains IDEs** have built-in settings sync tied to your account. On the new machine, install the IDE, sign in, then **explicitly choose to take settings *from* the account**. Don't let a fresh install push its defaults up. The first dialog offers both directions; pick "get".

Database connections sync, but **their passwords live in the Keychain**, so re-enter them. Plugin licenses follow your account.

Take a local backup of the old machine's settings folder before you start, as an escape hatch:
```bash
tar -czf ~/jetbrains-settings.tar.gz -C ~/Library/Application\ Support/JetBrains/<IDE><version> options keymaps codestyles colors templates
```

**VS Code / Cursor:** Settings Sync via GitHub or Microsoft account covers settings, keybindings, snippets and extensions. Verify extensions finish installing before judging the result.

**Zed, Sublime and similar:** plain config files. Put them in your dotfiles and symlink.

## Terminals

- **iTerm2:** point it at a settings folder in your dotfiles (Settings → General → Settings → "Load settings from a custom folder"), then set "Save changes" to automatically. **Do this from a second terminal app with iTerm quit**, or the running instance can overwrite the folder with defaults on exit. If both Macs write to the same file in git, decide which machine owns it.
- **Ghostty, Alacritty, Kitty, WezTerm:** single config file, version it.
- **Warp / Apple Terminal:** account sync and profile export respectively.

**Shell history** is a plain file. Merge rather than overwrite:
```bash
cat ~/.zsh_history.from-old-mac ~/.zsh_history > /tmp/merged && mv /tmp/merged ~/.zsh_history
```

## Database clients

The single most common data-loss point, because **connection passwords live in the Keychain**.

- Use the app's **export connections** feature and protect it with a passphrase (store the passphrase in your password manager). Import on the new Mac.
- Connections over SSH tunnels reference **key files by path**: make sure those keys exist on the new Mac, or point them at your password manager's agent.
- Take the chance to delete connections to servers that no longer exist.
- If the app's license is device-bound or company-provided, sort that out before you need the app.

## Launchers and utilities

- **Launchers (Raycast, Alfred):** export their settings to a file (usually password-protected), copy it over, import. Clipboard history is usually **not** included. They need Accessibility permission again.
- **Window managers, screenshot tools, keyboard tools:** most keep a preferences domain you can `defaults export` and `defaults import` **before first launch**. Screen-recording and Accessibility permissions must be granted again by hand.
- **Note apps:** account-synced ones need only a login. File-based ones (a vault of Markdown files) just need the folder copied, and that folder is worth putting in git or a sync service afterwards.

## Containers and VMs

- **Docker Desktop:** settings are trivial to redo; `docker login` for registries. **Images re-pull; named volumes do not move by themselves.**
- Decide per volume whether the data matters. Dev databases are usually re-seeded (`migrate --seed`), which is simpler and cleaner than moving volumes.
- If a volume does matter, export it while its container is stopped:
  ```bash
  docker run --rm -v "$VOL":/v -v "$PWD":/backup alpine tar czf "/backup/$VOL.tgz" -C /v .
  # restore on the new Mac
  docker volume create "$VOL"
  docker run --rm -v "$VOL":/v -v "$PWD":/backup alpine tar xzf "/backup/$VOL.tgz" -C /v
  ```
  `bin/docker-volumes` in this kit wraps both directions and refuses to export a volume whose container is running.

## Self-built and internal apps

If you build your own tools, they need a build on the new Mac, not a copy:

- Check for a build script in the repo (it may also create the `~/Applications` symlink). Running the language's plain build command can produce binaries without the app bundle.
- Xcode's command line tools, Rust toolchains and Node versions need to exist first.
- If another tool launches your app by absolute path (an MCP server, a launch agent), verify that path after building.

## Everything else

Make a list from `/Applications` and mark each as: **Brewfile**, **App Store**, **manual download**, or **drop it**. The apps you can't place are usually the ones you don't need.

```bash
ls /Applications | sed 's/\.app$//'
brew list --cask
mas list      # App Store apps, if you use mas
```
