/*
 * Copyright 2019 Ashraff Hathibelagal
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import 'package:flutter/material.dart';
import 'colors.dart';

/// Has utility methods to manipulate HTML text nodes
class TextGenUtils {
  /// Removes extra whitespace
  static String strip(String text) {
    var hasSpaceAfter = false;
    var hasSpaceBefore = false;
    if (text.startsWith(" ")) {
      hasSpaceBefore = true;
    }
    if (text.endsWith(" ")) {
      hasSpaceAfter = true;
    }
    text = text.trim();
    if (hasSpaceBefore) text = " " + text;
    if (hasSpaceAfter) text = text + " ";
    return text;
  }

  /// Returns the link of an anchor tag
  static String getLink(String value) {
    return value.replaceAll(r"__#COLON#__", ":");
  }
}

/// Has utility methods to convert CSS to [TextStyle] objects
class StyleGenUtils {
  /// Creates a [TextStyle] to handle CSS font-weight
  static TextStyle addFontWeight(TextStyle textStyle, String value) {
    final List<String> _supportedNumValues = [
      "100",
      "200",
      "300",
      "400",
      "500",
      "600",
      "700",
      "800",
      "900"
    ];
    if (_supportedNumValues.contains(value)) {
      return textStyle.copyWith(
          fontWeight: FontWeight.values[_supportedNumValues.indexOf(value)]);
    }
    switch (value) {
      case "normal":
        textStyle = textStyle.copyWith(fontWeight: FontWeight.normal);
        break;
      case "bold":
        textStyle = textStyle.copyWith(fontWeight: FontWeight.bold);
        break;
      default:
        textStyle = textStyle;
    }
    return textStyle;
  }

  static int _convertColor(String value) {
    var colorHex = 0xff000000;
    if (value.startsWith("#")) {
      if (value.length == 7)
        colorHex = int.parse(value.replaceAll(r"#", "0xff"));
      else if (value.length == 9)
        colorHex = int.parse(value.replaceAll(r"#", "0x"));
      else if (value.length == 4) {
        value = value.replaceFirst(r"#", "");
        value = value.split("").map((c) => "$c$c").join();
        colorHex = int.parse("0xff$value");
      }
    } else {
      value = value.toLowerCase();
      if (CSSColors.values[value] != null) {
        return CSSColors.values[value];
      }
    }
    return colorHex;
  }

  /// Creates a [TextStyle] to handle CSS color
  static TextStyle addFontColor(TextStyle textStyle, String value) {
    return textStyle.copyWith(color: Color(_convertColor(value)));
  }

  /// Creates a [TextStyle] to handle CSS background
  static TextStyle addBgColor(TextStyle textStyle, String value) {
    Paint p = Paint();
    p.color = Color(_convertColor(value));
    return textStyle.copyWith(background: p);
  }

  static TextStyle addFontStyle(TextStyle textStyle, String value) {
    if (value == "italic") {
      textStyle = textStyle.copyWith(fontStyle: FontStyle.italic);
    } else if (value == "normal") {
      textStyle = textStyle.copyWith(fontStyle: FontStyle.normal);
    }
    return textStyle;
  }

  /// Creates a [TextStyle] to handle CSS font-family
  static TextStyle addFontFamily(TextStyle textStyle, String value) {
    return textStyle.copyWith(fontFamily: value);
  }

  /// Creates a [TextStyle] to handle CSS font-size
  static TextStyle addFontSize(TextStyle textStyle, String value) {
    double number = 14.0;
    if (value.endsWith("px")) {
      number = double.parse(value.replaceAll("px", "").trim());
    } else if (value.endsWith("em")) {
      number *= double.parse(value.replaceAll("em", "").trim());
    }
    return textStyle.copyWith(fontSize: number);
  }

  /// Creates a [TextStyle] to handle CSS text-decoration
  static TextStyle addTextDecoration(TextStyle textStyle, String value) {
    if (value.indexOf("underline") != -1) {
      textStyle = textStyle.copyWith(decoration: TextDecoration.underline);
    }
    if (value.indexOf("overline") != -1) {
      textStyle = textStyle.copyWith(decoration: TextDecoration.overline);
    }
    if (value.indexOf("none") != -1) {
      return textStyle.copyWith(decoration: TextDecoration.none);
    }
    if (value.indexOf("line-through") != -1) {
      textStyle = textStyle.copyWith(decoration: TextDecoration.lineThrough);
    }
    if (value.indexOf("dotted") != -1) {
      textStyle =
          textStyle.copyWith(decorationStyle: TextDecorationStyle.dotted);
    } else if (value.indexOf("dashed") != -1) {
      textStyle =
          textStyle.copyWith(decorationStyle: TextDecorationStyle.dashed);
    } else if (value.indexOf("wavy") != -1) {
      textStyle = textStyle.copyWith(decorationStyle: TextDecorationStyle.wavy);
    }
    return textStyle;
  }
}
