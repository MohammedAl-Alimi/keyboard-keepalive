# keyboard-keepalive

A tiny macOS [LaunchAgent](https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPSystemStartup/Chapters/CreatingLaunchdJobs.html) that stops a wireless keyboard's RGB backlight from switching off when you stop typing.

Originally written for a **Redragon Wyvern Pro** in Bluetooth mode, whose backlight times out after 3 minutes of inactivity. It works for any keyboard with a similar idle timeout.

## How it works

A background loop checks the system-wide idle time (`HIDIdleTime` from `ioreg`) every 20 seconds. When idle reaches **2:45** — just before the keyboard's 3:00 timeout — it sends a single **silent Shift tap** (`key code 56`) through AppleScript's System Events. Shift on its own types nothing and triggers no shortcuts, so it resets the keyboard's idle timer without side effects.

```
idle ≥ 165s ?  ──yes─→  osascript: key code 56 (Shift)  ──→  keyboard idle timer resets
     │
     no → wait 20s, check again
```

Two knobs at the top of the script:

| Variable | Default | Meaning |
|---|---|---|
| `THRESHOLD` | `165` | Idle seconds before a tap fires. Keep it below your keyboard's timeout. |
| `CHECK_INTERVAL` | `20` | How often to poll idle time. |

## Install

```bash
# 1. Put the script in your home folder and make it executable
mv keyboard-keepalive.sh ~/keyboard-keepalive.sh
chmod +x ~/keyboard-keepalive.sh

# 2. Set your username in the plist, then install it
sed -i '' "s/REPLACE_WITH_YOUR_USERNAME/$(whoami)/g" com.local.keyboard-keepalive.plist
mv com.local.keyboard-keepalive.plist ~/Library/LaunchAgents/

# 3. Load it (starts now and at every login)
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.local.keyboard-keepalive.plist
```

Check it's running:

```bash
launchctl print gui/$(id -u)/com.local.keyboard-keepalive | grep -E "state|pid"
```

Or just run `./install.sh` from the repo, which does all of the above.

## ⚠️ Accessibility permission

Sending keystrokes requires macOS **Accessibility** permission. The prompt appears the **first time a tap actually fires** — i.e. after your machine has been genuinely idle for ~2:45, not at install time.

Grant it under **System Settings → Privacy & Security → Accessibility**. Because the agent runs as `/bin/bash`, the entry shows up as generic “bash” rather than a friendly app name. To grant it up front instead of waiting, add `/bin/bash` manually with the **+** button (⌘⇧G → `/bin`).

Until it's granted, the idle check still runs but the tap silently fails (errors are sent to `/dev/null`).

## Logs

```
/tmp/keyboard-keepalive.log   # stdout
/tmp/keyboard-keepalive.err   # stderr (should stay empty)
```

## Uninstall

```bash
launchctl bootout gui/$(id -u)/com.local.keyboard-keepalive
rm ~/Library/LaunchAgents/com.local.keyboard-keepalive.plist
rm ~/keyboard-keepalive.sh
```

## License

MIT
