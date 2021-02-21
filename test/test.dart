import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:css_text/css_text.dart';

class TestWidget extends StatelessWidget {
  final String stringToParse;

  const TestWidget({Key key, this.stringToParse}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var myRichText = HTML.toRichText(context, stringToParse);
    return myRichText;
  }
}

void main() {
  Widget wrap(String parse) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            "Demo",
          ),
        ),
        body: Container(
          padding: EdgeInsets.all(16.0),
          child: TestWidget(
            stringToParse: parse,
          ),
        ),
      ),
    );
  }

  testWidgets('successfully parses p tags', (WidgetTester tester) async {
    await tester.pumpWidget(
      wrap('<p>This is formatted correctly</p>'),
    );

    RichText text = tester.firstWidget(find.byType(RichText));
    expect(text.text.toPlainText(), 'This is formatted correctly');
  });

  group('Missing Tags', () {
    testWidgets('safely ignores missing opening tag',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        wrap('This is missing the opening tag</p>'),
      );

      RichText text = tester.firstWidget(find.byType(RichText));
      expect(text.text.toPlainText(), 'This is missing the opening tag');
    });

    testWidgets('safely ignores missing ending tag',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        wrap('<p>This is missing the ending tag'),
      );

      RichText text = tester.firstWidget(find.byType(RichText));
      expect(text.text.toPlainText(), 'This is missing the ending tag');
    });
  });
}
