# Android Deep Dive Reference

Extended reference for advanced Android device operations.

---

## Advanced Logcat

### Buffer Selection

```bash
adb logcat -b main       # App logs (default)
adb logcat -b system     # System logs
adb logcat -b crash      # Crashes only
adb logcat -b radio      # Telephony
adb logcat -b events     # System events
adb logcat -b kernel     # Kernel (like dmesg)
adb logcat -b all        # Everything
```

### Output Formats

```bash
adb logcat -v brief      # Tag and priority
adb logcat -v time       # With timestamps
adb logcat -v threadtime # Time + PID + TID (recommended)
adb logcat -v long       # Full metadata
adb logcat -v color      # Colorized
```

### Advanced Filtering

```bash
# Multiple tags
adb logcat "ActivityManager:I MyApp:D *:S"

# By UID
adb logcat --uid=10123

# Since timestamp
adb logcat -T "01-25 14:00:00.000"

# Clear buffer
adb logcat -c
```

---

## Comprehensive dumpsys

### Activity Manager (Most Used)

```bash
adb shell dumpsys activity activities    # Activity stacks
adb shell dumpsys activity services      # Running services
adb shell dumpsys activity broadcasts    # Broadcast queues
adb shell dumpsys activity processes     # Process list
adb shell dumpsys activity recents       # Recent tasks
adb shell dumpsys activity top           # Current activity
adb shell dumpsys activity lastanr       # Last ANR
adb shell dumpsys activity package <pkg> # Per-package info
adb shell dumpsys activity exit-info     # Exit reasons (Android 11+)
```

### Package Manager

```bash
adb shell dumpsys package <pkg>          # Full package dump
adb shell dumpsys package packages       # All packages
adb shell dumpsys package permissions    # Permission definitions
adb shell dumpsys package features       # Device features
adb shell dumpsys package dexopt         # DEX optimization state
```

### Battery & Power

```bash
adb shell dumpsys battery                # Current status
adb shell dumpsys batterystats           # Detailed stats
adb shell dumpsys batterystats --charged # Since last charge
adb shell dumpsys power                  # Wake locks
adb shell dumpsys deviceidle             # Doze state
```

### Network

```bash
adb shell dumpsys connectivity           # Network state
adb shell dumpsys wifi                   # WiFi details
adb shell dumpsys netstats               # Network usage
```

### Graphics & Performance

```bash
adb shell dumpsys gfxinfo <pkg>          # Frame stats
adb shell dumpsys gfxinfo <pkg> framestats  # Detailed timing
adb shell dumpsys meminfo <pkg>          # Memory breakdown
adb shell dumpsys procstats --hours 3    # Process stats
adb shell dumpsys cpuinfo                # CPU usage
```

### Other Useful Services

```bash
adb shell dumpsys notification           # Notifications
adb shell dumpsys alarm                  # Scheduled alarms
adb shell dumpsys location               # Location providers
adb shell dumpsys sensorservice          # Sensors
adb shell dumpsys input                  # Input devices
adb shell dumpsys display                # Display config
adb shell dumpsys usb                    # USB state
adb shell dumpsys dropbox                # System crash logs
```

---

## Process Debugging

### Process Inspection

```bash
adb shell ps -A                          # All processes
adb shell ps -A | grep <pkg>             # Filter by name
adb shell ps -T -p <pid>                 # Threads for PID
adb shell top -n 1 -s cpu                # Top by CPU
adb shell top -n 1 -s res                # Top by memory
```

### /proc Filesystem

```bash
# Process status
adb shell cat /proc/<pid>/status

# Memory maps
adb shell cat /proc/<pid>/maps

# Open file descriptors
adb shell ls -la /proc/<pid>/fd

# Command line
adb shell cat /proc/<pid>/cmdline

# System memory
adb shell cat /proc/meminfo

# CPU info
adb shell cat /proc/cpuinfo
```

---

## Performance Profiling

### Heap Dumps

```bash
# Java heap (for Android Studio / MAT)
adb shell am dumpheap <pid> /sdcard/heap.hprof
adb pull /sdcard/heap.hprof
hprof-conv heap.hprof heap-converted.hprof

# Native heap (requires root)
adb shell am dumpheap -n <pid> /sdcard/native.hprof
```

### Method Tracing

```bash
adb shell am profile start <pkg> /sdcard/profile.trace
# ... perform actions ...
adb shell am profile stop <pkg>
adb pull /sdcard/profile.trace
```

### GPU Profiling

```bash
adb shell dumpsys gfxinfo <pkg>
adb shell dumpsys gfxinfo <pkg> framestats

# Enable overdraw visualization
adb shell setprop debug.hwui.overdraw show

# GPU debug layers (Vulkan)
adb shell settings put global enable_gpu_debug_layers 1
adb shell settings put global gpu_debug_app <pkg>
```

### Perfetto/Systrace

```bash
# Record system trace
adb shell perfetto --txt -c /etc/perfetto/configs/sched_trace.pbtxt \
    -o /data/misc/perfetto-traces/trace.perfetto-trace
adb pull /data/misc/perfetto-traces/trace.perfetto-trace
# Open at https://ui.perfetto.dev
```

