import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';

class IdGenerator {
  static int _count = 0;

  /// Math.Random()-based RNG. All platforms, fast, not cryptographically strong. Optional Seed passable.
  static Uint8List mathRNG({int seed = -1}) {
    var b = Uint8List(16);

    var rand = (seed == -1) ? Random() : Random(seed);

    for (var i = 0; i < 16; i++) {
      b[i] = rand.nextInt(256);
    }

    (seed == -1) ? b.shuffle() : b.shuffle(Random(seed));

    return b;
  }

  /// Crypto-Strong RNG. All platforms, unknown speed, cryptographically strong (theoretically)
  static Uint8List cryptoRNG() {
    var b = Uint8List(16);
    var rand = Random.secure();
    for (var i = 0; i < 16; i++) {
      b[i] = rand.nextInt(256);
    }
    return b;
  }

  static String generate() {
    _count++;
    return _count.toString() + cryptoRNG().map((e) => e.toString()).join('');
  }
}

extension UtilColor on Color {
  static Color? fromStringRepresentation(String colorValue) {
    if (colorValue.startsWith("#")) {
      return fromHex(colorValue);
    } else if (colorValue.startsWith("rgb(")) {
      return fromRgbString(colorValue);
    } else if (colorValue.startsWith("rgba(")) {
      return fromRgbaString(colorValue);
    } else if (colorValue.startsWith("hls(")) {
      return fromHlsString(colorValue);
    } else if (colorValue.startsWith("hlsa(")) {
      return fromHlsaString(colorValue);
    } else {
      /**
          This part of the code is generated using the JavaScript code below on this link: https://drafts.csswg.org/css-color/#typedef-color


          let code = 'switch(colorValue) {\n';
          const table = document.querySelector('.named-color-table');
          const colorNameCells = table.querySelectorAll('tr > th dfn');
          const colorHexValueCells = table.querySelectorAll('tr > td:nth-child(4)');
          for (let i = 0; i < colorNameCells.length; i++) {
          const colorName = colorNameCells[i].textContent.trim();
          const colorHexValue = colorHexValueCells[i].textContent.trim();
          code += '  case "' + colorName + '":\n';
          code += '     return getColorFromHex("' + colorHexValue + '");\n';
          }
          code += '}';
       */

      switch (colorValue) {
        case "aliceblue":
          return fromHex("#f0f8ff");
        case "antiquewhite":
          return fromHex("#faebd7");
        case "aqua":
          return fromHex("#00ffff");
        case "aquamarine":
          return fromHex("#7fffd4");
        case "azure":
          return fromHex("#f0ffff");
        case "beige":
          return fromHex("#f5f5dc");
        case "bisque":
          return fromHex("#ffe4c4");
        case "black":
          return fromHex("#000000");
        case "blanchedalmond":
          return fromHex("#ffebcd");
        case "blue":
          return fromHex("#0000ff");
        case "blueviolet":
          return fromHex("#8a2be2");
        case "brown":
          return fromHex("#a52a2a");
        case "burlywood":
          return fromHex("#deb887");
        case "cadetblue":
          return fromHex("#5f9ea0");
        case "chartreuse":
          return fromHex("#7fff00");
        case "chocolate":
          return fromHex("#d2691e");
        case "coral":
          return fromHex("#ff7f50");
        case "cornflowerblue":
          return fromHex("#6495ed");
        case "cornsilk":
          return fromHex("#fff8dc");
        case "crimson":
          return fromHex("#dc143c");
        case "cyan":
          return fromHex("#00ffff");
        case "darkblue":
          return fromHex("#00008b");
        case "darkcyan":
          return fromHex("#008b8b");
        case "darkgoldenrod":
          return fromHex("#b8860b");
        case "darkgray":
          return fromHex("#a9a9a9");
        case "darkgreen":
          return fromHex("#006400");
        case "darkgrey":
          return fromHex("#a9a9a9");
        case "darkkhaki":
          return fromHex("#bdb76b");
        case "darkmagenta":
          return fromHex("#8b008b");
        case "darkolivegreen":
          return fromHex("#556b2f");
        case "darkorange":
          return fromHex("#ff8c00");
        case "darkorchid":
          return fromHex("#9932cc");
        case "darkred":
          return fromHex("#8b0000");
        case "darksalmon":
          return fromHex("#e9967a");
        case "darkseagreen":
          return fromHex("#8fbc8f");
        case "darkslateblue":
          return fromHex("#483d8b");
        case "darkslategray":
          return fromHex("#2f4f4f");
        case "darkslategrey":
          return fromHex("#2f4f4f");
        case "darkturquoise":
          return fromHex("#00ced1");
        case "darkviolet":
          return fromHex("#9400d3");
        case "deeppink":
          return fromHex("#ff1493");
        case "deepskyblue":
          return fromHex("#00bfff");
        case "dimgray":
          return fromHex("#696969");
        case "dimgrey":
          return fromHex("#696969");
        case "dodgerblue":
          return fromHex("#1e90ff");
        case "firebrick":
          return fromHex("#b22222");
        case "floralwhite":
          return fromHex("#fffaf0");
        case "forestgreen":
          return fromHex("#228b22");
        case "fuchsia":
          return fromHex("#ff00ff");
        case "gainsboro":
          return fromHex("#dcdcdc");
        case "ghostwhite":
          return fromHex("#f8f8ff");
        case "gold":
          return fromHex("#ffd700");
        case "goldenrod":
          return fromHex("#daa520");
        case "gray":
          return fromHex("#808080");
        case "green":
          return fromHex("#008000");
        case "greenyellow":
          return fromHex("#adff2f");
        case "grey":
          return fromHex("#808080");
        case "honeydew":
          return fromHex("#f0fff0");
        case "hotpink":
          return fromHex("#ff69b4");
        case "indianred":
          return fromHex("#cd5c5c");
        case "indigo":
          return fromHex("#4b0082");
        case "ivory":
          return fromHex("#fffff0");
        case "khaki":
          return fromHex("#f0e68c");
        case "lavender":
          return fromHex("#e6e6fa");
        case "lavenderblush":
          return fromHex("#fff0f5");
        case "lawngreen":
          return fromHex("#7cfc00");
        case "lemonchiffon":
          return fromHex("#fffacd");
        case "lightblue":
          return fromHex("#add8e6");
        case "lightcoral":
          return fromHex("#f08080");
        case "lightcyan":
          return fromHex("#e0ffff");
        case "lightgoldenrodyellow":
          return fromHex("#fafad2");
        case "lightgray":
          return fromHex("#d3d3d3");
        case "lightgreen":
          return fromHex("#90ee90");
        case "lightgrey":
          return fromHex("#d3d3d3");
        case "lightpink":
          return fromHex("#ffb6c1");
        case "lightsalmon":
          return fromHex("#ffa07a");
        case "lightseagreen":
          return fromHex("#20b2aa");
        case "lightskyblue":
          return fromHex("#87cefa");
        case "lightslategray":
          return fromHex("#778899");
        case "lightslategrey":
          return fromHex("#778899");
        case "lightsteelblue":
          return fromHex("#b0c4de");
        case "lightyellow":
          return fromHex("#ffffe0");
        case "lime":
          return fromHex("#00ff00");
        case "limegreen":
          return fromHex("#32cd32");
        case "linen":
          return fromHex("#faf0e6");
        case "magenta":
          return fromHex("#ff00ff");
        case "maroon":
          return fromHex("#800000");
        case "mediumaquamarine":
          return fromHex("#66cdaa");
        case "mediumblue":
          return fromHex("#0000cd");
        case "mediumorchid":
          return fromHex("#ba55d3");
        case "mediumpurple":
          return fromHex("#9370db");
        case "mediumseagreen":
          return fromHex("#3cb371");
        case "mediumslateblue":
          return fromHex("#7b68ee");
        case "mediumspringgreen":
          return fromHex("#00fa9a");
        case "mediumturquoise":
          return fromHex("#48d1cc");
        case "mediumvioletred":
          return fromHex("#c71585");
        case "midnightblue":
          return fromHex("#191970");
        case "mintcream":
          return fromHex("#f5fffa");
        case "mistyrose":
          return fromHex("#ffe4e1");
        case "moccasin":
          return fromHex("#ffe4b5");
        case "navajowhite":
          return fromHex("#ffdead");
        case "navy":
          return fromHex("#000080");
        case "oldlace":
          return fromHex("#fdf5e6");
        case "olive":
          return fromHex("#808000");
        case "olivedrab":
          return fromHex("#6b8e23");
        case "orange":
          return fromHex("#ffa500");
        case "orangered":
          return fromHex("#ff4500");
        case "orchid":
          return fromHex("#da70d6");
        case "palegoldenrod":
          return fromHex("#eee8aa");
        case "palegreen":
          return fromHex("#98fb98");
        case "paleturquoise":
          return fromHex("#afeeee");
        case "palevioletred":
          return fromHex("#db7093");
        case "papayawhip":
          return fromHex("#ffefd5");
        case "peachpuff":
          return fromHex("#ffdab9");
        case "peru":
          return fromHex("#cd853f");
        case "pink":
          return fromHex("#ffc0cb");
        case "plum":
          return fromHex("#dda0dd");
        case "powderblue":
          return fromHex("#b0e0e6");
        case "purple":
          return fromHex("#800080");
        case "rebeccapurple":
          return fromHex("#663399");
        case "red":
          return fromHex("#ff0000");
        case "rosybrown":
          return fromHex("#bc8f8f");
        case "royalblue":
          return fromHex("#4169e1");
        case "saddlebrown":
          return fromHex("#8b4513");
        case "salmon":
          return fromHex("#fa8072");
        case "sandybrown":
          return fromHex("#f4a460");
        case "seagreen":
          return fromHex("#2e8b57");
        case "seashell":
          return fromHex("#fff5ee");
        case "sienna":
          return fromHex("#a0522d");
        case "silver":
          return fromHex("#c0c0c0");
        case "skyblue":
          return fromHex("#87ceeb");
        case "slateblue":
          return fromHex("#6a5acd");
        case "slategray":
          return fromHex("#708090");
        case "slategrey":
          return fromHex("#708090");
        case "snow":
          return fromHex("#fffafa");
        case "springgreen":
          return fromHex("#00ff7f");
        case "steelblue":
          return fromHex("#4682b4");
        case "tan":
          return fromHex("#d2b48c");
        case "teal":
          return fromHex("#008080");
        case "thistle":
          return fromHex("#d8bfd8");
        case "tomato":
          return fromHex("#ff6347");
        case "turquoise":
          return fromHex("#40e0d0");
        case "violet":
          return fromHex("#ee82ee");
        case "wheat":
          return fromHex("#f5deb3");
        case "white":
          return fromHex("#ffffff");
        case "whitesmoke":
          return fromHex("#f5f5f5");
        case "yellow":
          return fromHex("#ffff00");
        case "yellowgreen":
          return fromHex("#9acd32");
      }
    }
    return null;
  }

