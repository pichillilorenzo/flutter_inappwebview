# WPE WebKit Backend for flutter_inappwebview_linux

This document describes how to install and configure WPE WebKit for the flutter_inappwebview Linux
plugin.

Examples and defaults target **WPE WebKit 2.54** on Linux, with developer mode and experimental
features OFF. See [LINUX_COMPATIBILITY.md](LINUX_COMPATIBILITY.md) for compatibility and packaging.

## Overview

This plugin uses WPE WebKit for offscreen web rendering. WPE WebKit is the official WebKit port for
embedded systems:

1. **Designed for headless/offscreen rendering** - No GTK widget hierarchy required
2. **GPU integration** - Imports DMA-BUF frames and copies them to a Flutter texture on the GPU;
   pixel transfer is a fallback when the driver cannot import or copy the frame
3. **Lower memory footprint** - No widget hierarchy overhead
4. **Perfect for embedded systems** - Raspberry Pi, set-top boxes, kiosks, etc.

The WPE backend exports frames directly as GPU textures via DMA-BUF or SHM buffers.

## Backend Selection

The plugin supports two backend APIs, with automatic selection at compile time:

| Backend            | Package                                          | Status          | Description                                                  |
|--------------------|--------------------------------------------------|-----------------|--------------------------------------------------------------|
| **WPEPlatform**    | `wpe-platform-2.0` + `wpe-platform-headless-2.0` | **DEFAULT**     | WPEPlatform 2.52+; 2.54 recommended for new installations.   |
| **WPEBackend-FDO** | `wpebackend-fdo-1.0`                             | Legacy Fallback | Fallback with wpe-webkit-2.0 >= 2.48 and legacy API enabled. |

### Backend Detection Logic

The build system automatically selects the backend after compile/link checks against the selected
SDK:

1. **If WPEPlatform is found** (`wpe-platform-2.0` and `wpe-platform-headless-2.0`):

- WPEPlatform is used as the default backend
- `HAVE_WPE_PLATFORM=1` is defined
- WPEBackend-FDO is ignored even if available

2. **If WPEPlatform is NOT found** but WPEBackend-FDO is available:

- WPEBackend-FDO is used as legacy fallback if WebKit exports the legacy API
- `HAVE_WPE_BACKEND_LEGACY=1` is defined

3. **If neither is found**: Build fails with an error message. WebKit <2.48 lacks required APIs and
   is unsupported, including with FDO.

> **Note:** WPEPlatform and WPEBackend-FDO are **mutually exclusive** at compile time. You cannot
> use both simultaneously.

## Installation Options

You can either:

1. **Use pre-built packages** from your distribution (if
   available): https://wpewebkit.org/about/get-wpe.html
2. **Build from source** using official tarball releases (recommended for latest
   features): https://wpewebkit.org/release/

### Option 2: Build from Source

#### Prerequisites

Install the **required** build dependencies (optional features are listed separately below):

```bash
# Core build tools
sudo apt-get install -y \
  build-essential cmake ninja-build pkg-config xz-utils \
  ruby perl python3 \
  gperf unifdef

# GLib (required)
sudo apt-get install -y libglib2.0-dev

# Networking and security (required)
sudo apt-get install -y \
  libsoup-3.0-dev \
  libsecret-1-dev \
  libgcrypt20-dev libtasn1-6-dev

# Graphics and rendering (required)
sudo apt-get install -y \
  libepoxy-dev \
  libegl-dev libgles-dev \
  libxkbcommon-dev

# Image and font processing (required)
sudo apt-get install -y \
  libjpeg-dev libpng-dev libwebp-dev \
  libharfbuzz-dev libharfbuzz-icu0 libfreetype6-dev libfontconfig1-dev

# Text and internationalization (required)
sudo apt-get install -y \
  libicu-dev libexpat1-dev libxml2-dev libxml2-utils \
  libhyphen-dev libenchant-2-dev

# Media and audio (required for ENABLE_VIDEO and ENABLE_WEB_AUDIO)
sudo apt-get install -y \
  libgstreamer1.0-dev \
  libgstreamer-plugins-base1.0-dev \
  libgstreamer-plugins-bad1.0-dev \
  gstreamer1.0-plugins-base gstreamer1.0-plugins-good

# Database and storage (required)
sudo apt-get install -y libsqlite3-dev zlib1g-dev

# Flutter plugin dependencies (in addition to the engine)
sudo apt-get install -y libgtk-3-dev

# Only for legacy FDO builds, not the recommended WPEPlatform-only build:
# sudo apt-get install -y libwpe-1.0-dev libwpebackend-fdo-1.0-dev meson
```

