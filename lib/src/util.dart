import 'dart:math';

import 'package:flutter/material.dart';

class Util {
  static Color convertColorFromStringRepresentation(String colorValue) {
    if (colorValue.startsWith("#")) {
      return Util.getColorFromHex(colorValue);
    } else if (colorValue.startsWith("rgb(")) {
      return Util.getColorFromRgbString(colorValue);
    } else if (colorValue.startsWith("rgba(")) {
      return Util.getColorFromRgbaString(colorValue);
    } else if (colorValue.startsWith("hls(")) {
      return Util.getColorFromHlsString(colorValue);
    } else if (colorValue.startsWith("hlsa(")) {
      return Util.getColorFromHlsaString(colorValue);
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
          code += '     return Util.getColorFromHex("' + colorHexValue + '");\n';
        }
        code += '}';
      */

      switch (colorValue) {
        case "aliceblue":
          return Util.getColorFromHex("#f0f8ff");
        case "antiquewhite":
          return Util.getColorFromHex("#faebd7");
        case "aqua":
          return Util.getColorFromHex("#00ffff");
        case "aquamarine":
          return Util.getColorFromHex("#7fffd4");
        case "azure":
          return Util.getColorFromHex("#f0ffff");
        case "beige":
          return Util.getColorFromHex("#f5f5dc");
        case "bisque":
          return Util.getColorFromHex("#ffe4c4");
        case "black":
          return Util.getColorFromHex("#000000");
        case "blanchedalmond":
          return Util.getColorFromHex("#ffebcd");
        case "blue":
          return Util.getColorFromHex("#0000ff");
        case "blueviolet":
          return Util.getColorFromHex("#8a2be2");
        case "brown":
          return Util.getColorFromHex("#a52a2a");
        case "burlywood":
          return Util.getColorFromHex("#deb887");
        case "cadetblue":
          return Util.getColorFromHex("#5f9ea0");
        case "chartreuse":
          return Util.getColorFromHex("#7fff00");
        case "chocolate":
          return Util.getColorFromHex("#d2691e");
        case "coral":
          return Util.getColorFromHex("#ff7f50");
        case "cornflowerblue":
          return Util.getColorFromHex("#6495ed");
        case "cornsilk":
          return Util.getColorFromHex("#fff8dc");
        case "crimson":
          return Util.getColorFromHex("#dc143c");
        case "cyan":
          return Util.getColorFromHex("#00ffff");
        case "darkblue":
          return Util.getColorFromHex("#00008b");
        case "darkcyan":
          return Util.getColorFromHex("#008b8b");
        case "darkgoldenrod":
          return Util.getColorFromHex("#b8860b");
        case "darkgray":
          return Util.getColorFromHex("#a9a9a9");
        case "darkgreen":
          return Util.getColorFromHex("#006400");
        case "darkgrey":
          return Util.getColorFromHex("#a9a9a9");
        case "darkkhaki":
          return Util.getColorFromHex("#bdb76b");
        case "darkmagenta":
          return Util.getColorFromHex("#8b008b");
        case "darkolivegreen":
          return Util.getColorFromHex("#556b2f");
        case "darkorange":
          return Util.getColorFromHex("#ff8c00");
        case "darkorchid":
          return Util.getColorFromHex("#9932cc");
        case "darkred":
          return Util.getColorFromHex("#8b0000");
        case "darksalmon":
          return Util.getColorFromHex("#e9967a");
        case "darkseagreen":
          return Util.getColorFromHex("#8fbc8f");
        case "darkslateblue":
          return Util.getColorFromHex("#483d8b");
        case "darkslategray":
          return Util.getColorFromHex("#2f4f4f");
        case "darkslategrey":
          return Util.getColorFromHex("#2f4f4f");
        case "darkturquoise":
          return Util.getColorFromHex("#00ced1");
        case "darkviolet":
          return Util.getColorFromHex("#9400d3");
        case "deeppink":
          return Util.getColorFromHex("#ff1493");
        case "deepskyblue":
          return Util.getColorFromHex("#00bfff");
        case "dimgray":
          return Util.getColorFromHex("#696969");
        case "dimgrey":
          return Util.getColorFromHex("#696969");
        case "dodgerblue":
          return Util.getColorFromHex("#1e90ff");
        case "firebrick":
          return Util.getColorFromHex("#b22222");
        case "floralwhite":
          return Util.getColorFromHex("#fffaf0");
        case "forestgreen":
          return Util.getColorFromHex("#228b22");
        case "fuchsia":
          return Util.getColorFromHex("#ff00ff");
        case "gainsboro":
          return Util.getColorFromHex("#dcdcdc");
        case "ghostwhite":
          return Util.getColorFromHex("#f8f8ff");
        case "gold":
          return Util.getColorFromHex("#ffd700");
        case "goldenrod":
          return Util.getColorFromHex("#daa520");
        case "gray":
          return Util.getColorFromHex("#808080");
        case "green":
          return Util.getColorFromHex("#008000");
        case "greenyellow":
          return Util.getColorFromHex("#adff2f");
        case "grey":
          return Util.getColorFromHex("#808080");
        case "honeydew":
          return Util.getColorFromHex("#f0fff0");
        case "hotpink":
          return Util.getColorFromHex("#ff69b4");
        case "indianred":
          return Util.getColorFromHex("#cd5c5c");
        case "indigo":
          return Util.getColorFromHex("#4b0082");
        case "ivory":
          return Util.getColorFromHex("#fffff0");
        case "khaki":
          return Util.getColorFromHex("#f0e68c");
        case "lavender":
          return Util.getColorFromHex("#e6e6fa");
        case "lavenderblush":
          return Util.getColorFromHex("#fff0f5");
        case "lawngreen":
          return Util.getColorFromHex("#7cfc00");
        case "lemonchiffon":
          return Util.getColorFromHex("#fffacd");
        case "lightblue":
          return Util.getColorFromHex("#add8e6");
        case "lightcoral":
          return Util.getColorFromHex("#f08080");
        case "lightcyan":
          return Util.getColorFromHex("#e0ffff");
        case "lightgoldenrodyellow":
          return Util.getColorFromHex("#fafad2");
        case "lightgray":
          return Util.getColorFromHex("#d3d3d3");
        case "lightgreen":
          return Util.getColorFromHex("#90ee90");
        case "lightgrey":
          return Util.getColorFromHex("#d3d3d3");
        case "lightpink":
          return Util.getColorFromHex("#ffb6c1");
        case "lightsalmon":
          return Util.getColorFromHex("#ffa07a");
        case "lightseagreen":
          return Util.getColorFromHex("#20b2aa");
        case "lightskyblue":
          return Util.getColorFromHex("#87cefa");
        case "lightslategray":
          return Util.getColorFromHex("#778899");
        case "lightslategrey":
          return Util.getColorFromHex("#778899");
        case "lightsteelblue":
          return Util.getColorFromHex("#b0c4de");
        case "lightyellow":
          return Util.getColorFromHex("#ffffe0");
        case "lime":
          return Util.getColorFromHex("#00ff00");
        case "limegreen":
          return Util.getColorFromHex("#32cd32");
        case "linen":
          return Util.getColorFromHex("#faf0e6");
        case "magenta":
          return Util.getColorFromHex("#ff00ff");
        case "maroon":
          return Util.getColorFromHex("#800000");
        case "mediumaquamarine":
          return Util.getColorFromHex("#66cdaa");
        case "mediumblue":
          return Util.getColorFromHex("#0000cd");
        case "mediumorchid":
          return Util.getColorFromHex("#ba55d3");
        case "mediumpurple":
          return Util.getColorFromHex("#9370db");
        case "mediumseagreen":
          return Util.getColorFromHex("#3cb371");
        case "mediumslateblue":
          return Util.getColorFromHex("#7b68ee");
        case "mediumspringgreen":
          return Util.getColorFromHex("#00fa9a");
        case "mediumturquoise":
          return Util.getColorFromHex("#48d1cc");
        case "mediumvioletred":
          return Util.getColorFromHex("#c71585");
        case "midnightblue":
          return Util.getColorFromHex("#191970");
        case "mintcream":
          return Util.getColorFromHex("#f5fffa");
        case "mistyrose":
          return Util.getColorFromHex("#ffe4e1");
        case "moccasin":
          return Util.getColorFromHex("#ffe4b5");
        case "navajowhite":
          return Util.getColorFromHex("#ffdead");
        case "navy":
          return Util.getColorFromHex("#000080");
        case "oldlace":
          return Util.getColorFromHex("#fdf5e6");
        case "olive":
          return Util.getColorFromHex("#808000");
        case "olivedrab":
          return Util.getColorFromHex("#6b8e23");
        case "orange":
          return Util.getColorFromHex("#ffa500");
        case "orangered":
          return Util.getColorFromHex("#ff4500");
        case "orchid":
          return Util.getColorFromHex("#da70d6");
        case "palegoldenrod":
          return Util.getColorFromHex("#eee8aa");
        case "palegreen":
          return Util.getColorFromHex("#98fb98");
        case "paleturquoise":
          return Util.getColorFromHex("#afeeee");
        case "palevioletred":
          return Util.getColorFromHex("#db7093");
        case "papayawhip":
          return Util.getColorFromHex("#ffefd5");
        case "peachpuff":
          return Util.getColorFromHex("#ffdab9");
        case "peru":
          return Util.getColorFromHex("#cd853f");
        case "pink":
          return Util.getColorFromHex("#ffc0cb");
        case "plum":
          return Util.getColorFromHex("#dda0dd");
        case "powderblue":
          return Util.getColorFromHex("#b0e0e6");
        case "purple":
          return Util.getColorFromHex("#800080");
        case "rebeccapurple":
          return Util.getColorFromHex("#663399");
        case "red":
          return Util.getColorFromHex("#ff0000");
        case "rosybrown":
          return Util.getColorFromHex("#bc8f8f");
        case "royalblue":
          return Util.getColorFromHex("#4169e1");
        case "saddlebrown":
          return Util.getColorFromHex("#8b4513");
        case "salmon":
          return Util.getColorFromHex("#fa8072");
        case "sandybrown":
          return Util.getColorFromHex("#f4a460");
        case "seagreen":
          return Util.getColorFromHex("#2e8b57");
        case "seashell":
          return Util.getColorFromHex("#fff5ee");
        case "sienna":
          return Util.getColorFromHex("#a0522d");
        case "silver":
          return Util.getColorFromHex("#c0c0c0");
        case "skyblue":
          return Util.getColorFromHex("#87ceeb");
        case "slateblue":
          return Util.getColorFromHex("#6a5acd");
        case "slategray":
          return Util.getColorFromHex("#708090");
        case "slategrey":
          return Util.getColorFromHex("#708090");
        case "snow":
          return Util.getColorFromHex("#fffafa");
        case "springgreen":
          return Util.getColorFromHex("#00ff7f");
        case "steelblue":
          return Util.getColorFromHex("#4682b4");
        case "tan":
          return Util.getColorFromHex("#d2b48c");
        case "teal":
          return Util.getColorFromHex("#008080");
        case "thistle":
          return Util.getColorFromHex("#d8bfd8");
        case "tomato":
          return Util.getColorFromHex("#ff6347");
        case "turquoise":
          return Util.getColorFromHex("#40e0d0");
        case "violet":
          return Util.getColorFromHex("#ee82ee");
        case "wheat":
          return Util.getColorFromHex("#f5deb3");
        case "white":
          return Util.getColorFromHex("#ffffff");
        case "whitesmoke":
          return Util.getColorFromHex("#f5f5f5");
        case "yellow":
          return Util.getColorFromHex("#ffff00");
        case "yellowgreen":
          return Util.getColorFromHex("#9acd32");
      }
    }
    return null;
  }

  static Color getColorFromHex(String hexString) {
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

  static Color getColorFromRgbString(String rgbString) {
    rgbString = rgbString.trim();
    var rgbValues = rgbString
        .substring(4, rgbString.length - 1)
        .split(",")
        .map((rbgValue) => int.parse(rbgValue.trim()))
        .toList();
    return Color.fromRGBO(rgbValues[0], rgbValues[1], rgbValues[2], 1);
  }

  static Color getColorFromRgbaString(String rgbaString) {
    rgbaString = rgbaString.trim();
    var rgbaValues = rgbaString
        .substring(5, rgbaString.length - 1)
        .split(",")
        .map((rbgValue) => rbgValue.trim())
        .toList();
    return Color.fromRGBO(int.parse(rgbaValues[0]), int.parse(rgbaValues[1]),
        int.parse(rgbaValues[2]), double.parse(rgbaValues[3]));
  }

  static Color getColorFromHlsString(String hlsString) {
    hlsString = hlsString.trim();
    var hlsValues = hlsString
        .substring(4, hlsString.length - 1)
        .split(",")
        .map((rbgValue) => double.parse(rbgValue.trim()))
        .toList();
    var rgbValues = hslToRgb(hlsValues[0], hlsValues[1], hlsValues[2]);
    return Color.fromRGBO(rgbValues[0], rgbValues[1], rgbValues[2], 1);
  }

  static Color getColorFromHlsaString(String hlsaString) {
    hlsaString = hlsaString.trim();
    var hlsaValues = hlsaString
        .substring(5, hlsaString.length - 1)
        .split(",")
        .map((rbgValue) => double.parse(rbgValue.trim()))
        .toList();
    var rgbaValues = hslToRgb(hlsaValues[0], hlsaValues[1], hlsaValues[2]);
    return Color.fromRGBO(
        rgbaValues[0], rgbaValues[1], rgbaValues[2], hlsaValues[3]);
  }

  static List<num> hslToRgb(double h, double s, double l) {
    double r, g, b;

    if (s == 0) {
      r = g = b = l; // achromatic
    } else {
      double q = l < 0.5 ? l * (1 + s) : l + s - l * s;
      double p = 2 * l - q;
      r = hueToRgb(p, q, h + 1 / 3);
      g = hueToRgb(p, q, h);
      b = hueToRgb(p, q, h - 1 / 3);
    }
    var rgb = [to255(r), to255(g), to255(b)];
    return rgb;
  }

  static num to255(double v) {
    return min(255, 256 * v);
  }

  /// Helper method that converts hue to rgb
  static double hueToRgb(double p, double q, double t) {
    if (t < 0) t += 1;
    if (t > 1) t -= 1;
    if (t < 1 / 6) return p + (q - p) * 6 * t;
    if (t < 1 / 2) return q;
    if (t < 2 / 3) return p + (q - p) * (2 / 3 - t) * 6;
    return p;
  }
}
