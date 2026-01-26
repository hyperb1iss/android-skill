# AOSP Build System Deep Dive

## Environment Setup

### System Requirements

- Ubuntu 20.04+ or compatible
- 400GB+ free disk space
- 32GB+ RAM recommended
- Fast internet for initial sync

### Dependencies

```bash
sudo apt-get install git-core gnupg flex bison build-essential \
    zip curl zlib1g-dev libc6-dev-i386 libncurses5 \
    x11proto-core-dev libx11-dev lib32z1-dev libgl1-mesa-dev \
    libxml2-utils xsltproc unzip fontconfig python3
```

### Repo Tool

```bash
mkdir -p ~/.bin
curl https://storage.googleapis.com/git-repo-downloads/repo > ~/.bin/repo
chmod a+x ~/.bin/repo
export PATH="$HOME/.bin:$PATH"
```

---

## Source Management

### Initialize

```bash
# AOSP
repo init -u https://android.googlesource.com/platform/manifest -b android-14.0.0_r1

# LineageOS
repo init -u https://github.com/LineageOS/android.git -b lineage-21.0
```

### Sync

```bash
repo sync -c -j$(nproc) --force-sync --no-tags --no-clone-bundle

# Options:
# -c              Current branch only
# -j$(nproc)      Parallel jobs
# --force-sync    Force overwrite
# --no-tags       Skip tags (faster)
# --no-clone-bundle  Don't use bundles
```

### Local Manifests

Create `.repo/local_manifests/` for custom repos:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<manifest>
  <remote name="github" fetch="https://github.com/" />

  <project name="user/device_vendor_device"
           path="device/vendor/device"
           remote="github"
           revision="lineage-21" />
</manifest>
```

---

## Build System Architecture

### Make vs Soong

- **Make** (`.mk` files): Legacy, still used for device trees
- **Soong** (`Android.bp`): Modern, Go-based, for most modules
- **Blueprint**: DSL for `Android.bp` files
- **Ninja**: Actual build executor

### Build Flow

1. `source build/envsetup.sh` - Load functions
2. `lunch <target>` - Set build variables
3. `m` - Invoke Soong/Make → Ninja → Build

---

## envsetup.sh Functions

```bash
source build/envsetup.sh

# Essential
lunch <target>        # Set target device
m                     # Build (Soong-based)
mm                    # Build current directory
mmm <path>            # Build specific path
mma                   # mm + dependencies
mmma <path>           # mmm + dependencies

# LineageOS additions
breakfast <device>    # Setup + device deps
brunch <device>       # breakfast + mka bacon
eat                   # Alias for brunch

# Utilities
croot                 # cd to top of tree
godir <file>          # Find and go to file
mgrep <pattern>       # Grep makefiles
cgrep <pattern>       # Grep C/C++
jgrep <pattern>       # Grep Java
```

---

## lunch Targets

Format: `<product>-<variant>`

```bash
lunch aosp_crosshatch-userdebug    # Pixel 3 XL
lunch lineage_cheeseburger-userdebug  # OnePlus 5
```

### Variants

| Variant | Root | Debug | Use Case |
|---------|------|-------|----------|
| user | No | No | Production |
| userdebug | Yes | Yes | Development (most common) |
| eng | Yes | Full | Engineering/testing |

---

## Build Targets

### Full Builds

```bash
m                     # Full build
m dist                # Full + distribution packages
mka bacon             # LineageOS flashable zip
mka otapackage        # OTA package
```

### Image Targets

```bash
mka bootimage         # boot.img
mka systemimage       # system.img
mka vendorimage       # vendor.img
mka recoveryimage     # recovery.img (non-A/B)
mka superimage        # super.img (dynamic)
```

### Module Targets

```bash
m Settings            # Build Settings app
m libstagefright      # Build specific library
m android.hardware.audio@7.0-impl
```

---

## Device Tree Structure

```
device/<vendor>/<device>/
├── Android.mk                # Legacy make
├── Android.bp                # Soong build
├── AndroidProducts.mk        # Product list
├── BoardConfig.mk            # Board hardware
├── device.mk                 # Device packages
├── lineage_<device>.mk       # LineageOS product
├── vendorsetup.sh            # Add to lunch
├── extract-files.sh          # Blob extraction
├── proprietary-files.txt     # Blob list
├── sepolicy/                 # SELinux
│   ├── file_contexts
│   ├── property_contexts
│   └── *.te
├── overlay/                  # Resource overlays
├── configs/                  # Config files
├── rootdir/                  # Init files
└── recovery/                 # Recovery config
```

### BoardConfig.mk Key Variables

```makefile
# Architecture
TARGET_ARCH := arm64
TARGET_ARCH_VARIANT := armv8-2a
TARGET_CPU_ABI := arm64-v8a

