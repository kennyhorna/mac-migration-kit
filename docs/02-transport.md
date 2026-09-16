# Transport: getting bytes from A to B

## Recommended: a USB-C or Thunderbolt cable between the two Macs

Plug the Macs into each other. macOS creates a private point-to-point network with no configuration and no Wi-Fi involved.

**Why this and not the alternatives:**

| Method | Speed for ~15 GB | Notes |
|---|---|---|
| Thunderbolt cable | a couple of minutes | Shows up as "Thunderbolt Bridge" |
| USB-C data cable | 10–25 minutes | Often negotiates 100 Mbit/s; still fine |
| Wi-Fi (same network) | 15–60 minutes | Blocked outright on many corporate and guest networks |
| External drive | slowest | You copy everything twice |
| AirDrop | fine for a few files | No resume, no verification, painful for folders |

A charge-only USB-C cable won't work; it must carry data.

### Set it up

1. Connect the cable to both Macs.
2. On the **destination** Mac: System Settings → General → Sharing → turn on **Remote Login**. Restrict it to your user.
3. Find the destination's address on the cable network. On either Mac:
   ```bash
   ipconfig getifaddr en5 2>/dev/null; ipconfig getifaddr bridge0 2>/dev/null   # your own address
   ping -c 2 169.254.255.255 >/dev/null; arp -a | grep 169.254                  # the other Mac
   ```
   Addresses on a direct link start with `169.254.`. They can change if you unplug and replug, so re-check after reconnecting.
4. Test: `ssh <user>@169.254.x.y`

### Use a temporary key, and remove it afterwards

Don't wire your everyday SSH key into a one-off transfer, especially if it lives in a password manager that will prompt for every connection.

```bash
# on the source Mac
ssh-keygen -t ed25519 -f ~/.ssh/migration_transfer -N '' -C "temporary migration key"
cat ~/.ssh/migration_transfer.pub
```

On the destination Mac, add it with restrictions so it only works over the cable:

```bash
mkdir -p ~/.ssh && chmod 700 ~/.ssh
echo 'from="169.254.0.0/16",no-agent-forwarding,no-X11-forwarding,no-port-forwarding ssh-ed25519 AAAA...' >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
```

When the migration is done: remove that line, turn **Remote Login** back off, and delete the key on the source Mac. `bin/transfer --cleanup` prints the exact commands.

## The pitfall that silently loses data

**macOS ships `openrsync` as `rsync`. It does nothing when the destination folder doesn't exist, and still exits 0.**

```
Number of files: 250
Number of files transferred: 0     ← notice this
sent 21594 bytes  received 20 bytes
```

You get a success message, a plausible-looking summary and an empty destination. If you don't check the destination, you find out weeks later.

**Two defences:**

1. **Create destination folders first**, then copy:
   ```bash
   ssh "$REMOTE" 'mkdir -p ~/Documents ~/Pictures ~/Code'
   ```
2. **Prefer a `tar` stream** for whole folders. It creates directories as it extracts, and it's faster for many small files:
   ```bash
   COPYFILE_DISABLE=1 tar -cf - -C ~/Pictures --exclude .DS_Store . \
     | ssh "$REMOTE" 'mkdir -p ~/Pictures && tar -xpf - -C ~/Pictures'
   ```

`bin/transfer` does both for you, and verifies afterwards.

Installing GNU rsync (`brew install rsync`) is another option, but only helps if it's on **both** machines.

## Excludes are matched at every depth

`--exclude=vendor` excludes **every** folder named `vendor`, not just the one at the top. That quietly drops tracked files like `public/vendor/...` or `resources/views/vendor/...` from real projects, and the repo then looks like files were deleted.

Anchor excludes to the transfer root:

```bash
rsync -a --exclude=/vendor --exclude=node_modules ~/Code/project/ "$REMOTE:Code/project/"
```

Then check the repo afterwards: `git status` should look the same on both machines.

## What to exclude, and what that costs

Leaving out dependency and build folders saves a lot of time:

| Folder | Rebuild with | Worth excluding |
|---|---|---|
| `node_modules` | `npm install` | Yes |
| `vendor` (top level) | `composer install` | Yes, but see [`docs/07-dev-environment.md`](07-dev-environment.md) about private package credentials |
| `.build`, `target`, `DerivedData` | a build | Yes, they're often the biggest folders |
| `.git` | nothing, **never exclude it** | No |
| `.env`, local SQLite files | nothing | No |

Rebuilding dependencies needs working toolchains and, for private packages, credentials. Plan for that before you delete anything on the old machine.

## Verify after every copy

```bash
bin/verify-copy ~/Pictures "$REMOTE" Pictures
```

It lists every file with its size on both sides and compares them as sets. Don't compare with `diff` on two sorted listings: the two Macs can sort filenames differently, which produces mismatches that aren't real.

For code, compare git state per repo (`bin/verify-copy --git ~/Code "$REMOTE" Code`): current commit, branches, stashes and modified files.

## If you can't use a cable

- **Same network:** same commands, using the LAN address. Check first that the two machines can reach each other; guest networks usually block it.
- **External drive:** format it as APFS (Encrypted) and copy in two steps. Verify both times.
- **Cloud storage:** fine for documents, bad for code, and it will mangle symlinks and file permissions.