  static Color? fromHex(String? hexString) {
    if (hexString == null) {
      return null;
    }

    hexString = hexString.trim();
    if (hexString.length == 4) {
      // convert for example #f00 to #ff0000
      hexString =
          "#" + (hexString[1] * 2) + (hexString[2] * 2) + (hexString[3] * 2);
    }
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  static Color? fromRgbString(String? rgbString) {
    if (rgbString == null) {
      return null;
    }

    rgbString = rgbString.trim();
    var rgbValues = rgbString
        .substring(4, rgbString.length - 1)
        .split(",")
        .map((rbgValue) => int.parse(rbgValue.trim()))
        .toList();
    return Color.fromRGBO(rgbValues[0], rgbValues[1], rgbValues[2], 1);
  }

  static Color? fromRgbaString(String? rgbaString) {
    if (rgbaString == null) {
      return null;
    }

    rgbaString = rgbaString.trim();
    var rgbaValues = rgbaString
        .substring(5, rgbaString.length - 1)
        .split(",")
        .map((rbgValue) => rbgValue.trim())
        .toList();
    return Color.fromRGBO(int.parse(rgbaValues[0]), int.parse(rgbaValues[1]),
        int.parse(rgbaValues[2]), double.parse(rgbaValues[3]));
  }

  static Color? fromHlsString(String? hlsString) {
    if (hlsString == null) {
      return null;
    }

    hlsString = hlsString.trim();
    var hlsValues = hlsString
        .substring(4, hlsString.length - 1)
        .split(",")
        .map((rbgValue) => double.parse(rbgValue.trim()))
        .toList();
    var rgbValues = _hslToRgb(hlsValues[0], hlsValues[1], hlsValues[2]);
    return Color.fromRGBO(rgbValues[0], rgbValues[1], rgbValues[2], 1);
  }

  static Color? fromHlsaString(String? hlsaString) {
    if (hlsaString == null) {
      return null;
    }

    hlsaString = hlsaString.trim();
    var hlsaValues = hlsaString
        .substring(5, hlsaString.length - 1)
        .split(",")
        .map((rbgValue) => double.parse(rbgValue.trim()))
        .toList();
    var rgbaValues = _hslToRgb(hlsaValues[0], hlsaValues[1], hlsaValues[2]);
    return Color.fromRGBO(
        rgbaValues[0], rgbaValues[1], rgbaValues[2], hlsaValues[3]);
  }

  static List<int> _hslToRgb(double h, double s, double l) {
    double r, g, b;

    if (s == 0) {
      r = g = b = l; // achromatic
    } else {
      double q = l < 0.5 ? l * (1 + s) : l + s - l * s;
      double p = 2 * l - q;
      r = _hueToRgb(p, q, h + 1 / 3);
      g = _hueToRgb(p, q, h);
      b = _hueToRgb(p, q, h - 1 / 3);
    }
    var rgb = [_to255(r), _to255(g), _to255(b)];
    return rgb;
  }

  static int _to255(double v) {
    return min(255, (256 * v).round());
  }

  /// Helper method that converts hue to rgb
  static double _hueToRgb(double p, double q, double t) {
    if (t < 0) t += 1;
    if (t > 1) t -= 1;
    if (t < 1 / 6) return p + (q - p) * 6 * t;
    if (t < 1 / 2) return q;
    if (t < 2 / 3) return p + (q - p) * (2 / 3 - t) * 6;
    return p;
  }
}

extension HexColor on Color {
  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
  String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
      '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}

extension MapSize on Size {
  static Size? fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return null;
    }
    return Size(map["width"] ?? -1.0, map["height"] ?? -1.0);
  }

  Map<String, double> toJson() {
    return toMap();
  }

  Map<String, double> toMap() {
    return {'width': width, 'height': height};
  }
}
