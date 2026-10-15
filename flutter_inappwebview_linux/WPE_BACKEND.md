# WPE WebKit Backend for flutter_inappwebview_linux

This document describes how to install and configure WPE WebKit for the flutter_inappwebview Linux plugin.

## Overview

This plugin uses WPE WebKit for offscreen web rendering. WPE WebKit is the official WebKit port for embedded systems:

1. **Designed for headless/offscreen rendering** - No GTK widget hierarchy required
2. **Excellent GPU integration** - Uses DMA-BUF for zero-copy texture sharing with Flutter
3. **Lower memory footprint** - No widget hierarchy overhead
4. **Perfect for embedded systems** - Raspberry Pi, set-top boxes, kiosks, etc.

The WPE backend exports frames directly as GPU textures via DMA-BUF or SHM buffers.

## Backend Selection

The plugin supports two backend APIs, with automatic selection at compile time:

| Backend | Package | Status | Description |
|---------|---------|--------|-------------|
| **WPEPlatform** | `wpe-platform-2.0` + `wpe-platform-headless-2.0` | **DEFAULT** | Modern API for WPE WebKit 2.40+. Recommended for new installations. |
| **WPEBackend-FDO** | `wpebackend-fdo-1.0` | Legacy Fallback | Used only when WPEPlatform is not available. For older systems. |

### Backend Detection Logic

The build system automatically selects the backend:

1. **If WPEPlatform is found** (`wpe-platform-2.0` and `wpe-platform-headless-2.0`):
   - WPEPlatform is used as the default backend
   - `HAVE_WPE_PLATFORM=1` is defined
   - WPEBackend-FDO is ignored even if available

2. **If WPEPlatform is NOT found** but WPEBackend-FDO is available:
   - WPEBackend-FDO is used as legacy fallback
   - `HAVE_WPE_BACKEND_LEGACY=1` is defined

3. **If neither is found**: Build fails with an error message.

> **Note:** WPEPlatform and WPEBackend-FDO are **mutually exclusive** at compile time. You cannot use both simultaneously.

## Installation Options

You can either:
1. **Use pre-built packages** from your distribution (if available): https://wpewebkit.org/about/get-wpe.html
2. **Build from source** using official tarball releases (recommended for latest features): https://wpewebkit.org/release/

### Option 2: Build from Source

#### Prerequisites

Install the **required** build dependencies (optional features are listed separately below):

```bash
# Core build tools
sudo apt-get install -y \
  build-essential cmake ninja-build meson pkg-config \
  ruby ruby-dev python3 python3-pip \
  gperf unifdef

# GLib (required)
sudo apt-get install -y libglib2.0-dev

# Networking and security (required)
sudo apt-get install -y \
  libsoup-3.0-dev \
  libssl-dev libgnutls28-dev \
  libsecret-1-dev \
  libgcrypt20-dev libtasn1-dev

# Graphics and rendering (required)
sudo apt-get install -y \
  libepoxy-dev \
  libegl1-mesa-dev libgles2-mesa-dev \
  libxkbcommon-dev

# Image and font processing (required)
sudo apt-get install -y \
  libjpeg-dev libpng-dev libwebp-dev \
  libharfbuzz-dev libharfbuzz-icu0 libfreetype6-dev libfontconfig1-dev

# Text and internationalization (required)
sudo apt-get install -y \
  libicu-dev libxml2-dev \
  libhyphen-dev libenchant-2-dev

# Media and audio (required for ENABLE_VIDEO and ENABLE_WEB_AUDIO)
sudo apt-get install -y \
  libgstreamer1.0-dev \
  libgstreamer-plugins-base1.0-dev \
  libgstreamer-plugins-bad1.0-dev \
  gstreamer1.0-plugins-base gstreamer1.0-plugins-good

# Database and storage (required)
sudo apt-get install -y libsqlite3-dev

# WPE libraries (required)
sudo apt-get install -y libwpe-1.0-dev
```

