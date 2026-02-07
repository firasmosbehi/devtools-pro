// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:convert';
import 'dart:typed_data';

import 'package:devtools_pro/main.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  binding.defaultBinaryMessenger.setMockMessageHandler(
    'flutter/assets',
    (message) async {
      final key = utf8.decode(message!.buffer.asUint8List());
      if (key == 'AssetManifest.json') {
        final data = utf8.encode('{}');
        return ByteData.view(Uint8List.fromList(data).buffer);
      }
      return ByteData(0);
    },
  );
  GoogleFonts.config.allowRuntimeFetching = false;

  testWidgets('Home lists utilities', (WidgetTester tester) async {
    await tester.pumpWidget(const DevToolsProApp());

    expect(find.text('Regex Builder'), findsOneWidget);
    expect(find.text('Cron Designer'), findsOneWidget);
    expect(find.text('CIDR Helper'), findsOneWidget);
  });
}
