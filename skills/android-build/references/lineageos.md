# LineageOS Development Reference

## LineageOS-Specific Commands

### breakfast

Setup device and sync dependencies:

```bash
source build/envsetup.sh
breakfast <device>

# Example:
breakfast cheeseburger    # OnePlus 5
breakfast oriole          # Pixel 6
```

This will:
1. Set up lunch target
2. Sync device-specific repos
3. Sync kernel and vendor repos

### brunch

Full build shortcut (breakfast + build):

```bash
brunch <device>
# Equivalent to:
# breakfast <device>
# mka bacon
```

### mka bacon

Build flashable ZIP:

```bash
mka bacon
# Output: out/target/product/<device>/lineage-21.0-*-UNOFFICIAL-<device>.zip
```

---

## Directory Structure

### vendor/lineage

```
vendor/lineage/
├── build/
│   ├── core/               # Build system extensions
│   ├── soong/              # Soong config modules
│   └── tools/              # Build scripts
├── config/
│   ├── common.mk           # Common packages
│   ├── BoardConfigLineage.mk
│   └── version.mk          # Version info
├── overlay/                # System overlays
├── prebuilt/               # Prebuilt apps
└── sepolicy/               # SELinux additions
```

### lineage-sdk

```
lineage-sdk/
├── sdk/                    # SDK source
├── api/                    # API definitions
└── samples/                # Example code
```

---

## Device Tree for LineageOS

### Required Files

```
device/<vendor>/<device>/
├── lineage_<device>.mk     # Product makefile
├── lineage.dependencies    # Repo dependencies
└── vendorsetup.sh          # Add to lunch menu
```

### lineage_<device>.mk

```makefile
# Inherit from device
$(call inherit-product, device/vendor/device/device.mk)

# Inherit LineageOS product
$(call inherit-product, vendor/lineage/config/common_full_phone.mk)

# Device identifier
PRODUCT_NAME := lineage_device
PRODUCT_DEVICE := device
PRODUCT_BRAND := Vendor
PRODUCT_MODEL := Device Name
PRODUCT_MANUFACTURER := Vendor

PRODUCT_GMS_CLIENTID_BASE := android-vendor

PRODUCT_BUILD_PROP_OVERRIDES += \
    PRIVATE_BUILD_DESC="device-user 13 ..."

BUILD_FINGERPRINT := vendor/device/device:13/...
```

### lineage.dependencies

```json
[
  {
    "repository": "android_kernel_vendor_device",
    "target_path": "kernel/vendor/device"
  },
  {
    "repository": "android_device_vendor_device-common",
    "target_path": "device/vendor/device-common"
  },
  {
    "repository": "proprietary_vendor_device",
    "target_path": "vendor/device"
  }
]
```

---

## repopick

Cherry-pick changes from Gerrit:

```bash
# Single change
repopick 12345

# Multiple changes
repopick 12345 12346 12347

# By topic
repopick -t feature-name

# With dependencies
repopick -Q 12345

# Force (overwrite local changes)
repopick -f 12345
```

### Finding Changes

1. Go to `review.lineageos.org`
2. Find change number in URL
3. `repopick <number>`

---

## LineageOS Features

### Trust Interface

Security dashboard in Settings:

```xml
<!-- overlay -->
<bool name="config_enableTrustInterface">true</bool>
```

### LiveDisplay

Display color management:

```makefile
# device.mk
PRODUCT_PACKAGES += \
    lineage.livedisplay@2.0-service-sdm
```

### Styles

System-wide theming:

```makefile
PRODUCT_PACKAGES += \
    LineageThemesStub
```

### Protected Apps

App hiding feature:

```makefile
PRODUCT_PACKAGES += \
    LineageParts
```

---

## Building Kernels for LineageOS

### In-Tree (Recommended)

```makefile
# BoardConfig.mk
TARGET_KERNEL_SOURCE := kernel/vendor/device
TARGET_KERNEL_CONFIG := lineageos_device_defconfig
TARGET_KERNEL_CLANG_COMPILE := true

# Clang version (from prebuilts)
TARGET_KERNEL_CLANG_VERSION := r416183b
```

### Prebuilt

```makefile
# BoardConfig.mk
TARGET_PREBUILT_KERNEL := device/vendor/device/prebuilt/kernel
BOARD_KERNEL_IMAGE_NAME := Image
```

---

## Contributing to LineageOS

### Gerrit Workflow

```bash
# Setup
git config --global review.review.lineageos.org.username <your_username>

# Create branch
repo start my_feature .

# Make changes
git add .
git commit -m "subsystem: Description of change"

# Push for review
git push ssh://<username>@review.lineageos.org:29418/<project> HEAD:refs/for/<branch>
```

### Commit Message Format

```
subsystem: Short description

Longer explanation if needed. Wrap at 72 characters.

Change-Id: I1234567890abcdef...
```

### Code Style

- Follow Android code style
- 4-space indentation (no tabs)
- 100-character line limit
- No trailing whitespace

---

## Upstream Merging

### aosp-merger

Merge AOSP tags:

```bash
cd vendor/lineage/build/tools
./aosp-merger.sh <tag>
# Example: ./aosp-merger.sh android-14.0.0_r20
```

### Manual Merge

```bash
cd frameworks/base
git fetch aosp
git merge android-14.0.0_r20

# Resolve conflicts
git mergetool
git add .
git commit
```

---

## Common Issues

### Missing Dependencies

```bash
# Re-run breakfast to sync
breakfast <device>

# Or manual sync
repo sync device/vendor/device
repo sync kernel/vendor/device
```

### SELinux Denials

```bash
# Get denials
adb shell dmesg | grep "avc: denied"

# Generate policy
adb shell dmesg | grep "avc: denied" | audit2allow
```

### Build Signature Mismatch

```bash
# Clean vendor
rm -rf out/target/product/<device>/vendor
m vendorimage
```

---

## Quick Reference

| Task | Command |
|------|---------|
| Setup device | `breakfast <device>` |
| Full build | `brunch <device>` |
| Build ZIP | `mka bacon` |
| Cherry-pick | `repopick <number>` |
| Sync all | `repo sync` |
| Sync device | `repo sync device/vendor/device` |
| Clean build | `m clean && brunch <device>` |
