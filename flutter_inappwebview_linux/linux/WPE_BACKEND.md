# WPE WebKit Backend for flutter_inappwebview_linux

This document describes how to install and configure WPE WebKit for the flutter_inappwebview Linux plugin.

## Overview

This plugin uses WPE WebKit for offscreen web rendering. WPE WebKit is the official WebKit port for embedded systems:

1. **Designed for headless/offscreen rendering** - No GTK widget hierarchy required
2. **Excellent GPU integration** - Uses DMA-BUF for zero-copy texture sharing with Flutter
3. **Lower memory footprint** - No widget hierarchy overhead
4. **Perfect for embedded systems** - Raspberry Pi, set-top boxes, kiosks, etc.

The WPE backend exports frames directly as GPU textures via DMA-BUF or SHM buffers.

## Installation Options

You can either:
1. **Use pre-built packages** from your distribution (if available)
2. **Build from source** using official tarball releases (recommended for latest features)

### Option 1: Install from Distribution Packages

Some distributions provide WPE WebKit packages:

- **Debian/Ubuntu**: `sudo apt install libwpewebkit-1.0-dev libwpebackend-fdo-1.0-dev`
- **Arch Linux**: `sudo pacman -S wpewebkit`
- **Fedora**: Available via COPR

> **Note:** Distribution packages may be outdated. For the latest features and security fixes, building from source is recommended.

> **Note on Snaps and Flatpaks:** Installing WPE WebKit via Snap (`wpe-webkit-mir-kiosk`) or Flatpak (`org.wpewebkit.WPEWebKit`) provides a standalone browser application. **These do not provide the development headers and libraries required to build this plugin.** You must install the `dev` packages via `apt` or build from source.

### Option 2: Build from Source (Recommended)

#### Prerequisites

Install all required build dependencies:

```bash
# Core build tools
sudo apt-get install -y \
  build-essential cmake ninja-build meson pkg-config \
  ruby ruby-dev python3 python3-pip \
  gperf unifdef

# GLib and GObject introspection
sudo apt-get install -y \
  libglib2.0-dev \
  gobject-introspection libgirepository1.0-dev

# Networking and security
sudo apt-get install -y \
  libsoup-3.0-dev \
  libssl-dev libgnutls28-dev \
  libsecret-1-dev \
  libgcrypt20-dev

# Graphics and rendering
sudo apt-get install -y \
  libepoxy-dev \
  libegl1-mesa-dev libgles2-mesa-dev \
  libdrm-dev libgbm-dev \
  libxkbcommon-dev

# Image and font processing
sudo apt-get install -y \
  libjpeg-dev libpng-dev libwebp-dev libopenjp2-7-dev libavif-dev \
  libharfbuzz-dev libwoff-dev libfreetype6-dev libfontconfig1-dev

# Text and internationalization
sudo apt-get install -y \
  libicu-dev libxml2-dev libxslt1-dev \
  libhyphen-dev libenchant-2-dev

# Media and audio
sudo apt-get install -y \
  libgstreamer1.0-dev \
  libgstreamer-plugins-base1.0-dev \
  libgstreamer-plugins-bad1.0-dev \
  gstreamer1.0-plugins-base gstreamer1.0-plugins-good

# Input and gamepad support
sudo apt-get install -y \
  libmanette-0.2-dev libevdev-dev

# Database and storage
sudo apt-get install -y \
  libsqlite3-dev

# Security sandboxing
sudo apt-get install -y \
  libseccomp-dev libsystemd-dev bubblewrap xdg-dbus-proxy

# Additional dependencies
sudo apt-get install -y \
  libnotify-dev \
  libatk1.0-dev libatk-bridge2.0-dev \
  liblcms2-dev
```

#### Download Official Tarballs

