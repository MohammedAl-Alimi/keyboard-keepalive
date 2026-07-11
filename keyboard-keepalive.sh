#!/bin/bash
# Keeps the Redragon Wyvern Pro RGB backlight from timing out in wireless/BT mode.
# Checks system-wide idle time, and if it's about to hit the 3-minute timeout,
# sends a single silent Shift key tap to reset the keyboard's idle timer.

THRESHOLD=165       # 2 minutes 45 seconds (in seconds) - fires before the 3:00 timeout
CHECK_INTERVAL=20   # how often to check idle time, in seconds

while true; do
    # HIDIdleTime is reported in nanoseconds, convert to whole seconds
    IDLE_TIME=$(ioreg -c IOHIDSystem | awk '/HIDIdleTime/ {print int($NF/1000000000); exit}')

    if [ -n "$IDLE_TIME" ] && [ "$IDLE_TIME" -ge "$THRESHOLD" ]; then
        # Silent tap of Shift alone (key code 56) - types nothing, triggers nothing
        osascript -e 'tell application "System Events" to key code 56' 2>/dev/null
    fi

    sleep "$CHECK_INTERVAL"
done