> **Note:** Optional dependencies (libjxl, libavif, flite, libdrm, etc.) are listed in the "Installing All Optional Dependencies" section below. Install them for full feature support, or disable the corresponding CMake flags.

#### Optional Features and Dependencies

WPE WebKit has many optional features that are **enabled by default**. If you don't have the required dependencies installed, you must either install them or disable the feature via CMake flags.

##### Features Enabled by Default

| CMake Flag | Default | Min Version | Dependencies (Debian/Ubuntu) | Description |
|------------|---------|-------------|------------------------------|-------------|
| `USE_JPEGXL` | ON | 0.7.0 | `libjxl-dev` | JPEG XL image format support |
| `USE_AVIF` | ON | 0.9.0 | `libavif-dev` | AVIF image format support |
| `USE_WOFF2` | ON | 1.0.2 | `libwoff-dev` | WOFF2 web font support |
| `USE_LCMS` | ON | — | `liblcms2-dev` | Color management (Little CMS) |
| `USE_ATK` | ON | 2.16.0 | `libatk1.0-dev libatk-bridge2.0-dev` | Accessibility toolkit |
| `USE_GBM` | ON | — | `libgbm-dev` | Generic Buffer Management (GPU) |
| `USE_LIBDRM` | ON | — | `libdrm-dev` | Direct Rendering Manager |
| `USE_LIBBACKTRACE` | ON | — | `libbacktrace-dev` | Stack trace support |
| `USE_SKIA_OPENTYPE_SVG` | ON | — | — | Skia OpenType SVG font support |
| `ENABLE_SPEECH_SYNTHESIS` | ON | — | See speech options below | Text-to-speech support |
| `USE_FLITE` | ON | 2.2 | `flite1-dev` | Flite speech engine (used when speech enabled) |
| `USE_SPIEL` | OFF | — | `libspiel-dev` | Alternative speech engine (LibSpiel) |
| `ENABLE_XSLT` | ON | 1.1.13 | `libxslt1-dev` | XSLT transformation support |
| `ENABLE_INTROSPECTION` | ON | — | `gobject-introspection libgirepository1.0-dev` | GObject introspection |
| `ENABLE_DOCUMENTATION` | ON | — | `pip3 install gi-docgen` | API documentation generation |
| `ENABLE_JOURNALD_LOG` | ON | — | `libsystemd-dev` or `libelogind-dev` | Systemd journal logging |
| `ENABLE_BUBBLEWRAP_SANDBOX` | ON | — | `bubblewrap xdg-dbus-proxy libseccomp-dev` | Process sandboxing (Linux only) |
| `ENABLE_WEBDRIVER` | ON | — | — | WebDriver automation support |
| `ENABLE_PDFJS` | ON | — | — | PDF.js viewer |
| `ENABLE_VIDEO` | ON | — | GStreamer (see prerequisites) | HTML5 video support |
| `ENABLE_WEB_AUDIO` | ON | — | GStreamer (see prerequisites) | Web Audio API support |
| `ENABLE_GAMEPAD` | ON | 0.2.4 | `libmanette-0.2-dev` | Gamepad/controller support |
| `ENABLE_MEDIA_STREAM` | ON | — | GStreamer plugins | Camera/microphone access |
| `USE_GSTREAMER_WEBRTC` | OFF | — | `gstreamer1.0-plugins-bad` | GStreamer-based WebRTC |

##### Features Disabled by Default (Experimental/Advanced)