Download the official release tarballs from [wpewebkit.org](https://wpewebkit.org/about/get-wpe.html).

##### Stable Releases (Recommended for Production)

| Component | Version | Download |
|-----------|---------|----------|
| libwpe | 1.16.3 | https://wpewebkit.org/releases/libwpe-1.16.3.tar.xz |
| WPEBackend-fdo | 1.16.1 | https://wpewebkit.org/releases/wpebackend-fdo-1.16.1.tar.xz |
| WPE WebKit | 2.50.4 | https://wpewebkit.org/releases/wpewebkit-2.50.4.tar.xz |

##### Unstable Releases (Development/Preview)

| Component | Version | Download |
|-----------|---------|----------|
| libwpe | 1.15.2 | https://wpewebkit.org/releases/libwpe-1.15.2.tar.xz |
| WPEBackend-fdo | 1.15.90 | https://wpewebkit.org/releases/wpebackend-fdo-1.15.90.tar.xz |
| WPE WebKit | 2.51.4 | https://wpewebkit.org/releases/wpewebkit-2.51.4.tar.xz |

> **Note:** Check [wpewebkit.org/release/](https://wpewebkit.org/release/) for the latest versions.

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

# === 2. Build WPEBackend-fdo ===
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
cmake -B build -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=$WPE_PREFIX \
  -DPORT=WPE \
  -DENABLE_DOCUMENTATION=OFF \
  -DENABLE_INTROSPECTION=OFF \
  -DENABLE_BUBBLEWRAP_SANDBOX=ON \
  -DENABLE_WEBDRIVER=OFF \
  -DENABLE_MINIBROWSER=OFF \
  -DUSE_SOUP2=OFF \
  -DUSE_AVIF=ON \
  -DUSE_WOFF2=ON

# Build (use -j to limit parallelism if you have limited RAM)
# Each WebKit build process uses ~1.5GB RAM
ninja -C build -j$(nproc)

# Install
sudo ninja -C build install
cd ..

# === 4. Update library cache ===
sudo ldconfig

# === 5. Create the default backend symlink ===
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

During build, you should see messages like:

```
-- flutter_inappwebview_linux: Using WPE WebKit backend
-- flutter_inappwebview_linux: Found wpe-webkit-2.0 (2.50.4)
-- flutter_inappwebview_linux: Found wpebackend-fdo-1.0 (DMA-BUF support enabled)
-- flutter_inappwebview_linux: Will bundle /usr/local/lib/libWPEWebKit-2.0.so.1.6.9
-- flutter_inappwebview_linux: Will bundle /usr/local/lib/libwpe-1.0.so.1.10.0
-- flutter_inappwebview_linux: Will bundle /usr/local/lib/.../libWPEBackend-fdo-1.0.so.1.11.0
```

### Run Your App

The built app includes all WPE libraries bundled in the `lib/` directory. A launcher script is automatically generated that sets the required `LD_LIBRARY_PATH`:

```bash
# Use the launcher script (recommended)
./build/linux/x64/release/bundle/your_app.sh

# Or on ARM64:
./build/linux/arm64/release/bundle/your_app.sh
```

> **Note:** The launcher script is required because `libwpe` uses `dlopen()` to dynamically load the WPE backend library (`libWPEBackend-default.so`), which doesn't respect RPATH. The script sets `LD_LIBRARY_PATH` to include the bundled libraries.

Alternatively, you can run the binary directly by setting the environment variable:

```bash
LD_LIBRARY_PATH=./lib:$LD_LIBRARY_PATH ./your_app
```

### What Gets Bundled

The following files are automatically copied to your app's `lib/` directory:

- `libWPEWebKit-2.0.so.*` - WPE WebKit library (~160MB)
- `libwpe-1.0.so.*` - libwpe library
- `libWPEBackend-fdo-1.0.so.*` - FDO backend library
- `libWPEBackend-default.so` - Symlink to FDO backend

Additionally, a launcher script (`your_app.sh`) is created in the bundle directory that sets the library path automatically.

## Runtime Environment Variables

| Variable | Description |
|----------|-------------|
| `FLUTTER_INAPPWEBVIEW_LINUX_DEBUG=1` | Enable debug logging |
| `FLUTTER_INAPPWEBVIEW_LINUX_WPE_INSPECTOR=1` | Enable remote web inspector |
| `FLUTTER_INAPPWEBVIEW_LINUX_WPE_INSPECTOR_PORT=9222` | Web inspector port |

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
    │    WPE Backend (FDO)
    │         │
    │         ▼
    └──► Flutter Texture ◄──── SHM Buffer / DMA-BUF
```

### Frame Export Flow

1. WPE WebKit renders a frame using GPU
2. `wpebackend-fdo` exports the frame as a SHM buffer or DMA-BUF
3. The export callback receives the buffer data
4. Buffer is converted to RGBA and uploaded to Flutter texture
5. Flutter composites the webview texture into the scene

### Input Handling

Input events are forwarded to WPE's backend:

- Pointer events → `wpe_view_backend_dispatch_pointer_event()`
- Keyboard events → `wpe_view_backend_dispatch_keyboard_event()`  
- Axis (scroll) events → `wpe_view_backend_dispatch_axis_event()`

Keyboard modifiers (Ctrl, Shift, Alt, Meta) and shortcuts (Ctrl+A, Ctrl+C, Ctrl+V, etc.) are properly mapped to X11 keysyms.

### Cursor Handling

The plugin detects cursor changes via:
- WebKit's `mouse-target-changed` signal for links, editable content, etc.
- JavaScript injection for CSS `cursor` property detection

Cursor types are mapped to Flutter's cursor system: pointer, text, grab, resize, forbidden, etc.

## Troubleshooting

### "WPE WebKit not found"

Ensure pkg-config can find the libraries:

```bash
pkg-config --cflags --libs wpe-webkit-2.0
pkg-config --cflags --libs wpebackend-fdo-1.0
pkg-config --cflags --libs wpe-1.0
```

If not found, add the installation prefix:

```bash
export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:/usr/local/lib/$(uname -m)-linux-gnu/pkgconfig:$PKG_CONFIG_PATH
```

### "Failed to load WPEBackend-default.so"

Create the default backend symlink:

```bash
sudo ln -sf /usr/local/lib/$(uname -m)-linux-gnu/libWPEBackend-fdo-1.0.so.1 \
  /usr/local/lib/libWPEBackend-default.so
```

Or for the bundled app, ensure the symlink exists in the `lib/` directory.

### Blank webview

Enable debug logging:

```bash
FLUTTER_INAPPWEBVIEW_LINUX_DEBUG=1 ./your_app
```

Check for errors related to:
- EGL context creation
- SHM buffer allocation
- WebKit rendering

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

### App crashes on startup

Run with debug logging and check for:

```bash
FLUTTER_INAPPWEBVIEW_LINUX_DEBUG=1 ./your_app 2>&1 | head -50
```

Common issues:
- Missing library symlinks in `lib/`
- Mismatched library versions
- Missing `libWPEBackend-default.so`

### Debug mode fails with "could not load the impl library"

When running in Flutter debug mode via VS Code or `flutter run`, the app runs without the launcher script, so `LD_LIBRARY_PATH` is not set. The `libwpe` library uses `dlopen()` to load the backend, which doesn't find the bundled libraries.

**Solution 1: Use VS Code launch configuration**

Create `.vscode/launch.json` in your project:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Flutter Linux (Debug)",
      "type": "dart",
      "request": "launch",
      "program": "lib/main.dart",
      "env": {
        "LD_LIBRARY_PATH": "${workspaceFolder}/build/linux/arm64/debug/bundle/lib"
      }
    }
  ]
}
```

> **Note:** Adjust `arm64` to `x64` on x86_64 systems.

**Solution 2: Run from terminal with environment variable**

```bash
cd your_flutter_app
flutter build linux --debug
LD_LIBRARY_PATH=./build/linux/arm64/debug/bundle/lib:$LD_LIBRARY_PATH flutter run -d linux
```

**Solution 3: Install WPE libraries system-wide**

If you installed WPE to `/usr/local`, ensure the library cache is updated:

```bash
# Update library cache
sudo ldconfig

# Create symlink in system path if not already done
sudo ln -sf /usr/local/lib/libWPEBackend-fdo-1.0.so.1 /usr/local/lib/libWPEBackend-default.so
# Or for arch-specific path:
sudo ln -sf /usr/local/lib/aarch64-linux-gnu/libWPEBackend-fdo-1.0.so.1 /usr/local/lib/libWPEBackend-default.so
```

This makes the libraries findable system-wide, so debug mode works without extra configuration.

## Resources

- [WPE WebKit Official Site](https://wpewebkit.org/)
- [WPE WebKit API Reference](https://webkitgtk.org/reference/wpe-webkit-2.0/stable/)
- [Release Downloads](https://wpewebkit.org/release/)
- [Release Schedule](https://wpewebkit.org/release/schedule/)
