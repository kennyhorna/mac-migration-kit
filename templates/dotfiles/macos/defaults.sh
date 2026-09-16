#!/usr/bin/env bash
# macOS settings. Safe to re-run. Adapt to taste — these are examples, not recommendations.
#
# To find the key for a setting you changed:
#   defaults read > /tmp/before.txt   # change it in System Settings
#   defaults read > /tmp/after.txt && diff /tmp/before.txt /tmp/after.txt
#
# Not scriptable, do by hand: privacy permissions (Accessibility, Screen Recording, Full Disk
# Access), display arrangement, Touch ID, anything your company's device management controls.
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"

echo "== Dock"
defaults write com.apple.dock orientation -string left      # left | bottom | right
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock tilesize -int 38
defaults write com.apple.dock show-recents -bool false

if command -v dockutil >/dev/null; then
  dockutil --remove all --no-restart
  for app in "/Applications/Safari.app" "/System/Applications/Calendar.app"; do
    [ -d "$app" ] && dockutil --add "$app" --no-restart
  done
fi

echo "== Finder"
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder FXPreferredViewStyle -string Nlsv     # list view
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

echo "== Keyboard"
# Caps Lock → Command. This is stored PER KEYBOARD, keyed by vendor/product id, and those ids
# differ between Macs — so map every keyboard attached right now. Re-run after plugging a new one in.
# 0x700000039 = Caps Lock · 0x7000000E7 = Right Command · 0x7000000E0 = Left Control
CAPS_LOCK=30064771129
TARGET=30064771303
# `hidutil list --matching '{...}'` is ignored on some macOS builds, so filter the columns instead:
hidutil list 2>/dev/null \
  | awk '$1 ~ /^0x/ && $1 != "0x0" && $4 == 1 && $5 == 6 {print $1, $2}' | sort -u \
  | while read -r vendor product; do
      defaults -currentHost write -g "com.apple.keyboard.modifiermapping.$((vendor))-$((product))-0" -array \
        "<dict><key>HIDKeyboardModifierMappingSrc</key><integer>$CAPS_LOCK</integer><key>HIDKeyboardModifierMappingDst</key><integer>$TARGET</integer></dict>"
      echo "  mapped keyboard $((vendor))-$((product))"
    done
# Apply immediately as well (the System Settings copy takes effect after logout)
hidutil property --set "{\"UserKeyMapping\":[{\"HIDKeyboardModifierMappingSrc\":$CAPS_LOCK,\"HIDKeyboardModifierMappingDst\":$TARGET}]}" >/dev/null

# Keyboard shortcuts, captured with:
#   defaults export com.apple.symbolichotkeys macos/symbolichotkeys.plist
if [ -f "$HERE/symbolichotkeys.plist" ]; then
  defaults import com.apple.symbolichotkeys "$HERE/symbolichotkeys.plist"
  /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u 2>/dev/null || true
fi

echo "== Trackpad"
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true         # tap to click
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# App preferences captured with `defaults export <domain> macos/apps/<name>.plist`.
# Import BEFORE the app's first launch: some apps write their defaults on first run.
for plist in "$HERE"/apps/*.plist; do
  [ -e "$plist" ] || continue
  domain=$(/usr/libexec/PlistBuddy -c 'Print' "$plist" >/dev/null 2>&1 && basename "$plist" .plist)
  echo "  import $domain"
  defaults import "$domain" "$plist" || echo "  ! could not import $domain"
done

killall Dock Finder 2>/dev/null || true
echo "Done. Log out and back in for keyboard and trackpad changes."