| CMake Flag | Default | Dependencies (Debian/Ubuntu) | Description |
|------------|---------|------------------------------|-------------|
| `ENABLE_WPE_PLATFORM` | OFF | See platform flags below | WPE 2.0 platform abstraction (**required for this plugin**, ⚠️ see note) |
| `ENABLE_WPE_PLATFORM_HEADLESS` | OFF | See platform flags below | Headless platform (**required for this plugin**, ⚠️ see note) |
| `ENABLE_ENCRYPTED_MEDIA` | OFF | Thunder/OCDM | Encrypted Media Extensions (EME/DRM) |
| `ENABLE_WPE_PLATFORM_DRM` | OFF | `libinput-dev libudev-dev libdrm-dev libgbm-dev` | DRM/KMS platform (requires `USE_GBM`) |
| `ENABLE_WPE_PLATFORM_WAYLAND` | OFF | `libwayland-dev wayland-protocols` | Wayland platform |
| `ENABLE_WPE_QT_API` | OFF | Qt5/Qt6 development packages | Qt/QML API bindings |
| `USE_QT6` | OFF | `qt6-base-dev qt6-declarative-dev` | Use Qt6 instead of Qt5 (requires `ENABLE_WPE_PLATFORM`) |
| `ENABLE_WPE_1_1_API` | OFF | — | Build WPE 1.1 API instead of 2.0 |

> **⚠️ WPEPlatform for this Plugin:** The `ENABLE_WPE_PLATFORM` flags above are for **building WPE WebKit from source**. To use the modern WPEPlatform backend with this Flutter plugin (the default), you must enable `ENABLE_WPE_PLATFORM=ON` and `ENABLE_WPE_PLATFORM_HEADLESS=ON` when building WPE WebKit. If these are disabled, the plugin will fall back to WPEBackend-FDO.

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
  -DENABLE_INTROSPECTION=OFF  \
  -DENABLE_WPE_PLATFORM=ON \
  -DENABLE_WPE_PLATFORM_HEADLESS=ON \
  # ... other options
```

##### Minimal Build (Disable Most Optional Features)

For a minimal build without optional dependencies:

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
  -DENABLE_BUBBLEWRAP_SANDBOX=OFF \
  -DENABLE_WEBDRIVER=OFF \
  -DENABLE_GAMEPAD=OFF \
  -DUSE_GSTREAMER_WEBRTC=OFF \
  -DENABLE_MINIBROWSER=OFF \
  -DENABLE_WPE_PLATFORM=ON \
  -DENABLE_WPE_PLATFORM_HEADLESS=ON
```

##### Feature-Complete Build (WPE 2.0 with All Features)

For a full-featured WPE 2.0 build with all optional features enabled:

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
  -DUSE_GSTREAMER_WEBRTC=ON \
  -DENABLE_WPE_PLATFORM=ON \
  -DENABLE_WPE_PLATFORM_HEADLESS=ON
```

> **Note:** This requires all optional dependencies to be installed (see "Installing All Optional Dependencies" above).

##### Installing All Optional Dependencies

To install **all** optional dependencies for a full-featured build:

```bash
# Image format support
sudo apt-get install -y \
  libjxl-dev \
  libavif-dev \
  libwoff-dev \
  libopenjp2-7-dev

# Color management
sudo apt-get install -y liblcms2-dev

# Accessibility
sudo apt-get install -y libatk1.0-dev libatk-bridge2.0-dev

# Graphics/GPU (required for USE_GBM and USE_LIBDRM)
sudo apt-get install -y libdrm-dev libgbm-dev

# Debugging
sudo apt-get install -y libbacktrace-dev

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

# WebRTC with GStreamer
sudo apt-get install -y gstreamer1.0-plugins-bad

# WPE Platform DRM (for ENABLE_WPE_PLATFORM_DRM)
sudo apt-get install -y libinput-dev libudev-dev

# WPE Platform Wayland (for ENABLE_WPE_PLATFORM_WAYLAND)
sudo apt-get install -y libwayland-dev wayland-protocols

