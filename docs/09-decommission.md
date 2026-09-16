# Decommissioning the old Mac

Don't rush this. The old machine is your backup until the new one has carried real work for a while.

## Wait about two weeks

Use the new Mac for everything. The gaps surface when you need something you haven't touched yet: an old project, a VPN profile, a licence, a script in a folder nobody thought about.

Keep the old Mac charged, updated and reachable. Don't "tidy it up" in the meantime.

## Before wiping: the final sweep

Find anything created or changed since the transfer:

```bash
# marker file created at transfer time; otherwise use a date
find ~ -newer ~/.migration-marker -type f \
     -not -path '*/Library/*' -not -path '*/.git/*' -not -path '*/node_modules/*' \
     -not -path '*/.Trash/*' 2>/dev/null | head -50
```

Also re-check the things that change quietly:

```bash
bin/repo-report                         # new uncommitted work in ~/Code
ls -lt ~/Downloads | head               # anything downloaded since
ls -lt ~/Desktop | head
```

Then confirm you can open, on the **new** Mac: your notes, your password manager, your main projects, and one thing from each app that mattered.

## Deauthorize and sign out

1. **App licences:** deactivate device-bound ones (they have a limited number of seats).
2. **Password manager:** sign out, and remove the old device in your account settings.
3. **Sign out of your Apple Account** (System Settings → your name → Sign Out) and of Messages/FaceTime if used.
4. **Browsers:** sign out of profiles so the device disappears from your sync list.
5. **Find My / device management:** on a company Mac this is usually IT's job; don't unenroll it yourself.
6. **2FA apps and passkeys:** make sure every code and passkey is available on another device **before** wiping.

## Wipe

- **Personal Mac:** System Settings → General → Transfer or Reset → **Erase All Content and Settings**.
- **Company Mac:** follow IT's process. They may require a specific wipe method, or want the machine untouched for their own tooling. Ask before erasing anything.

## Keep the artifacts

After the machine is gone, keep:

- Your **dotfiles repo**, with the migration plan and notes in it
- The **archives** of old projects
- **App export files** and their passphrases in your password manager
- A short note of anything that surprised you

Next migration starts from a working `bin/install` and a plan that already knows your setup.