# Platform
TARGET_BOARD_PLATFORM := sm8350
TARGET_BOOTLOADER_BOARD_NAME := lahaina

# Kernel
TARGET_KERNEL_SOURCE := kernel/oneplus/sm8350
TARGET_KERNEL_CONFIG := vendor/lahaina-qgki_defconfig
TARGET_KERNEL_CLANG_COMPILE := true
BOARD_KERNEL_CMDLINE := androidboot.hardware=qcom

# Boot image
BOARD_BOOT_HEADER_VERSION := 3
BOARD_KERNEL_PAGESIZE := 4096
BOARD_RAMDISK_USE_LZ4 := true

# Partitions
BOARD_SUPER_PARTITION_SIZE := 9126805504
BOARD_SYSTEMIMAGE_FILE_SYSTEM_TYPE := ext4

# Recovery
TARGET_RECOVERY_FSTAB := $(DEVICE_PATH)/rootdir/etc/fstab.qcom
TARGET_RECOVERY_PIXEL_FORMAT := RGBX_8888

# SELinux
BOARD_VENDOR_SEPOLICY_DIRS += $(DEVICE_PATH)/sepolicy/vendor
```

---

## Kernel Building

### In-Tree

```makefile
# BoardConfig.mk
TARGET_KERNEL_SOURCE := kernel/vendor/device
TARGET_KERNEL_CONFIG := device_defconfig
TARGET_KERNEL_CLANG_COMPILE := true

# GKI (Android 12+)
TARGET_KERNEL_CLANG_VERSION := r416183b
BOARD_USES_GENERIC_KERNEL_IMAGE := true
```

### Standalone

```bash
cd kernel/vendor/device

# Setup
export ARCH=arm64
export CROSS_COMPILE=aarch64-linux-gnu-
# Or Clang:
export CC=clang
export CLANG_TRIPLE=aarch64-linux-gnu-

# Build
make device_defconfig
make -j$(nproc)

# Output
ls arch/arm64/boot/Image*
```

---

## Vendor Blobs

### proprietary-files.txt Format

```
# Audio
vendor/lib64/hw/audio.primary.lahaina.so
vendor/etc/audio_policy_configuration.xml

# With source path
vendor/lib64/libqti-perfd-client.so:vendor/lib64/libqti-perfd-client.so

# Pinned (hash required)
-vendor/app/TimeService/TimeService.apk

# From other device
vendor/lib64/lib.so|device/other
```

### Extraction

```bash
./extract-files.sh            # From device
./extract-files.sh ~/ota.zip  # From OTA
```

---

## SELinux/SEAndroid

### Common Files

```
sepolicy/
├── file_contexts         # File labels
├── property_contexts     # Property labels
├── hwservice_contexts    # HAL service labels
├── genfs_contexts        # Generated FS labels
└── vendor/*.te           # Policy rules
```

### Debugging

```bash
# Check mode
adb shell getenforce

# Set permissive (temporary, needs root)
adb shell su -c "setenforce 0"

# Find denials
adb shell dmesg | grep "avc: denied"
adb logcat | grep "avc: denied"

# Generate policy
audit2allow -i audit.log
```

---

## Common Issues

### Out of Memory

```bash
export JACK_SERVER_VM_ARGUMENTS="-Xmx8g"
export _JAVA_OPTIONS="-Xmx8g"
```

### Ninja Build Error

```bash
# Usually dependency issue, clean and rebuild
m clean
m
```

### Missing Blobs

Check logcat for:
```
E ServiceManager: Could not find service <name>
E linker: cannot find symbol
```

Solution: Add missing blobs to `proprietary-files.txt`

---

## Useful Commands

```bash
# Find module name from file
grep -r "LOCAL_MODULE := " --include="*.mk" | grep <filename>

# Find Android.bp module
grep -r "name: " --include="*.bp" | grep <name>

# Check what builds a file
mgrep <filename>

# Incremental build specific module
mm <module>

# Force rebuild
touch <file> && mm
```