# Qt6 support (for ENABLE_WPE_QT_API with USE_QT6)
# sudo apt-get install -y qt6-base-dev qt6-declarative-dev
```

##### Common Build Errors and Fixes

| Error Message | Solution |
|---------------|----------|
| `libjxl is required for USE_JPEGXL` | Install `libjxl-dev` OR add `-DUSE_JPEGXL=OFF` |
| `libavif 0.9.0 is required for USE_AVIF` | Install `libavif-dev` OR add `-DUSE_AVIF=OFF` |
| `libwoff2dec is required for USE_WOFF2` | Install `libwoff-dev` OR add `-DUSE_WOFF2=OFF` |
| `libcms2 is required for USE_LCMS` | Install `liblcms2-dev` OR add `-DUSE_LCMS=OFF` |
| `atk is required for USE_ATK` | Install `libatk1.0-dev libatk-bridge2.0-dev` OR add `-DUSE_ATK=OFF` |
| `libbacktrace is required for USE_LIBBACKTRACE` | Install `libbacktrace-dev` OR add `-DUSE_LIBBACKTRACE=OFF` |
| `Flite is needed for ENABLE_SPEECH_SYNTHESIS` | Install `flite1-dev` OR add `-DENABLE_SPEECH_SYNTHESIS=OFF` |
| `LibSpiel is needed for ENABLE_SPEECH_SYNTHESIS` | Install `libspiel-dev` OR use Flite instead |
| `libxslt is required for ENABLE_XSLT` | Install `libxslt1-dev` OR add `-DENABLE_XSLT=OFF` |
| `GObjectIntrospection is needed for ENABLE_INTROSPECTION` | Install `gobject-introspection libgirepository1.0-dev` OR add `-DENABLE_INTROSPECTION=OFF` |
| `gi-docgen is needed for ENABLE_DOCUMENTATION` | Run `pip3 install gi-docgen` OR add `-DENABLE_DOCUMENTATION=OFF` |
| `libsystemd or libelogind are needed for ENABLE_JOURNALD_LOG` | Install `libsystemd-dev` OR add `-DENABLE_JOURNALD_LOG=OFF` |
| `GBM is required for USE_GBM` | Install `libgbm-dev` OR add `-DUSE_GBM=OFF` (disables GPU process) |
| `libdrm is required for USE_LIBDRM` | Install `libdrm-dev` OR add `-DUSE_LIBDRM=OFF` |

#### Build Instructions

```bash
# Create a working directory
mkdir -p ~/wpe-build && cd ~/wpe-build

# Set installation prefix (use /usr/local or a custom path)
export WPE_PREFIX=/usr/local

# === 1. Build libwpe ===
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

# === 3. Build WPE WebKit ===
# This is the largest component and takes significant time/resources
wget https://wpewebkit.org/releases/wpewebkit-2.50.4.tar.xz
tar xf wpewebkit-2.50.4.tar.xz
cd wpewebkit-2.50.4

# Configure with recommended options for flutter_inappwebview
# See "Optional Features and Dependencies" section above for all flags
cmake -B build -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=$WPE_PREFIX \
  -DPORT=WPE \
  -DENABLE_DOCUMENTATION=OFF \
  -DENABLE_INTROSPECTION=OFF \
  -DENABLE_BUBBLEWRAP_SANDBOX=ON \
  -DENABLE_WEBDRIVER=OFF \
  -DENABLE_MINIBROWSER=OFF \
  -DUSE_AVIF=ON \
  -DUSE_WOFF2=ON \
  -DUSE_JPEGXL=ON \
  -DENABLE_WPE_PLATFORM=ON \
  -DENABLE_WPE_PLATFORM_HEADLESS=ON

# The last two flags enable the modern WPEPlatform backend (recommended).
# If omitted, the plugin will fall back to legacy WPEBackend-FDO.

# If you're missing optional dependencies, disable them:
#   -DUSE_JPEGXL=OFF           # if libjxl-dev not installed
#   -DUSE_AVIF=OFF             # if libavif-dev not installed
#   -DUSE_WOFF2=OFF            # if libwoff-dev not installed
#   -DUSE_LCMS=OFF             # if liblcms2-dev not installed
#   -DENABLE_SPEECH_SYNTHESIS=OFF  # if flite1-dev not installed
#   -DUSE_ATK=OFF              # if libatk1.0-dev not installed
#   -DUSE_LIBBACKTRACE=OFF     # if libbacktrace-dev not installed
#   -DENABLE_JOURNALD_LOG=OFF  # if libsystemd-dev not installed