---

## Crash Analysis

### Tombstones (Native Crashes)

```bash
adb shell ls -la /data/tombstones/
adb shell cat /data/tombstones/tombstone_00
adb pull /data/tombstones/
```

**Key sections:**
- Signal (SIGSEGV, SIGABRT, etc.)
- Fault address
- Register state
- Backtrace

### Symbolication

```bash
ndk-stack -sym /path/to/symbols -dump tombstone_00
adb logcat | ndk-stack -sym /path/to/symbols
```

### ANR Analysis

```bash
adb shell cat /data/anr/traces.txt      # Older devices
adb shell cat /data/anr/anr_*           # Newer devices
```

Look for:
- Main thread state
- Lock contention
- Long operations on main thread

### DropBox Entries

```bash
adb shell dumpsys dropbox
adb shell dumpsys dropbox --print data_app_crash
adb shell dumpsys dropbox --print data_app_anr
```

---

## Network Debugging

### Connection Info

```bash
adb shell cat /proc/net/tcp
adb shell cat /proc/net/udp
adb shell netstat -an                   # If available
adb shell ss -tunap                     # Modern alternative
```

### Proxy Setup

```bash
adb shell settings put global http_proxy <ip>:<port>
adb shell settings put global http_proxy :0  # Remove
```

### Packet Capture

```bash
adb shell tcpdump -i any -w /sdcard/capture.pcap
adb pull /sdcard/capture.pcap
# Open in Wireshark
```

---

## UI Automation Advanced

### All Keycodes

```bash
# Navigation
KEYCODE_DPAD_UP=19, DOWN=20, LEFT=21, RIGHT=22, CENTER=23

# Media
KEYCODE_MEDIA_PLAY_PAUSE=85, NEXT=87, PREVIOUS=88
KEYCODE_VOLUME_MUTE=164

# System
KEYCODE_WAKEUP=224, KEYCODE_SLEEP=223
KEYCODE_APP_SWITCH=187 (Recent apps)
KEYCODE_SYSRQ=120 (Screenshot)
```

### Long Press

```bash
# Simulate long press with swipe of 0 distance
adb shell input swipe 500 500 500 500 1000
```

### Text with Special Characters

```bash
# Escape spaces
adb shell input text "hello%sworld"  # %s = space

# For complex text, use keyboard broadcast
adb shell am broadcast -a ADB_INPUT_TEXT --es msg "Hello World!"
```

### Window Manager

```bash
adb shell wm size                       # Screen size
adb shell wm density                    # DPI
adb shell wm size 1080x1920             # Override size
adb shell wm size reset                 # Reset

adb shell wm overscan 0,0,0,200         # Add overscan
```

---

## Content Providers

```bash
# Query
adb shell content query --uri content://settings/system

# Insert
adb shell content insert --uri content://settings/system \
    --bind name:s:my_setting --bind value:s:my_value

# Update
adb shell content update --uri content://settings/system \
    --where "name='my_setting'" --bind value:s:new_value

# Delete
adb shell content delete --uri content://settings/system \
    --where "name='my_setting'"

# Common URIs
content://contacts/people
content://sms/inbox
content://settings/system
content://settings/secure
content://settings/global
```

---

## Service Calls

```bash
adb shell service list                  # List services
adb shell service call <service> <code> # Call service method
```

### cmd Interface (Android 8+)

```bash
adb shell cmd -l                        # List services
adb shell cmd package list packages
adb shell cmd activity start -n <component>
adb shell cmd statusbar expand-notifications
adb shell cmd battery set level 50
```

---

## Developer Options via ADB

```bash
# Stay awake while charging
adb shell settings put global stay_on_while_plugged_in 3

# Show touches
adb shell settings put system show_touches 1

# Pointer location
adb shell settings put system pointer_location 1

# Animation scales (0 = off, good for testing)
adb shell settings put global window_animation_scale 0
adb shell settings put global transition_animation_scale 0
adb shell settings put global animator_duration_scale 0

# Force GPU rendering
adb shell settings put global force_gpu true
```

---

## Emulator-Specific

```bash
# Telnet to emulator console
telnet localhost 5554

# In console:
sms send 5551234567 "Hello"
geo fix -122.084 37.422
power capacity 50
network speed gsm
```

---

## Quick Diagnostics Script

```bash
#!/bin/bash
# android-diag.sh - Quick device diagnostics

echo "=== Device Info ==="
adb shell getprop ro.product.model
adb shell getprop ro.build.version.release

echo "=== Memory ==="
adb shell cat /proc/meminfo | head -5

echo "=== Storage ==="
adb shell df -h /data

echo "=== Battery ==="
adb shell dumpsys battery | grep -E "level|status|health"

echo "=== Top Processes ==="
adb shell top -n 1 -m 5 -s res

echo "=== Recent Crashes ==="
adb logcat -b crash -d -t 10 2>/dev/null || echo "No recent crashes"
```
