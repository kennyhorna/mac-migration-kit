# Secrets, SSH keys and licenses

Two setups, both fine. Pick the one you use and skip the other.

- **Password manager with an SSH agent** (1Password, Secretive, …): keys never touch the new Mac's disk.
- **Plain SSH key files** with passphrases: the common setup, and perfectly good.

## Inventory first

Find every secret before you copy anything:

```bash
ls -la ~/.ssh
grep -rl -E '(API_KEY|TOKEN|SECRET|PASSWORD)=' ~/.zshrc ~/.zprofile ~/.config 2>/dev/null
find ~/Code -maxdepth 2 -name '.env' -not -path '*/node_modules/*'
ls ~/.aws ~/.kube ~/.docker/config.json ~/.npmrc ~/.composer/auth.json 2>/dev/null
```

Typical finds: SSH keys, cloud CLI credentials, `.env` files per project, package registry tokens (npm, Composer, Docker), and API keys exported in shell config.

**Never copy these with a plain `scp` to a shared machine, and never commit them.** Use a password manager, an encrypted volume, or a direct cable copy between your own machines.

## SSH keys: bring only the ones you use

Old `~/.ssh` folders accumulate keys nobody accepts any more. `bin/ssh-audit` finds out which still work:

- Tests each key against GitHub and GitLab, reporting the account it authenticates as
- Reads "last used" dates from the GitHub/GitLab APIs when their CLIs are logged in
- Optionally probes servers you name, reporting which key each account accepts
- Flags duplicate public keys, passphrase-less keys and keys referenced in `~/.ssh/config` that don't exist

```bash
bin/ssh-audit                        # git hosts only
bin/ssh-audit --hosts user@host,...  # also probe servers you have access to
```

**Reading the results:** a key accepted nowhere and never used is a key you can retire. Move retired keys to a backup folder first; delete them only once the new Mac has run for a while.

**File access times are useless on macOS for this.** They don't update reliably, so a key "last accessed in 2022" may be in daily use.

**If you probe servers:** many refuse repeated failed attempts (fail2ban), so offer all keys in **one** connection, note which one the server accepts, then repeat without it. That keeps failures to about one per account. `bin/ssh-audit` does this.

### Moving the keys you keep

**Password manager:** import each key into it, enable the SSH agent, and point `~/.ssh/config` at it. Nothing to copy at all:

```
Host *
    IdentityAgent "~/Library/Group Containers/<manager-agent-socket>"
```
Select a specific key for a specific host with its **public** key file plus `IdentitiesOnly yes`.

**Plain files:** copy `~/.ssh` over the cable (never through cloud storage), then fix permissions:

```bash
chmod 700 ~/.ssh && chmod 600 ~/.ssh/id_* && chmod 644 ~/.ssh/*.pub
```

Either way, clean `~/.ssh/config` while you're at it. Host entries pointing at keys that no longer exist, or aliases you never use, are noise. Verify afterwards:

```bash
ssh -T git@github.com
ssh -T git@gitlab.com
git -C ~/some/repo pull
```

## `.env` files and other ignored-but-essential files

Each `.env` is unique to the machine and excluded from git, so it's lost if you only re-clone.

- **A handful:** store each as a document/secure note in your password manager, or copy them over the cable with the project.
- **Many:** copy the project folders (`.env` files ride along), and keep the important ones in the password manager as backup.

A password manager CLI makes this repeatable. Store a template in your dotfiles that contains **references**, not values:

```
API_KEY={{ op://Private/service-name/credential }}
```
and render it at setup time. `templates/dotfiles/secrets.env.tpl` shows the pattern. Without a manager, keep them in an encrypted disk image and copy manually.

**Shell exports:** move any `export SOME_API_KEY=...` out of `.zshrc` into a machine-local file (`~/.dotfiles-custom/secrets.zsh`, `chmod 600`) that your `.zshrc` sources if present.

## Cloud and CLI credentials

| Tool | What to do |
|---|---|
| AWS with SSO | Copy `~/.aws/config` (no secrets in it). Run `aws sso login` on the new Mac. Don't copy `~/.aws/sso/cache` |
| AWS with long-lived keys | `~/.aws/credentials` is a secret; move it like any other, or better, switch to SSO |
| gcloud / az | Re-run their login commands |
| GitHub / GitLab CLI | `gh auth login`, `glab auth login` |
| Docker registries | `docker login` again; don't copy `~/.docker/config.json` |
| npm, Composer, private registries | Tokens in `~/.npmrc`, `~/.composer/auth.json`. Treat as secrets; needed before installing private packages |
| Kubernetes | `~/.kube/config` often contains tokens; re-generate where you can |

Also delete stale credential files while you're here. Expired temporary credentials from tools you no longer use are just clutter.

## Licenses

Check every paid app **before** wiping the old Mac:

- **Account-based:** sign in on the new Mac. Nothing to do.
- **Key-based:** make sure the key is in your password manager. If you can't find it, the vendor's account page or the original purchase email has it.
- **Device-bound:** deactivate on the old Mac (often in the app's licence screen), then activate on the new one. The activation file on disk is not portable; copying it achieves nothing.
- **Company-provided licenses:** the key may not be in your possession at all. Ask whoever administers it early, because it can take days.

## After the migration

1. Remove any temporary transfer key from both machines.
2. Rotate anything that was exposed in the process (a key that briefly sat in a plain file, a token in a screenshot).
3. Delete plaintext secret files you created for the move, once the new Mac works.
4. Keep passphrases for export files (database client exports, launcher backups) in your password manager: those archives are useless without them.