# Build (use -j to limit parallelism if you have limited RAM)
# Each WebKit build process uses ~1.5GB RAM
ninja -C build -j$(nproc)

# Install
sudo ninja -C build install
cd ..

# === 4. Update library cache ===
sudo ldconfig

# === 5. Create the default backend symlink (OPTIONAL - only for legacy fallback) ===
# WPE looks for libWPEBackend-default.so
ARCH=$(uname -m)
if [ -f "$WPE_PREFIX/lib/${ARCH}-linux-gnu/libWPEBackend-fdo-1.0.so.1" ]; then
  sudo ln -sf "$WPE_PREFIX/lib/${ARCH}-linux-gnu/libWPEBackend-fdo-1.0.so.1" \
    "$WPE_PREFIX/lib/libWPEBackend-default.so"
elif [ -f "$WPE_PREFIX/lib/aarch64-linux-gnu/libWPEBackend-fdo-1.0.so.1" ]; then
  sudo ln -sf "$WPE_PREFIX/lib/aarch64-linux-gnu/libWPEBackend-fdo-1.0.so.1" \
    "$WPE_PREFIX/lib/libWPEBackend-default.so"
elif [ -f "$WPE_PREFIX/lib/x86_64-linux-gnu/libWPEBackend-fdo-1.0.so.1" ]; then
  sudo ln -sf "$WPE_PREFIX/lib/x86_64-linux-gnu/libWPEBackend-fdo-1.0.so.1" \
    "$WPE_PREFIX/lib/libWPEBackend-default.so"
elif [ -f "$WPE_PREFIX/lib/libWPEBackend-fdo-1.0.so.1" ]; then
  sudo ln -sf "$WPE_PREFIX/lib/libWPEBackend-fdo-1.0.so.1" \
    "$WPE_PREFIX/lib/libWPEBackend-default.so"
fi
```

#### Verify Installation

```bash
# Check pkg-config can find the libraries
pkg-config --modversion wpe-webkit-2.0
# (OPTIONAL - only for legacy fallback)
pkg-config --modversion wpebackend-fdo-1.0
pkg-config --modversion wpe-1.0
```

If pkg-config doesn't find the libraries, add the installation path:

```bash
export PKG_CONFIG_PATH=$WPE_PREFIX/lib/pkgconfig:$WPE_PREFIX/lib/$(uname -m)-linux-gnu/pkgconfig:$PKG_CONFIG_PATH
```

## Building the Flutter Plugin

The plugin automatically detects WPE libraries via pkg-config. When WPE is found, it:

1. **Compiles with the WPE backend**
2. **Bundles WPE libraries** into the Flutter app's `lib/` directory
3. **Creates necessary symlinks** so the app runs without `LD_LIBRARY_PATH`

### Build Your App

```bash
cd your_flutter_app
flutter build linux --release
```

During build, you should see messages indicating which backend is being used:

**With WPEPlatform (default):**
```
-- flutter_inappwebview_linux: Using WPE WebKit backend
-- flutter_inappwebview_linux: Found wpe-webkit-2.0 (2.50.4)
-- flutter_inappwebview_linux: Found wpe-platform-2.0 (WPEPlatform API - DEFAULT)
-- flutter_inappwebview_linux: Found wpe-platform-headless-2.0
-- flutter_inappwebview_linux: Will bundle /usr/local/lib/libWPEWebKit-2.0.so.1.6.9
-- flutter_inappwebview_linux: Will bundle /usr/local/lib/libwpe-1.0.so.1.10.0
```

**With WPEBackend-FDO (legacy fallback):**
```
-- flutter_inappwebview_linux: Using WPE WebKit backend
-- flutter_inappwebview_linux: Found wpe-webkit-2.0 (2.50.4)
-- flutter_inappwebview_linux: Found wpebackend-fdo-1.0 (Legacy FDO API)
-- flutter_inappwebview_linux: Will bundle /usr/local/lib/libWPEWebKit-2.0.so.1.6.9
-- flutter_inappwebview_linux: Will bundle /usr/local/lib/libwpe-1.0.so.1.10.0
-- flutter_inappwebview_linux: Will bundle /usr/local/lib/.../libWPEBackend-fdo-1.0.so.1.11.0
```

### Run Your App

The built app includes all WPE libraries bundled in the `lib/` directory and can be run directly:

```bash
# x64 architecture
./build/linux/x64/release/bundle/your_app