> **Note:** Optional dependencies (libjxl, libavif, flite, libdrm, etc.) are listed in the
> "Installing All Optional Dependencies" section below. Install them for full feature support, or
> disable the corresponding CMake flags.

#### Optional Features and Dependencies

WPE WebKit has many optional features that are **enabled by default**. If you don't have the
required dependencies installed, you must either install them or disable the feature via CMake
flags.

##### Feature Defaults

`Min Version` is the dependency minimum checked by WPE 2.54 CMake, not a WebKit version. `—` means
no explicit version minimum or no separate dependency.

| CMake Flag                  | Default in 2.54                         | Min Version | Dependencies (Debian/Ubuntu)                   | Description                                                         |
|-----------------------------|-----------------------------------------|-------------|------------------------------------------------|---------------------------------------------------------------------|
| `USE_JPEGXL`                | ON                                      | 0.7.0       | `libjxl-dev`                                   | JPEG XL image format support                                        |
| `USE_AVIF`                  | ON                                      | 0.9.0       | `libavif-dev`                                  | AVIF image format support                                           |
| `USE_WOFF2`                 | ON, or OFF when FreeType provides WOFF2 | 1.0.2       | `libwoff-dev` if needed                        | WOFF2 web font support                                              |
| `USE_LCMS`                  | ON                                      | —           | `liblcms2-dev`                                 | Color management (Little CMS)                                       |
| `USE_ATK`                   | ON                                      | 2.16.0      | `libatk1.0-dev libatk-bridge2.0-dev`           | Accessibility toolkit                                               |
| `USE_GBM`                   | ON                                      | —           | `libgbm-dev`                                   | Generic Buffer Management (GPU)                                     |
| `USE_LIBDRM`                | ON                                      | —           | `libdrm-dev`                                   | Direct Rendering Manager                                            |
| `USE_LIBBACKTRACE`          | ON                                      | —           | GCC development package                        | Stack trace support; compiler-private paths may need to be supplied |
| `USE_SKIA_OPENTYPE_SVG`     | ON                                      | —           | —                                              | Skia OpenType SVG font support                                      |
| `ENABLE_SPEECH_SYNTHESIS`   | ON                                      | —           | See speech options below                       | Text-to-speech support                                              |
| `USE_FLITE`                 | ON when speech synthesis is enabled     | 2.2         | `flite1-dev`                                   | Flite speech engine (used when speech enabled)                      |
| `USE_SPIEL`                 | OFF                                     | —           | `libspiel-dev`                                 | Alternative speech engine (LibSpiel)                                |
| `ENABLE_XSLT`               | ON                                      | 1.1.13      | `libxslt1-dev`                                 | XSLT transformation support                                         |
| `ENABLE_INTROSPECTION`      | ON                                      | —           | `gobject-introspection libgirepository1.0-dev` | GObject introspection                                               |
| `ENABLE_DOCUMENTATION`      | ON                                      | —           | `pip3 install gi-docgen`                       | API documentation generation                                        |
| `ENABLE_JOURNALD_LOG`       | ON                                      | —           | `libsystemd-dev` or `libelogind-dev`           | Systemd journal logging                                             |
| `ENABLE_BUBBLEWRAP_SANDBOX` | ON                                      | 0.3.1       | `bubblewrap xdg-dbus-proxy libseccomp-dev`     | Process sandboxing (Linux only)                                     |
| `ENABLE_WEBDRIVER`          | ON                                      | —           | —                                              | WebDriver automation support                                        |
| `ENABLE_PDFJS`              | ON                                      | —           | —                                              | PDF.js viewer                                                       |
| `ENABLE_VIDEO`              | ON                                      | 1.18.4      | GStreamer (see prerequisites)                  | HTML5 video support                                                 |
| `ENABLE_WEB_AUDIO`          | ON                                      | 1.18.4      | GStreamer (see prerequisites)                  | Web Audio API support                                               |
| `ENABLE_GAMEPAD`            | ON                                      | 0.2.4       | `libmanette-0.2-dev`                           | Gamepad/controller support                                          |
| `ENABLE_MEDIA_STREAM`       | ON                                      | 1.18.4      | GStreamer plugins                              | MediaStream infrastructure; Requires runtime sources/codecs      |
| `ENABLE_WEB_RTC`            | OFF                                     | —           | —                                              | WebRTC disabled in the 2.54 release series                          |
| `USE_GSTREAMER_WEBRTC`      | ON → OFF with `ENABLE_WEB_RTC=OFF`      | 1.20        | GStreamer WebRTC                               | Keep effective OFF; not a supported WebRTC path in 2.54             |
| `ENABLE_SPELLCHECK`         | ON                                      | —           | `libenchant-2-dev`                             | Spell checking; dictionaries needed at runtime                      |
| `USE_SYSPROF_CAPTURE`       | ON                                      | —           | `libsysprof-capture-4-dev`                     | Tracing; OFF in the recommended recipe                              |

