/// Key mapping tables for WPE WebKit keyboard input
/// 
/// WPE WebKit expects:
/// - key_code: XKB keysym (Unicode for printable chars, 0xFF00+ for special keys)
/// - hardware_key_code: X11 keycode (evdev scancode + 8)

import 'package:flutter/services.dart';

/// USB HID usage code to Linux evdev scancode mapping.
/// Based on Linux kernel's hid-input.c hid_keyboard[] table.
/// Reference: https://www.usb.org/sites/default/files/hut1_3_0.pdf (page 89)
const kUsbHidToEvdev = <int, int>{
  // Letters (a-z)
  0x04: 30, 0x05: 48, 0x06: 46, 0x07: 32, 0x08: 18, 0x09: 33,
  0x0a: 34, 0x0b: 35, 0x0c: 23, 0x0d: 36, 0x0e: 37, 0x0f: 38,
  0x10: 50, 0x11: 49, 0x12: 24, 0x13: 25, 0x14: 16, 0x15: 19,
  0x16: 31, 0x17: 20, 0x18: 22, 0x19: 47, 0x1a: 17, 0x1b: 45,
  0x1c: 21, 0x1d: 44,
  // Numbers (1-0)
  0x1e: 2, 0x1f: 3, 0x20: 4, 0x21: 5, 0x22: 6,
  0x23: 7, 0x24: 8, 0x25: 9, 0x26: 10, 0x27: 11,
  // Common keys
  0x28: 28,  // Enter
  0x29: 1,   // Escape
  0x2a: 14,  // Backspace
  0x2b: 15,  // Tab
  0x2c: 57,  // Space
  // Symbols
  0x2d: 12, 0x2e: 13, 0x2f: 26, 0x30: 27, 0x31: 43,
  0x33: 39, 0x34: 40, 0x35: 41, 0x36: 51, 0x37: 52, 0x38: 53,
  // Lock keys
  0x39: 58,  // CapsLock
  // Function keys (F1-F12)
  0x3a: 59, 0x3b: 60, 0x3c: 61, 0x3d: 62, 0x3e: 63, 0x3f: 64,
  0x40: 65, 0x41: 66, 0x42: 67, 0x43: 68, 0x44: 87, 0x45: 88,
  // System keys
  0x46: 99, 0x47: 70, 0x48: 119,
  // Navigation
  0x49: 110, 0x4a: 102, 0x4b: 104, 0x4c: 111, 0x4d: 107, 0x4e: 109,
  // Arrow keys
  0x4f: 106, 0x50: 105, 0x51: 108, 0x52: 103,
  // Keypad
  0x53: 69, 0x54: 98, 0x55: 55, 0x56: 74, 0x57: 78, 0x58: 96,
  0x59: 79, 0x5a: 80, 0x5b: 81, 0x5c: 75, 0x5d: 76, 0x5e: 77,
  0x5f: 71, 0x60: 72, 0x61: 73, 0x62: 82, 0x63: 83,
  // Modifiers
  0xe0: 29, 0xe1: 42, 0xe2: 56, 0xe3: 125,
  0xe4: 97, 0xe5: 54, 0xe6: 100, 0xe7: 126,
};

/// Convert USB HID usage code to X11 keycode.
/// X11 keycode = evdev scancode + 8
int usbHidToX11Keycode(int usbHid) {
  final evdev = kUsbHidToEvdev[usbHid] ?? 0;
  return evdev + 8;
}

/// X11 keysym values for special keys.
/// For printable characters, the Unicode code point IS the keysym.
int getX11Keysym(LogicalKeyboardKey key, String? character) {
  // For printable characters, use Unicode code point directly
  if (character != null && character.isNotEmpty) {
    final codeUnit = character.codeUnitAt(0);
    if (codeUnit >= 0x20 && codeUnit < 0x7f) {
      return codeUnit;  // ASCII printable -> Unicode keysym
    }
  }
  
  // Special keys use X11 keysym constants
  final keyId = key.keyId;
  
  // Function keys (F1-F12): XK_F1 = 0xffbe
  if (keyId >= LogicalKeyboardKey.f1.keyId && 
      keyId <= LogicalKeyboardKey.f12.keyId) {
    return 0xffbe + (keyId - LogicalKeyboardKey.f1.keyId);
  }
  
  // Special key mapping
  return _specialKeyToKeysym[keyId] ?? (keyId & 0xFFFF);
}

const _specialKeyToKeysym = <int, int>{
  0x100000008: 0xff08,  // Backspace
  0x100000009: 0xff09,  // Tab
  0x10000000d: 0xff0d,  // Enter
  0x10000001b: 0xff1b,  // Escape
  0x10000007f: 0xffff,  // Delete
  0x100000301: 0xff50,  // Home
  0x100000302: 0xff57,  // End
  0x100000304: 0xff51,  // ArrowLeft
  0x100000305: 0xff52,  // ArrowUp
  0x100000306: 0xff53,  // ArrowRight
  0x100000307: 0xff54,  // ArrowDown
  0x100000308: 0xff55,  // PageUp
  0x100000309: 0xff56,  // PageDown
  0x100000407: 0xff63,  // Insert
  0x20: 0x0020,         // Space
};
