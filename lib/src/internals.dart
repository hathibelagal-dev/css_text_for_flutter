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

import 'package:xml/xml_events.dart' as xmle;
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import './utils.dart';

class _Tag {
  String name;
  String styles;

  _Tag(this.name, this.styles);
}

/// A default callback for links that does nothing.
void defaultLinksCallback(String link) {}

/// This class is at the core of the css_text library. It has most of the
/// methods required to convert HTML content into Flutter widgets
class Parser {
  var _stack = [];
  var _events;
  late BuildContext _context;
  late Function _linksCallback;

  Parser(BuildContext context, String data,
      {Function linksCallback = defaultLinksCallback}) {
    _events = xmle.parseEvents(data);
    _context = context;
    _linksCallback = linksCallback;
  }

  TextSpan _getTextSpan(text, style) {
    var rules = style.split(";").where((item) => !item.trim().isEmpty);
    TextStyle textStyle = DefaultTextStyle.of(_context).style;
    textStyle = textStyle.apply(color: Color(0xff000000));
    var isLink = false;
    var link = "";
    rules.forEach((String rule) {
      if (rule.indexOf(":") == -1) return;
      final parts = rule.split(":");
      String name = parts[0].trim();
      String value = parts[1].trim();
      switch (name) {
        case "color":
          textStyle = StyleGenUtils.addFontColor(textStyle, value);
          break;

        case "background":
          textStyle = StyleGenUtils.addBgColor(textStyle, value);
          break;

        case "font-weight":
          textStyle = StyleGenUtils.addFontWeight(textStyle, value);
          break;

        case "font-style":
          textStyle = StyleGenUtils.addFontStyle(textStyle, value);
          break;

        case "font-size":
          textStyle = StyleGenUtils.addFontSize(textStyle, value);
          break;

        case "text-decoration":
          textStyle = StyleGenUtils.addTextDecoration(textStyle, value);
          break;

        case "font-family":
          textStyle = StyleGenUtils.addFontFamily(textStyle, value);
          break;

        case "visit_link":
          isLink = true;
          link = TextGenUtils.getLink(value);
          break;
      }
    });
    if (isLink) {
      return TextSpan(
          style: textStyle,
          text: text,
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              _linksCallback(link);
            });
    }
    return TextSpan(style: textStyle, text: text);
  }

  TextSpan _handleText(String text) {
    text = TextGenUtils.strip(text);
    if (text.isEmpty) return TextSpan(text: "");
    var style = "";
    _stack.forEach((tag) {
      style += tag.styles + ";";
    });
    return _getTextSpan(text, style);
  }

  /// Converts HTML content to a list of [TextSpan] objects
  List<TextSpan> parse() {
    List<TextSpan> spans = List.empty(growable: true);
    _events.forEach((event) {
      if (event is xmle.XmlStartElementEvent) {
        if (!event.isSelfClosing) {
          var styles = "";
          if (event.name == 'b' || event.name == 'strong') {
            styles = "font-weight: bold;";
          } else if (event.name == 'i' || event.name == 'em') {
            styles = "font-style: italic;";
          } else if (event.name == 'u') {
            styles = "text-decoration: underline;";
          } else if (event.name == 'strike' ||
              event.name == 'del' ||
              event.name == 's') {
            styles = "text-decoration: line-through;";
          } else if (event.name == 'a') {
            styles = "visit_link:__#TO_GET#__;" +
                "text-decoration: underline;" +
                " color: #0000ff";
          }

          event.attributes.forEach((attribute) {
            if (attribute.name == "style")
              styles = styles + ";" + attribute.value;
            else if (attribute.name == "href") {
              styles = styles.replaceFirst(r"__#TO_GET#__",
                  attribute.value.replaceAll(r":", "__#COLON#__"));
            }
          });

          _stack.add(_Tag(event.name, styles));
        } else {
          if (event.name == "br") {
            spans.add(TextSpan(text: "\n"));
          }
        }
      }

      if (event is xmle.XmlEndElementEvent) {
        var top = _stack.removeLast();
        if (top.name != event.name) {
          print("Malformed HTML");
          return;
        }
        if (event.name == "p") {
          spans.add(TextSpan(text: "\n"));
        }
      }

      if (event is xmle.XmlTextEvent) {
        final currentSpan = _handleText(event.value);
        if (currentSpan.text!.isNotEmpty) {
          spans.add(currentSpan);
        }
      }
    });

    // for the last p tag
    if (spans[spans.length - 1].text == '\n') {
      spans.removeLast();
    }
    return spans;
  }
}
