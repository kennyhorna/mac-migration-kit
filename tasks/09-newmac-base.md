PHASE: New Mac
- [ ] Run Setup Assistant **without** Migration Assistant; enable FileVault
- [ ] `xcode-select --install`
- [ ] Install and sign in to your password manager; enable its SSH agent {{manager}}
- [ ] {{files}} Copy your SSH keys over and fix permissions (`chmod 700 ~/.ssh`, `600` for keys)
- [ ] Verify git access: `ssh -T git@github.com` (and any other host you use)
- [ ] Clone your dotfiles repo and run its install script
