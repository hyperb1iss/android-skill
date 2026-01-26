# Android Plugin - Skill Map

**Philosophy:** 4 skills. Progressive disclosure. Start simple, go deep when needed.

---

## The 4 Skills

### 1. `android` - Working with Android Devices
**The big one.** ADB, debugging, system exploration - all device interaction.

**Triggers:** "adb", "device", "install app", "logcat", "crash", "debug", "screenshot", "shell"

### 2. `android-bootloader` - Danger Zone
**Fastboot, flashing, recovery.** Kept separate because mistakes brick devices.

**Triggers:** "fastboot", "flash", "unlock bootloader", "recovery", "partition"

### 3. `android-build` - Building Android
**Gradle for apps, AOSP for ROMs.**

**Triggers:** "build", "Gradle", "AOSP", "lunch", "compile", "device tree"

### 4. `lineageos` - LineageOS Development
**LineageOS-specific workflow.** Separate because it has distinct patterns.

**Triggers:** "LineageOS", "breakfast", "brunch", "repopick", "lineage.dependencies"

---

## Directory Structure

```
android-skill/
├── .claude-plugin/plugin.json
├── skills/
│   ├── android/
│   │   ├── SKILL.md
│   │   └── references/deep-dive.md
│   ├── android-bootloader/
│   │   ├── SKILL.md
│   │   └── references/partitions.md
│   ├── android-build/
│   │   ├── SKILL.md
│   │   └── references/aosp.md, lineageos.md
│   └── lineageos/
│       ├── SKILL.md
│       └── references/gerrit-workflow.md
├── agents/
│   └── crash-analyzer.md
├── Makefile
├── README.md
└── LICENSE
```

---

## Stats

| Skill | Lines |
|-------|-------|
| android | 374 + 433 refs |
| android-bootloader | 317 + 272 refs |
| android-build | 380 + 706 refs |
| lineageos | 311 + 179 refs |
| crash-analyzer agent | 138 |
| **Total** | ~3,175 |

---

## Development

```bash
make check    # Validate structure
make lint     # Run linters
make format   # Format with prettier
make stats    # Show statistics
```
