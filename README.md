# Android Skill Plugin

A comprehensive Claude Code plugin for Android development - from app debugging to custom ROM building.

## Skills

### `android` - Device Mastery

Everything about interacting with Android devices via ADB:

- Device connection (USB, wireless, multi-device)
- Shell commands and file operations
- App management (install, start, stop, permissions)
- UI automation (tap, swipe, input, screenshots)
- Debugging (logcat, crashes, memory, performance)
- System inspection (dumpsys, getprop, /proc)

### `android-bootloader` - Danger Zone

Fastboot and bootloader operations (with safety warnings):

- Fastboot commands (flash, erase, boot, getvar)
- Bootloader unlocking/locking
- A/B slots and dynamic partitions
- Recovery operations (TWRP, sideload)
- Magisk/root installation
- Brick prevention

### `android-build` - Building Android

Both app and ROM building:

- Gradle CLI for app builds
- SDK management (sdkmanager, avdmanager)
- AOSP build system (envsetup, lunch, m)
- Device tree structure
- Kernel building

### `lineageos` - Custom ROM Development

LineageOS-specific development:

- Source syncing and building (breakfast, brunch)
- Device trees for LineageOS
- repopick and Gerrit workflow
- Vendor blob extraction
- Contributing to LineageOS

## Agents

### `crash-analyzer`

Autonomous crash investigation - collects logs, tombstones, ANR traces and provides diagnosis.

## Installation

```bash
# Clone
git clone https://github.com/your-username/android-skill.git

# Test locally
claude --plugin-dir ./android-skill
```

## Development

```bash
# Validate structure
make check

# Run linters
make lint

# Format files
make format

# Show stats
make stats
```

## Usage Examples

Once installed, the skills activate automatically based on context:

```
> Connect to my Android device wirelessly
[android skill activates]

> Flash the boot image
[android-bootloader skill activates]

> Build LineageOS for my device
[lineageos skill activates]
```

## Structure

```
android-skill/
├── .claude-plugin/
│   └── plugin.json
├── skills/
│   ├── android/
│   │   ├── SKILL.md
│   │   └── references/
│   ├── android-bootloader/
│   │   ├── SKILL.md
│   │   └── references/
│   ├── android-build/
│   │   ├── SKILL.md
│   │   └── references/
│   └── lineageos/
│       ├── SKILL.md
│       └── references/
└── agents/
    └── crash-analyzer.md
```

## License

MIT