`USE_WOFF2` requires libwoff2 >= 1.0.2 only when FreeType does not provide WOFF2; the FreeType
alternative requires >= 2.10.2 with Brotli. GStreamer >= 1.20 is required with
`ENABLE_MEDIA_RECORDER=ON` (the default). The ATK minimum does not apply to ATKBridge, which has no
explicit version check.

##### Platform and Advanced Features

| CMake Flag                     | Default in 2.54            | Dependencies (Debian/Ubuntu)                     | Description                                                        |
|--------------------------------|----------------------------|--------------------------------------------------|--------------------------------------------------------------------|
| `ENABLE_WPE_PLATFORM`          | ON                         | See platform flags below                         | Modern platform API (required for the modern backend)              |
| `ENABLE_WPE_PLATFORM_HEADLESS` | ON with WPEPlatform        | See platform flags below                         | Offscreen buffers for Flutter; GPU rendering is still available    |
| `ENABLE_ENCRYPTED_MEDIA`       | OFF                        | Thunder/OCDM                                     | Encrypted Media Extensions (EME/DRM)                               |
| `ENABLE_WPE_PLATFORM_DRM`      | ON with WPEPlatform/GBM    | `libinput-dev libudev-dev libdrm-dev libgbm-dev` | DRM/KMS platform (requires `USE_GBM`)                              |
| `ENABLE_WPE_PLATFORM_WAYLAND`  | ON with WPEPlatform        | `libwayland-dev wayland-protocols`               | Wayland platform                                                   |
| `ENABLE_WPE_QT_API`            | OFF without developer mode | Qt6 development packages                         | Qt/QML API bindings                                                |
| `ENABLE_WPE_1_1_API`           | OFF                        | —                                                | Old API; unsupported by this plugin and conflicts with WPEPlatform |
| `ENABLE_WPE_LEGACY_API`        | ON                         | `libwpe-1.0-dev`                                 | Set OFF for the modern-only SDK; keep ON only for FDO              |

DRM requires libinput >= 1.19.0; Wayland requires libwayland >= 1.20 and wayland-protocols >= 1.24.
The other platform rows have no explicit version minimum.

> **WPEPlatform for this Plugin:** WPEPlatform and headless default to ON in 2.54. The recipe below
> disables legacy, DRM and Wayland backends, keeping GBM/DRM buffer support. FDO builds require
> `ENABLE_WPE_LEGACY_API=ON`.

Defaults follow the release CMake options and dependency checks; recheck them when upgrading WebKit.

##### Disabling Optional Features

To disable a feature, pass `-D<FLAG>=OFF` to cmake. Example:

```bash
cmake -B build -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=$WPE_PREFIX \
  -DPORT=WPE \
  -DUSE_JPEGXL=OFF \
  -DUSE_AVIF=OFF \
  -DENABLE_SPEECH_SYNTHESIS=OFF \
  -DENABLE_DOCUMENTATION=OFF \
  -DENABLE_INTROSPECTION=OFF \
  -DENABLE_WPE_PLATFORM=ON \
  -DENABLE_WPE_PLATFORM_HEADLESS=ON \
  -DENABLE_WPE_LEGACY_API=OFF \
  -DENABLE_WPE_PLATFORM_DRM=OFF \
  -DENABLE_WPE_PLATFORM_WAYLAND=OFF \
  -DUSE_SYSPROF_CAPTURE=OFF
```

##### Minimal Build (Disable Most Optional Features)

For a minimal build, keeping sandbox support:

```bash
cmake -B build -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=$WPE_PREFIX \
  -DPORT=WPE \
  -DUSE_JPEGXL=OFF \
  -DUSE_AVIF=OFF \
  -DUSE_WOFF2=OFF \
  -DUSE_LCMS=OFF \
  -DUSE_ATK=OFF \
  -DUSE_LIBBACKTRACE=OFF \
  -DENABLE_SPEECH_SYNTHESIS=OFF \
  -DENABLE_DOCUMENTATION=OFF \
  -DENABLE_INTROSPECTION=OFF \
  -DENABLE_JOURNALD_LOG=OFF \
  -DENABLE_BUBBLEWRAP_SANDBOX=ON \
  -DENABLE_WEBDRIVER=OFF \
  -DENABLE_GAMEPAD=OFF \
  -DUSE_GSTREAMER_WEBRTC=OFF \
  -DENABLE_MINIBROWSER=OFF \
  -DENABLE_WPE_PLATFORM=ON \
  -DENABLE_WPE_PLATFORM_HEADLESS=ON \
  -DENABLE_WPE_LEGACY_API=OFF \
  -DENABLE_WPE_PLATFORM_DRM=OFF \
  -DENABLE_WPE_PLATFORM_WAYLAND=OFF \
  -DUSE_SYSPROF_CAPTURE=OFF
```

##### Build with Additional Optional Features

For a build with additional optional features:

```bash
cmake -B build -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=$WPE_PREFIX \
  -DPORT=WPE \
  -DENABLE_DOCUMENTATION=OFF \
  -DENABLE_INTROSPECTION=ON \
  -DENABLE_BUBBLEWRAP_SANDBOX=ON \
  -DENABLE_WEBDRIVER=ON \
  -DENABLE_MINIBROWSER=OFF \
  -DENABLE_PDFJS=ON \
  -DENABLE_VIDEO=ON \
  -DENABLE_WEB_AUDIO=ON \
  -DENABLE_SPEECH_SYNTHESIS=ON \
  -DENABLE_XSLT=ON \
  -DENABLE_GAMEPAD=ON \
  -DENABLE_JOURNALD_LOG=ON \
  -DUSE_AVIF=ON \
  -DUSE_WOFF2=ON \
  -DUSE_JPEGXL=ON \
  -DUSE_LCMS=ON \
  -DUSE_ATK=ON \
  -DUSE_GBM=ON \
  -DUSE_LIBDRM=ON \
  -DUSE_LIBBACKTRACE=ON \
  -DUSE_FLITE=ON \
  -DUSE_GSTREAMER_WEBRTC=OFF \
  -DENABLE_WPE_PLATFORM=ON \
  -DENABLE_WPE_PLATFORM_HEADLESS=ON \
  -DENABLE_WPE_LEGACY_API=OFF \
  -DENABLE_WPE_PLATFORM_DRM=OFF \
  -DENABLE_WPE_PLATFORM_WAYLAND=OFF \
  -DUSE_SYSPROF_CAPTURE=OFF
```