# ARM64 architecture
./build/linux/arm64/release/bundle/your_app
```

### What Gets Bundled

The following files are automatically copied to your app's `lib/` directory:

**Always bundled:**
- `libWPEWebKit-2.0.so.*` - WPE WebKit library (~160MB)
- `libwpe-1.0.so.*` - libwpe library

**With WPEPlatform (default):**
- `libWPEPlatform-2.0.so.*` - the WPEPlatform runtime linked by the plugin

**With WPEBackend-FDO (legacy):**
- `libWPEBackend-fdo-1.0.so.*` - FDO backend library
- `libWPEBackend-default.so` - Symlink to FDO backend

## Self-Contained Bundling (running without a system WPE install)

WPE WebKit is multi-process. In addition to the `.so` files above, `libWPEWebKit`
spawns helper processes and loads an injected bundle, whose locations are baked
into the library as absolute paths (`PKGLIBEXECDIR`, `PKGLIBDIR`). Bundling only
the libraries is therefore not enough for a machine without WPE installed — the
app fails with `Failed to spawn child process '.../WPENetworkProcess'`.

When available at build time, the plugin also bundles these files into `lib/`.
The set is located under the exact install prefix selected by the WPE WebKit
`pkg-config` file and staged all-or-nothing. The plugin deliberately does not
fall back independently to `/usr`, because that could combine a custom
`libWPEWebKit` with system helper processes from another version:

- `WPEWebProcess`, `WPENetworkProcess` (and `WPEGPUProcess` if present) - helper processes
- `libWPEInjectedBundle.so` - injected bundle

At startup, before any WebView is created, the plugin resolves its own directory
(via `dladdr`), restores the execute bit on the helper processes (an app's
`install(FILES)` step drops it), and — only when the full set (both helper
processes runnable + the injected bundle, plus `WPEGPUProcess` runnable when it
exists) is present — points WebKit at the bundled copies via environment
variables, set together as one unit:

- `WEBKIT_EXEC_PATH` (helper processes) - **only honored when `libWPEWebKit` was
  built with `-DDEVELOPER_MODE=ON`.** A stock distro (Debian/Ubuntu) release
  build ignores it and always uses the compile-time `PKGLIBEXECDIR`. To ship a
  self-contained app you must build WPE WebKit from source with
  `-DDEVELOPER_MODE=ON` (see the source-build section above). Without it, the app
  still requires the system helper processes to be installed.
- `WEBKIT_INJECTED_BUNDLE_PATH` - honored by all WebKit builds, but set **only on
  the bundled path** (i.e. alongside the bundled helper processes). Pairing a
  bundled injected bundle with a system web process could cause an ABI mismatch.

If any part of the set is missing/non-executable at runtime, or the paths are
already set, the plugin falls back silently to the system WPE install (existing
behavior) and sets none of the variables.

### Scope: what the plugin does NOT bundle

The plugin stages only the WPE-specific runtime pieces (helper processes,
injected bundle, and the `.so` files listed above, including WPEPlatform). It
does **not** close the
transitive shared-library dependencies of `libWPEWebKit` (ICU, libsoup,
image/media codecs, ...), whose sonames differ between distros. A truly
self-contained app must handle that closure in its packaging step — e.g. an
`ldd`-based copy of non-host libraries into the bundle `lib/` dir (see the
Otzaria CI for a working example) — or ship on a base image where those
dependencies are guaranteed.

Consumers must also install the helper processes with the execute bit
preserved: use `install(PROGRAMS ...)` (not `install(FILES ...)`) for
`WPE*Process` files in the app's `linux/CMakeLists.txt` (see
`example/linux/CMakeLists.txt`). The runtime `chmod` fallback cannot fix a
package installed root-owned (DEB/RPM) when the app runs as a regular user.

The runtime path variables are process-wide environment variables. GLib does
not guarantee that environment mutation is thread-safe on Unix, so applications
that require strict thread-safety should set `WEBKIT_EXEC_PATH`,
`WEBKIT_INJECTED_BUNDLE_PATH`, and the helper library search path in their native
launcher before starting the Flutter engine. The plugin registration fallback
is intentionally early and idempotent, but cannot make process-wide environment
updates atomic with unrelated application threads.

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
    │    │    - Modern API (WPE WebKit 2.40+)  │
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

### Blank texture with otherwise working WebKit

DMA-BUF import depends on the EGL display and driver used by Flutter, as well as
the WPE producer. Keep the default zero-copy path when it works. If a Linux/WPE
combination still displays a blank texture, start the application with:

```bash
FLUTTER_INAPPWEBVIEW_LINUX_DISABLE_ZERO_COPY=1 your_application
```

This enables WPE pixel readback and uploads those pixels through the existing GL
texture. It does not disable OpenGL or change touch, mouse, or keyboard input.
The extra GPU/CPU transfer can increase CPU usage and memory bandwidth. Like
`FLUTTER_INAPPWEBVIEW_LINUX_DISABLE_GL`, presence of the variable enables the
override, including an empty value or `0`. Unset it and restart to restore
zero-copy. Set it before creating any WebViews; changing it at runtime is unsupported.

The native regression test exercises pixel upload and subsequent frame updates
using Mesa's surfaceless EGL display, without opening an application window:

```bash
flutter precache --linux
FLUTTER_ROOT=/path/to/flutter bash linux/test/run_egl_texture_fallback_test.sh
```

### "WPE WebKit not found"

Ensure pkg-config can find the libraries:

```bash
# Core WPE WebKit library (required)
pkg-config --cflags --libs wpe-webkit-2.0
pkg-config --cflags --libs wpe-1.0

