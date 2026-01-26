# Android Partition Reference

## Partition Types

### Boot Partitions

| Partition | Purpose | A/B Naming |
|-----------|---------|------------|
| `boot` | Kernel + ramdisk | `boot_a`, `boot_b` |
| `init_boot` | Init ramdisk (Android 13+) | `init_boot_a`, `init_boot_b` |
| `vendor_boot` | Vendor ramdisk (GKI) | `vendor_boot_a`, `vendor_boot_b` |
| `recovery` | Recovery (non-A/B only) | N/A on A/B devices |
| `dtbo` | Device tree overlay | `dtbo_a`, `dtbo_b` |
| `vbmeta` | Verified boot metadata | `vbmeta_a`, `vbmeta_b` |

### System Partitions (Dynamic on Android 10+)

| Partition | Purpose |
|-----------|---------|
| `super` | Container for dynamic partitions |
| `system` | Android OS |
| `system_ext` | System extensions |
| `vendor` | Vendor HALs and binaries |
| `product` | Product customizations |
| `odm` | ODM customizations |

### Data Partitions

| Partition | Purpose |
|-----------|---------|
| `userdata` | User data (apps, files) |
| `cache` | Cache (non-A/B) |
| `metadata` | Encryption metadata |
| `misc` | Bootloader communication |
| `persist` | Factory calibration data |

### Critical Partitions (⚠️ Careful!)

| Partition | Purpose | Risk |
|-----------|---------|------|
| `bootloader` | Device bootloader | Hard brick if wrong |
| `radio` / `modem` | Baseband firmware | Hard brick if wrong |
| `aboot` | Bootloader (older) | Hard brick |
| `sbl` | Secondary bootloader | Hard brick |
| `tz` | TrustZone | Hard brick |

---

## A/B (Seamless) Updates

Modern devices have two copies of key partitions for seamless updates.

### How It Works

1. System runs from slot A
2. Update installs to slot B (in background)
3. Reboot switches to slot B
4. If B fails, automatically falls back to A

### Commands

```bash
fastboot getvar current-slot           # a or b
fastboot getvar slot-count             # Usually 2
fastboot getvar slot-successful:a      # yes/no
fastboot getvar slot-retry-count:a     # Remaining attempts

fastboot set_active a                  # Switch to A
fastboot set_active b                  # Switch to B

fastboot --slot=all flash boot boot.img   # Flash both slots
fastboot --slot=other flash boot boot.img # Flash inactive slot
```

### Recovery on A/B

On A/B devices, recovery is part of `boot.img`, not a separate partition. To install custom recovery:
```bash
fastboot flash boot twrp-boot.img
# Or boot temporarily:
fastboot boot twrp.img
```

---

## Dynamic Partitions

Android 10+ uses dynamic partitions with a "super" partition.

### Architecture

```
super (physical partition)
├── system_a (logical)
├── system_b (logical)
├── vendor_a (logical)
├── vendor_b (logical)
├── product_a (logical)
├── product_b (logical)
└── (free space for resizing)
```

### Fastbootd Requirement

Regular fastboot (bootloader) cannot flash dynamic partitions. You must use fastbootd (userspace fastboot).

```bash
# Enter fastbootd
fastboot reboot fastboot

# Verify
fastboot getvar is-userspace           # Should be: yes

# Now flash
fastboot flash system system.img
```

### Operations

```bash
# Create partition
fastboot create-logical-partition mypart 1073741824  # 1GB

# Delete partition
fastboot delete-logical-partition mypart

# Resize partition
fastboot resize-logical-partition system 3221225472  # 3GB

# Reset super to empty
fastboot wipe-super super_empty.img
```

---

## Virtual A/B (Snapshots)

Android 11+ adds Virtual A/B with copy-on-write snapshots.

### How It Works

1. OTA writes changes as snapshots (not full partition copies)
2. After reboot, snapshots are "merged" into new slot
3. Merge happens in background after boot

### Snapshot States

```bash
fastboot getvar snapshot-update-status
# none - No pending update
# snapshotted - Snapshots created, waiting for merge
# merging - Merge in progress
```

### Dealing with Stuck Snapshots

```bash
# Cancel snapshot (may cause boot issues!)
fastboot snapshot-update cancel

# Then flash normally
fastboot reboot fastboot
fastboot flash system system.img
```

---

## Partition Variables

```bash
# Get partition info
fastboot getvar partition-type:boot     # raw, ext4, f2fs
fastboot getvar partition-size:boot     # Size in bytes
fastboot getvar is-logical:system       # yes/no
fastboot getvar has-slot:boot           # yes/no

# All variables
fastboot getvar all
```

---

## Partition Layout by Device Type

### Non-A/B (Legacy)

```
bootloader, radio, boot, recovery, system, vendor, cache, userdata
```

### A/B (Android 7+)

```
bootloader, radio, boot_a/b, system_a/b, vendor_a/b, userdata
```

### A/B + Dynamic (Android 10+)

```
bootloader, radio, boot_a/b, vbmeta_a/b, dtbo_a/b,
super (contains system_a/b, vendor_a/b, product_a/b),
userdata, metadata
```

### A/B + Virtual A/B + GKI (Android 13+)

```
bootloader, radio,
boot_a/b (kernel only),
init_boot_a/b (init ramdisk),
vendor_boot_a/b (vendor ramdisk),
vbmeta_a/b, dtbo_a/b,
super (system, vendor, product, system_ext, odm),
userdata, metadata
```

---

## Flashing Order

When flashing multiple partitions, order matters:

1. **bootloader** (reboot to bootloader after)
2. **radio/modem** (reboot to bootloader after)
3. **vbmeta** (disable verification if needed)
4. **boot**, **dtbo**, other boot partitions
5. **super** or individual dynamic partitions (in fastbootd)
6. **userdata** (wipe if needed)

```bash
# Example full flash
fastboot flash bootloader bootloader.img
fastboot reboot bootloader
fastboot flash radio radio.img
fastboot reboot bootloader
fastboot flash --disable-verity --disable-verification vbmeta vbmeta.img
fastboot flash boot boot.img
fastboot flash dtbo dtbo.img
fastboot reboot fastboot
fastboot flash system system.img
fastboot flash vendor vendor.img
fastboot -w
fastboot reboot
```

---

## GSI (Generic System Image)

GSI lets you run a generic Android build on any Treble-compatible device.

```bash
# 1. Unlock bootloader
# 2. Boot to fastbootd
adb reboot fastboot

# 3. Disable verification
fastboot flash vbmeta --disable-verity --disable-verification vbmeta.img

# 4. Optional: Delete product to make room
fastboot delete-logical-partition product_a
fastboot delete-logical-partition product_b

# 5. Flash GSI
fastboot flash system gsi-system.img

# 6. Wipe data (required!)
fastboot -w

# 7. Reboot
fastboot reboot
```