> **Note:** This requires all optional dependencies to be installed (see "Installing All Optional
> Dependencies" above).

##### Installing All Optional Dependencies

To install **all** optional dependencies for a full-featured build:

```bash
# Image format support
sudo apt-get install -y \
  libjxl-dev \
  libavif-dev \
  libwoff-dev

# Color management
sudo apt-get install -y liblcms2-dev

# Accessibility
sudo apt-get install -y libatk1.0-dev libatk-bridge2.0-dev

# Graphics/GPU (required for USE_GBM and USE_LIBDRM)
sudo apt-get install -y libdrm-dev libgbm-dev

# Debugging: GCC includes libbacktrace in its compiler-private directories.
# Add these to the WebKit cmake command if automatic discovery fails:
#   -DLIBBACKTRACE_INCLUDE_DIR="$(gcc -print-file-name=include)"
#   -DLIBBACKTRACE_LIBRARY="$(gcc -print-file-name=libbacktrace.a)"

# Speech synthesis (choose one)
sudo apt-get install -y flite1-dev  # Flite (default)
# OR: sudo apt-get install -y libspiel-dev  # LibSpiel (alternative)

# XSLT
sudo apt-get install -y libxslt1-dev

# GObject introspection & documentation
sudo apt-get install -y gobject-introspection libgirepository1.0-dev
pip3 install gi-docgen

# Systemd logging
sudo apt-get install -y libsystemd-dev

# Sandboxing
sudo apt-get install -y bubblewrap xdg-dbus-proxy libseccomp-dev

# Gamepad support
sudo apt-get install -y libmanette-0.2-dev libevdev-dev

# Additional GStreamer runtime codecs (does not enable WebRTC in 2.54)
sudo apt-get install -y gstreamer1.0-plugins-bad

# WPE Platform DRM (for ENABLE_WPE_PLATFORM_DRM)
sudo apt-get install -y libinput-dev libudev-dev

# WPE Platform Wayland (for ENABLE_WPE_PLATFORM_WAYLAND)
sudo apt-get install -y libwayland-dev wayland-protocols

# Qt6 support (only when ENABLE_WPE_QT_API=ON)
# sudo apt-get install -y qt6-base-dev qt6-declarative-dev
```

##### Common Build Errors and Fixes

| Error Message                                                 | Solution                                                                                   |
|---------------------------------------------------------------|--------------------------------------------------------------------------------------------|
| `libjxl is required for USE_JPEGXL`                           | Install `libjxl-dev` OR add `-DUSE_JPEGXL=OFF`                                             |
| `libavif 0.9.0 is required for USE_AVIF`                      | Install `libavif-dev` OR add `-DUSE_AVIF=OFF`                                              |
| `libwoff2dec is required for USE_WOFF2`                       | Install `libwoff-dev` OR add `-DUSE_WOFF2=OFF`                                             |
| `libcms2 is required for USE_LCMS`                            | Install `liblcms2-dev` OR add `-DUSE_LCMS=OFF`                                             |
| `atk is required for USE_ATK`                                 | Install `libatk1.0-dev libatk-bridge2.0-dev` OR add `-DUSE_ATK=OFF`                        |
| `libbacktrace is required for USE_LIBBACKTRACE`               | Pass GCC include/library locations as shown above                                          |
| `Flite is needed for ENABLE_SPEECH_SYNTHESIS`                 | Install `flite1-dev` OR add `-DENABLE_SPEECH_SYNTHESIS=OFF`                                |
| `LibSpiel is needed for ENABLE_SPEECH_SYNTHESIS`              | Install `libspiel-dev` OR use Flite instead                                                |
| `libxslt is required for ENABLE_XSLT`                         | Install `libxslt1-dev` OR add `-DENABLE_XSLT=OFF`                                          |
| `GObjectIntrospection is needed for ENABLE_INTROSPECTION`     | Install `gobject-introspection libgirepository1.0-dev` OR add `-DENABLE_INTROSPECTION=OFF` |
| `gi-docgen is needed for ENABLE_DOCUMENTATION`                | Run `pip3 install gi-docgen` OR add `-DENABLE_DOCUMENTATION=OFF`                           |
| `libsystemd or libelogind are needed for ENABLE_JOURNALD_LOG` | Install `libsystemd-dev` OR add `-DENABLE_JOURNALD_LOG=OFF`                                |
| `GBM is required for USE_GBM`                                 | Install `libgbm-dev` OR add `-DUSE_GBM=OFF` (disables GPU process)                         |
| `libdrm is required for USE_LIBDRM`                           | Install `libdrm-dev` OR add `-DUSE_LIBDRM=OFF`                                             |

#### Build Instructions

Use CMake >= 3.20 and a compiler supported by the selected WebKit release.

```bash
# Create a working directory
mkdir -p ~/wpe-build && cd ~/wpe-build

# Set installation prefix (use /usr/local or a custom path)
export WPE_PREFIX=/usr/local
```

Skip steps 1 and 2 for WPEPlatform. For FDO, enable `ENABLE_WPE_LEGACY_API` in WebKit and select
`FLUTTER_INAPPWEBVIEW_WPE_BACKEND=LEGACY` in the plugin.

```bash
# === 1. Build libwpe (OPTIONAL - only for legacy fallback) ===
wget https://wpewebkit.org/releases/libwpe-1.16.3.tar.xz
tar xf libwpe-1.16.3.tar.xz
cd libwpe-1.16.3
cmake -B build -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=$WPE_PREFIX
ninja -C build
sudo ninja -C build install
cd ..

# === 2. Build WPEBackend-fdo (OPTIONAL - only for legacy fallback) ===
# Skip this step if you enable ENABLE_WPE_PLATFORM in step 3.
# Only needed for older WPE WebKit builds or as a fallback.
wget https://wpewebkit.org/releases/wpebackend-fdo-1.16.1.tar.xz
tar xf wpebackend-fdo-1.16.1.tar.xz
cd wpebackend-fdo-1.16.1
meson setup build \
  --prefix=$WPE_PREFIX \
  --buildtype=release
ninja -C build
sudo ninja -C build install
cd ..

```

```bash
# === 3. Build WPE WebKit ===
# This is the largest component and takes significant time/resources
: "${WPE_VERSION:?Set the full patch version of the selected WPE 2.54 source archive}"
wget "https://wpewebkit.org/releases/wpewebkit-${WPE_VERSION}.tar.xz"
tar xf "wpewebkit-${WPE_VERSION}.tar.xz"
cd "wpewebkit-${WPE_VERSION}"

# Configure with recommended options for flutter_inappwebview
# Other features inherit the 2.54 defaults, including WebDriver and sandbox.
CC=gcc CXX=g++ cmake -B build -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=$WPE_PREFIX \
  -DPORT=WPE \
  -DLIBBACKTRACE_INCLUDE_DIR="$(gcc -print-file-name=include)" \
  -DLIBBACKTRACE_LIBRARY="$(gcc -print-file-name=libbacktrace.a)" \
  -DENABLE_DOCUMENTATION=OFF \
  -DENABLE_INTROSPECTION=OFF \
  -DENABLE_WPE_LEGACY_API=OFF \
  -DENABLE_WPE_PLATFORM_DRM=OFF \
  -DENABLE_WPE_PLATFORM_WAYLAND=OFF \
  -DUSE_SYSPROF_CAPTURE=OFF \
  -DENABLE_SPEECH_SYNTHESIS=OFF \
  -DENABLE_GAMEPAD=OFF \
  -DENABLE_JOURNALD_LOG=OFF

# WPEPlatform and headless are enabled by default in 2.54.

# If you're missing optional dependencies, disable them:
#   -DUSE_JPEGXL=OFF           # if libjxl-dev not installed
#   -DUSE_AVIF=OFF             # if libavif-dev not installed
#   -DUSE_WOFF2=OFF            # if libwoff-dev not installed
#   -DUSE_LCMS=OFF             # if liblcms2-dev not installed
#   -DENABLE_SPEECH_SYNTHESIS=OFF  # if flite1-dev not installed
#   -DUSE_ATK=OFF              # if libatk1.0-dev not installed
#   -DUSE_LIBBACKTRACE=OFF     # only if native backtraces are not required
#   -DENABLE_JOURNALD_LOG=OFF  # if libsystemd-dev not installed

# Build (use -j to limit parallelism if you have limited RAM)
ninja -C build -j$(nproc)

# Install
sudo ninja -C build install
cd ..

# === 4. Update library cache ===
sudo ldconfig

# This plugin loads FDO directly; no global default-backend symlink is needed.
```

#### Verify Installation

```bash
# Check pkg-config can find the libraries
pkg-config --modversion wpe-webkit-2.0
pkg-config --modversion wpe-platform-2.0 wpe-platform-headless-2.0
# (OPTIONAL - only for legacy fallback)
pkg-config --modversion wpebackend-fdo-1.0
pkg-config --modversion wpe-1.0
```

If pkg-config doesn't find the libraries, add the installation path:

```bash
export PKG_CONFIG_PATH=$WPE_PREFIX/lib/pkgconfig:$WPE_PREFIX/lib/$(uname -m)-linux-gnu/pkgconfig:$PKG_CONFIG_PATH
```

Check effective options in `CMakeCache.txt` and `cmakeconfig.h`. `DESTDIR` alone does not make
WebKit relocatable.

## Building the Flutter Plugin

The plugin automatically detects WPE libraries via pkg-config. When WPE is found, it:

1. **Compiles with the WPE backend**
2. **Bundles WPE libraries** into the Flutter app's `lib/` directory
3. **Preserves SONAME links** for the bundled libraries

Library bundling can be disabled for a separately packaged runtime;
see [LINUX_COMPATIBILITY.md](LINUX_COMPATIBILITY.md#runtime-packaging). WebKit subprocesses,
resources and OS dependencies must still be installed.

### Build Your App

```bash
cd your_flutter_app
flutter build linux --release
```

During build, you should see messages indicating which backend is being used:

**With WPEPlatform (default):**

```
-- flutter_inappwebview_linux: Using WPE WebKit backend
-- flutter_inappwebview_linux: WPE WebKit 2.54
-- flutter_inappwebview_linux: WPEPlatform 2.54 + headless
```

**With WPEBackend-FDO (legacy fallback):**

```
-- flutter_inappwebview_linux: Using WPE WebKit backend
-- flutter_inappwebview_linux: WPE WebKit 2.54
-- flutter_inappwebview_linux: Legacy WPEBackend-FDO
```

### Run Your App

With the complete WPE runtime and its OS dependencies installed, run the built app:

```bash
# x64 architecture
./build/linux/x64/release/bundle/your_app

# ARM64 architecture
./build/linux/arm64/release/bundle/your_app
```

### What Gets Bundled

The following files are automatically copied to your app's `lib/` directory:

**Always bundled:**

- `libWPEWebKit-2.0.so*` - WPE WebKit library and SONAME links (unless bundling is disabled)

**With WPEPlatform (default):**

- WPEPlatform/headless are built into `libWPEWebKit-2.0.so`; there are no separate platform
  libraries.

**With WPEBackend-FDO (legacy):**

- `libWPEBackend-fdo-1.0.so.*` - FDO backend library
- `libwpe-1.0.so.*` - libwpe library

## Architecture

```
Flutter App
    │
    ▼
flutter_inappwebview Dart layer
    │
    ▼
Method Channel
    │
    ▼
InAppWebView (C++)
    │
    ├──► WebKitWebView (WPE WebKit)
    │         │
    │         ▼
    │    ┌─────────────────────────────────────┐
    │    │  WPE Backend (compile-time choice)  │
    │    ├─────────────────────────────────────┤
    │    │  WPEPlatform (DEFAULT)              │
    │    │    - wpe-platform-2.0               │
    │    │    - wpe-platform-headless-2.0      │
    │    │    - Modern API (WPE WebKit 2.52+)  │
    │    ├─────────────────────────────────────┤
    │    │  WPEBackend-FDO (LEGACY FALLBACK)   │
    │    │    - wpebackend-fdo-1.0             │
    │    │    - For older systems              │
    │    └─────────────────────────────────────┘
    │         │
    │         ▼
    └──► Flutter Texture ◄──── SHM Buffer / DMA-BUF
```

## Troubleshooting

### "WPE WebKit not found"

Ensure pkg-config can find the libraries:

```bash
# Core WPE WebKit library (required)
pkg-config --cflags --libs wpe-webkit-2.0

# WPEPlatform (default backend) - check if available
pkg-config --cflags --libs wpe-platform-2.0
pkg-config --cflags --libs wpe-platform-headless-2.0

# WPEBackend-FDO (legacy fallback) - check if available
pkg-config --cflags --libs wpebackend-fdo-1.0 wpe-1.0
```

If not found, add the installation prefix:

```bash
export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:/usr/local/lib/$(uname -m)-linux-gnu/pkgconfig:$PKG_CONFIG_PATH
```

### Failed to load WPEBackend-FDO

This only applies to the **legacy** backend. Check that `libWPEBackend-fdo-1.0.so.1`
and libwpe are installed or bundled, and that WebKit was built with the legacy API. This plugin
loads FDO directly; it does not need a default-backend symlink.

### Build errors for WPE WebKit

If you encounter missing dependency errors during `cmake`:

```bash
# If you see "gi-docgen not found"
pip3 install gi-docgen

# If you see "unifdef not found"
sudo apt-get install unifdef

# If you see "gperf not found"
sudo apt-get install gperf

# If you see "ruby not found"
sudo apt-get install ruby ruby-dev

# If you see GObject introspection errors
sudo apt-get install gobject-introspection libgirepository1.0-dev
```

### Libraries not bundled

If libraries aren't being bundled, check:

1. `FLUTTER_INAPPWEBVIEW_BUNDLE_WPE` is ON
2. Library paths are correct in pkg-config

## Resources

- [WPE 2.54 Release Notes](https://wpewebkit.org/blog/2026-09-16-wpewebkit-2.54.html)
- [WPE WebKit Official Site](https://wpewebkit.org/)
- [WPE WebKit API Reference](https://webkitgtk.org/reference/wpe-webkit-2.0/stable/)
- [Release Downloads](https://wpewebkit.org/release/)
- [Release Schedule](https://wpewebkit.org/release/schedule/)