# WPEPlatform (default backend) - check if available
pkg-config --cflags --libs wpe-platform-2.0
pkg-config --cflags --libs wpe-platform-headless-2.0

# WPEBackend-FDO (legacy fallback) - check if available
pkg-config --cflags --libs wpebackend-fdo-1.0
```

If not found, add the installation prefix:

```bash
export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:/usr/local/lib/$(uname -m)-linux-gnu/pkgconfig:$PKG_CONFIG_PATH
```

### "Failed to load WPEBackend-default.so"

This error only applies to the **WPEBackend-FDO (legacy)** backend. If you're using WPEPlatform, you won't see this error.

Create the default backend symlink:

```bash
sudo ln -sf /usr/local/lib/$(uname -m)-linux-gnu/libWPEBackend-fdo-1.0.so.1 \
  /usr/local/lib/libWPEBackend-default.so
```

Or for the bundled app, ensure the symlink exists in the `lib/` directory.

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

1. CMake output for "Will bundle" messages
2. Library paths are correct in pkg-config

## Resources

- [WPE WebKit Official Site](https://wpewebkit.org/)
- [WPE WebKit API Reference](https://webkitgtk.org/reference/wpe-webkit-2.0/stable/)
- [Release Downloads](https://wpewebkit.org/release/)
- [Release Schedule](https://wpewebkit.org/release/schedule/)
